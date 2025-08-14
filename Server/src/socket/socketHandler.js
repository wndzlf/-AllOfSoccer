const jwt = require('jsonwebtoken');
const { User } = require('../models');

const socketHandler = (io) => {
  // 인증 미들웨어
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      
      if (!token) {
        return next(new Error('Authentication error'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findByPk(decoded.userId);

      if (!user || !user.is_active) {
        return next(new Error('User not found or inactive'));
      }

      socket.userId = user.id;
      socket.user = user;
      next();
    } catch (error) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`User ${socket.userId} connected`);

    // 사용자를 개인 룸에 참가시킴
    socket.join(`user_${socket.userId}`);

    // 매칭 관련 이벤트
    socket.on('join_match', (matchId) => {
      socket.join(`match_${matchId}`);
      console.log(`User ${socket.userId} joined match ${matchId}`);
    });

    socket.on('leave_match', (matchId) => {
      socket.leave(`match_${matchId}`);
      console.log(`User ${socket.userId} left match ${matchId}`);
    });

    // 채팅 메시지
    socket.on('send_message', (data) => {
      const { matchId, message } = data;
      
      // 메시지를 해당 매칭 룸의 모든 사용자에게 전송
      io.to(`match_${matchId}`).emit('new_message', {
        userId: socket.userId,
        userName: socket.user.name,
        message,
        timestamp: new Date().toISOString()
      });
    });

    // 매칭 상태 변경 알림
    socket.on('match_status_changed', (data) => {
      const { matchId, status, participants } = data;
      
      io.to(`match_${matchId}`).emit('match_updated', {
        matchId,
        status,
        participants,
        timestamp: new Date().toISOString()
      });
    });

    // 참가 신청 알림
    socket.on('match_application', (data) => {
      const { matchId, applicantId, applicantName } = data;
      
      // 매칭 생성자에게 알림
      io.to(`match_${matchId}`).emit('new_application', {
        matchId,
        applicantId,
        applicantName,
        timestamp: new Date().toISOString()
      });
    });

    // 연결 해제
    socket.on('disconnect', () => {
      console.log(`User ${socket.userId} disconnected`);
    });
  });

  // 전역 이벤트 (서버에서 발생하는 이벤트)
  io.on('new_match_created', (matchData) => {
    // 새로운 매칭이 생성되었을 때 모든 사용자에게 알림
    io.emit('new_match_available', matchData);
  });

  io.on('match_full', (matchId) => {
    // 매칭이 가득 찼을 때 해당 매칭 참가자들에게 알림
    io.to(`match_${matchId}`).emit('match_is_full', {
      matchId,
      timestamp: new Date().toISOString()
    });
  });

  return io;
};

module.exports = socketHandler; 