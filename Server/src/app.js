const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const { createServer } = require('http');
const { Server } = require('socket.io');

// Import configurations
const dbConfig = require('./config/database');
const redisConfig = require('./config/redis');

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const teamRoutes = require('./routes/teams');
const matchRoutes = require('./routes/matches');
const chatRoutes = require('./routes/chats');
const notificationRoutes = require('./routes/notifications');
const uploadRoutes = require('./routes/uploads');

// Import middleware
const errorHandler = require('./middleware/errorHandler');
const authMiddleware = require('./middleware/auth');

// Import socket handler
const socketHandler = require('./socket/socketHandler');

const app = express();
const server = createServer(app);

// Socket.io setup
const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(',') || "http://localhost:3000",
  credentials: true
}));
app.use(morgan('combined'));
app.use(limiter);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Static files
app.use('/uploads', express.static('uploads'));

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'AllOfSoccer Server is running',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', authMiddleware, userRoutes);
app.use('/api/teams', authMiddleware, teamRoutes);
app.use('/api/matches', authMiddleware, matchRoutes);
app.use('/api/chats', authMiddleware, chatRoutes);
app.use('/api/notifications', authMiddleware, notificationRoutes);
app.use('/api/uploads', authMiddleware, uploadRoutes);

// Socket connection
socketHandler(io);

// Error handling middleware
app.use(errorHandler);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

const PORT = process.env.PORT || 3000;

// Database connection
dbConfig.authenticate()
  .then(() => {
    console.log('Database connected successfully');
    return dbConfig.sync({ alter: true }); // Use { force: true } for development to recreate tables
  })
  .then(() => {
    console.log('Database synchronized');
    server.listen(PORT, () => {
      console.log(`🚀 AllOfSoccer Server is running on port ${PORT}`);
      console.log(`📊 Environment: ${process.env.NODE_ENV}`);
      console.log(`🔗 Health check: http://localhost:${PORT}/health`);
    });
  })
  .catch(err => {
    console.error('Database connection failed:', err);
    process.exit(1);
  });

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Process terminated');
  });
});

module.exports = app; 