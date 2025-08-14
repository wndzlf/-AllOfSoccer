const express = require('express');
const { User } = require('../models');
const auth = require('../middleware/auth');

const router = express.Router();

// 알림 목록 조회
router.get('/', auth, async (req, res) => {
  try {
    // 실제 알림 구현은 추후 추가
    res.json({
      success: true,
      data: [],
      message: 'Notification functionality will be implemented later'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch notifications',
      error: error.message
    });
  }
});

module.exports = router; 