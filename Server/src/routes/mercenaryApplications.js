const express = require('express');
const { Op } = require('sequelize');
const { MercenaryApplication, User } = require('../models');
const auth = require('../middleware/auth');

const router = express.Router();

// 용병 지원자 목록 조회 (필터링, 정렬, 페이징)
router.get('/', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      skill_level,
      location,
      status = 'available',
      sort_by = 'created_at',
      sort_order = 'DESC'
    } = req.query;

    const offset = (page - 1) * limit;
    const where = { is_active: true };

    // 필터링 조건들
    if (skill_level) {
      where.skill_level = skill_level;
    }

    if (location) {
      // preferred_locations는 JSON 배열이므로 특별한 쿼리 필요
      where.preferred_locations = { [Op.contains]: [location] };
    }

    if (status) {
      where.status = status;
    }

    const { count, rows: applications } = await MercenaryApplication.findAndCountAll({
      where,
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'profile_image', 'phone']
        }
      ],
      order: [[sort_by, sort_order]],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    res.json({
      success: true,
      data: applications,
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
      message: 'Failed to fetch mercenary applications',
      error: error.message
    });
  }
});

// 용병 지원 등록
router.post('/', auth, async (req, res) => {
  try {
    const {
      title,
      description,
      available_dates,
      preferred_locations,
      positions,
      skill_level,
      preferred_fee_min,
      preferred_fee_max
    } = req.body;

    // 필수 필드 검증
    if (!title) {
      return res.status(400).json({
        success: false,
        message: 'Title is required'
      });
    }

    const application = await MercenaryApplication.create({
      user_id: req.user.id,
      title,
      description,
      available_dates: available_dates || [],
      preferred_locations: preferred_locations || [],
      positions: positions || [],
      skill_level: skill_level || 'beginner',
      preferred_fee_min: preferred_fee_min || 0,
      preferred_fee_max: preferred_fee_max || 100000,
      status: 'available'
    });

    const createdApplication = await MercenaryApplication.findByPk(application.id, {
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'profile_image', 'phone']
        }
      ]
    });

    res.status(201).json({
      success: true,
      data: createdApplication,
      message: 'Mercenary application created successfully'
    });
  } catch (error) {
    console.error('용병 지원 등록 에러:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create mercenary application',
      error: error.message
    });
  }
});

// 용병 지원 상세 조회
router.get('/:id', async (req, res) => {
  try {
    const application = await MercenaryApplication.findByPk(req.params.id, {
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'profile_image', 'phone', 'email']
        }
      ]
    });

    if (!application) {
      return res.status(404).json({
        success: false,
        message: 'Mercenary application not found'
      });
    }

    res.json({
      success: true,
      data: application
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch mercenary application',
      error: error.message
    });
  }
});

// 용병 지원 수정
router.put('/:id', auth, async (req, res) => {
  try {
    const application = await MercenaryApplication.findByPk(req.params.id);

    if (!application) {
      return res.status(404).json({
        success: false,
        message: 'Mercenary application not found'
      });
    }

    // 본인 지원만 수정 가능
    if (application.user_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'You can only update your own mercenary application'
      });
    }

    await application.update(req.body);

    const updatedApplication = await MercenaryApplication.findByPk(req.params.id, {
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'profile_image', 'phone']
        }
      ]
    });

    res.json({
      success: true,
      data: updatedApplication,
      message: 'Mercenary application updated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update mercenary application',
      error: error.message
    });
  }
});

// 용병 지원 삭제
router.delete('/:id', auth, async (req, res) => {
  try {
    const application = await MercenaryApplication.findByPk(req.params.id);

    if (!application) {
      return res.status(404).json({
        success: false,
        message: 'Mercenary application not found'
      });
    }

    // 본인 지원만 삭제 가능
    if (application.user_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own mercenary application'
      });
    }

    await application.update({ is_active: false });

    res.json({
      success: true,
      message: 'Mercenary application deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to delete mercenary application',
      error: error.message
    });
  }
});

// 내가 올린 용병 지원 목록 조회
router.get('/my/posted', auth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const { count, rows: applications } = await MercenaryApplication.findAndCountAll({
      where: {
        user_id: req.user.id,
        is_active: true
      },
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'profile_image', 'phone']
        }
      ],
      order: [['created_at', 'DESC']],
      limit,
      offset
    });

    const totalPages = Math.ceil(count / limit);

    res.json({
      success: true,
      data: applications,
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
      message: 'Failed to fetch my mercenary applications',
      error: error.message
    });
  }
});

module.exports = router;
