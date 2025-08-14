const express = require('express');
const jwt = require('jsonwebtoken');
const { User } = require('../models');
const auth = require('../middleware/auth');

const router = express.Router();

// Apple Sign-In
router.post('/apple-signin', async (req, res) => {
  try {
    const { apple_id, email, name } = req.body;

    if (!apple_id) {
      return res.status(400).json({
        success: false,
        message: 'Apple ID is required'
      });
    }

    // 기존 사용자 확인
    let user = await User.findOne({
      where: { apple_id }
    });

    if (!user) {
      // 새 사용자 생성
      user = await User.create({
        apple_id,
        email,
        name,
        last_login: new Date()
      });
    } else {
      // 로그인 시간 업데이트
      await user.update({ last_login: new Date() });
    }

    // JWT 토큰 생성
    const accessToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    const refreshToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d' }
    );

    // 리프레시 토큰 저장
    await user.update({ refresh_token: refreshToken });

    res.json({
      success: true,
      data: {
        user: user.toJSON(),
        access_token: accessToken,
        refresh_token: refreshToken
      },
      message: 'Apple Sign-In successful'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Apple Sign-In failed',
      error: error.message
    });
  }
});

// 토큰 갱신
router.post('/refresh', async (req, res) => {
  try {
    const { refresh_token } = req.body;

    if (!refresh_token) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token is required'
      });
    }

    const decoded = jwt.verify(refresh_token, process.env.JWT_SECRET);
    const user = await User.findByPk(decoded.userId);

    if (!user || user.refresh_token !== refresh_token) {
      return res.status(401).json({
        success: false,
        message: 'Invalid refresh token'
      });
    }

    // 새로운 토큰 생성
    const accessToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    const newRefreshToken = jwt.sign(
      { userId: user.id },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d' }
    );

    // 리프레시 토큰 업데이트
    await user.update({ refresh_token: newRefreshToken });

    res.json({
      success: true,
      data: {
        access_token: accessToken,
        refresh_token: newRefreshToken
      },
      message: 'Token refreshed successfully'
    });
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid refresh token'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Token refresh failed',
      error: error.message
    });
  }
});

// 로그아웃
router.post('/logout', auth, async (req, res) => {
  try {
    await req.user.update({ refresh_token: null });

    res.json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Logout failed',
      error: error.message
    });
  }
});

// 프로필 조회
router.get('/profile', auth, async (req, res) => {
  try {
    res.json({
      success: true,
      data: req.user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch profile',
      error: error.message
    });
  }
});

// 프로필 수정
router.put('/profile', auth, async (req, res) => {
  try {
    const { name, phone, profile_image, fcm_token } = req.body;

    const updateData = {};
    if (name) updateData.name = name;
    if (phone !== undefined) updateData.phone = phone;
    if (profile_image !== undefined) updateData.profile_image = profile_image;
    if (fcm_token !== undefined) updateData.fcm_token = fcm_token;

    await req.user.update(updateData);

    res.json({
      success: true,
      data: req.user,
      message: 'Profile updated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update profile',
      error: error.message
    });
  }
});

// 회원탈퇴
router.delete('/profile', auth, async (req, res) => {
  try {
    await req.user.update({ 
      is_active: false,
      refresh_token: null
    });

    res.json({
      success: true,
      message: 'Account deactivated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to deactivate account',
      error: error.message
    });
  }
});

module.exports = router; 