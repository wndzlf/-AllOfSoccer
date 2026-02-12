const jwt = require('jsonwebtoken');
const { User } = require('../models');

const auth = async (req, res, next) => {
  try {
    const authorizationHeader = req.header('Authorization');
    let token = authorizationHeader ? authorizationHeader.replace('Bearer ', '') : '';

    // 개발 환경에서 토큰이 없으면 테스트 토큰 사용
    if (!token && process.env.NODE_ENV === 'development') {
      console.log('⚠️  개발 모드: 테스트 토큰 사용');
      // 테스트용 임시 토큰 생성
      const testUser = {
        userId: '550e8400-e29b-41d4-a716-446655440001',
        email: 'test@example.com',
        name: '테스트 사용자'
      };
      token = jwt.sign(testUser, process.env.JWT_SECRET || 'test-secret', { expiresIn: '7d' });
    }

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access token is required'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'test-secret');

    // 개발 환경에서는 user 확인을 건너뛸 수 있음
    if (process.env.NODE_ENV === 'development') {
      // decoded 객체를 기반으로 user 객체 생성
      req.user = {
        id: decoded.userId || decoded.id,
        email: decoded.email,
        name: decoded.name
      };
      req.token = token;
      next();
      return;
    }

    const user = await User.findByPk(decoded.userId);

    if (!user || !user.is_active) {
      return res.status(401).json({
        success: false,
        message: 'User not found or inactive'
      });
    }

    req.user = user;
    req.token = token;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }

    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Authentication error'
    });
  }
};

module.exports = auth; 
