const express = require('express');
const { User, UserProfile, UserInterest, Match, MercenaryRequest, Team } = require('../models');
const auth = require('../middleware/auth');
const { Op } = require('sequelize');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const jwt = require('jsonwebtoken');

const router = express.Router();

// 사용자 목록 조회 (관리자용)
router.get('/', auth, async (req, res) => {
  try {
    const { page = 1, limit = 20, search } = req.query;
    const offset = (page - 1) * limit;
    const where = { is_active: true };

    if (search) {
      where.name = { [Op.iLike]: `%${search}%` };
    }

    const { count, rows: users } = await User.findAndCountAll({
      where,
      attributes: { exclude: ['password', 'refresh_token'] },
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    res.json({
      success: true,
      data: users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        total_pages: Math.ceil(count / limit)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch users',
      error: error.message
    });
  }
});

// 특정 사용자 조회
router.get('/:id', auth, async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id, {
      attributes: { exclude: ['password', 'refresh_token'] }
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      data: user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user',
      error: error.message
    });
  }
});

// ============================================
// 사용자 프로필 관련 API
// ============================================

// 사용자 프로필 조회
router.get('/profile/me', auth, async (req, res) => {
  try {
    let profile = await UserProfile.findOne({
      where: { user_id: req.user.id }
    });

    if (!profile) {
      // 프로필이 없으면 빈 프로필 생성
      profile = await UserProfile.create({
        user_id: req.user.id
      });
    }

    res.json({
      success: true,
      data: profile
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user profile',
      error: error.message
    });
  }
});

// 사용자 프로필 수정 (부분 수정 지원)
router.put('/profile/me', auth, async (req, res) => {
  try {
    const { nickname, bio, preferred_positions, preferred_skill_level, location, phone, email } = req.body;

    // 닉네임 검증
    if (nickname !== undefined) {
      if (nickname && (nickname.length < 2 || nickname.length > 50)) {
        return res.status(400).json({
          success: false,
          message: 'Nickname must be between 2 and 50 characters'
        });
      }
    }

    // 소개글 검증
    if (bio !== undefined) {
      if (bio && bio.length > 500) {
        return res.status(400).json({
          success: false,
          message: 'Bio must be less than 500 characters'
        });
      }
    }

    // 이메일 검증
    if (email !== undefined && email) {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid email format'
        });
      }
    }

    let profile = await UserProfile.findOne({
      where: { user_id: req.user.id }
    });

    if (!profile) {
      // 프로필이 없으면 생성
      profile = await UserProfile.create({
        user_id: req.user.id,
        nickname,
        bio,
        preferred_positions,
        preferred_skill_level,
        location,
        phone,
        email
      });
    } else {
      // 기존 프로필 수정
      const updateData = {};
      if (nickname !== undefined) updateData.nickname = nickname;
      if (bio !== undefined) updateData.bio = bio;
      if (preferred_positions !== undefined) updateData.preferred_positions = preferred_positions;
      if (preferred_skill_level !== undefined) updateData.preferred_skill_level = preferred_skill_level;
      if (location !== undefined) updateData.location = location;
      if (phone !== undefined) updateData.phone = phone;
      if (email !== undefined) updateData.email = email;

      await profile.update(updateData);
    }

    res.json({
      success: true,
      data: profile,
      message: 'Profile updated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update user profile',
      error: error.message
    });
  }
});

// 프로필 이미지 업로드 설정
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../../uploads/profiles');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, 'profile-' + req.user.id + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const allowedMimes = ['image/jpeg', 'image/png'];
    if (!allowedMimes.includes(file.mimetype)) {
      cb(new Error('Only jpg and png images are allowed'));
      return;
    }
    cb(null, true);
  }
});

// 프로필 이미지 업로드
router.post('/profile-image/me', auth, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image file provided'
      });
    }

    const imageUrl = `/uploads/profiles/${req.file.filename}`;

    let profile = await UserProfile.findOne({
      where: { user_id: req.user.id }
    });

    if (!profile) {
      profile = await UserProfile.create({
        user_id: req.user.id,
        profile_image_url: imageUrl
      });
    } else {
      await profile.update({ profile_image_url: imageUrl });
    }

    res.status(201).json({
      success: true,
      data: {
        profile_image_url: imageUrl
      },
      message: 'Profile image uploaded successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to upload profile image',
      error: error.message
    });
  }
});

// ============================================
// 관심 글 조회 API
// ============================================

// 관심 팀 매칭 목록 조회
router.get('/my/interests/matches', auth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const { count, rows: interests } = await UserInterest.findAndCountAll({
      where: {
        user_id: req.user.id,
        interest_type: 'match'
      },
      include: [
        {
          model: Match,
          include: [
            {
              model: Team,
              as: 'team',
              include: [
                {
                  model: User,
                  as: 'captain',
                  attributes: ['id', 'name', 'profile_image']
                }
              ]
            }
          ]
        }
      ],
      order: [['created_at', 'DESC']],
      limit,
      offset
    });

    const totalPages = Math.ceil(count / limit);

    res.json({
      success: true,
      data: interests.map(i => i.Match),
      pagination: {
        page,
        limit,
        total: count,
        total_pages: totalPages
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch interested matches',
      error: error.message
    });
  }
});

// 관심 용병 목록 조회
router.get('/my/interests/mercenary', auth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const { count, rows: interests } = await UserInterest.findAndCountAll({
      where: {
        user_id: req.user.id,
        interest_type: 'mercenary'
      },
      include: [
        {
          model: MercenaryRequest,
          include: [
            {
              model: Team,
              as: 'team',
              include: [
                {
                  model: User,
                  as: 'captain',
                  attributes: ['id', 'name', 'profile_image']
                }
              ]
            }
          ]
        }
      ],
      order: [['created_at', 'DESC']],
      limit,
      offset
    });

    const totalPages = Math.ceil(count / limit);

    res.json({
      success: true,
      data: interests.map(i => i.MercenaryRequest),
      pagination: {
        page,
        limit,
        total: count,
        total_pages: totalPages
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch interested mercenary requests',
      error: error.message
    });
  }
});

module.exports = router; 