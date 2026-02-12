const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserProfile = sequelize.define('UserProfile', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    unique: true,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  nickname: {
    type: DataTypes.STRING(50),
    allowNull: true,
    validate: {
      len: {
        args: [2, 50],
        msg: 'Nickname must be between 2 and 50 characters'
      }
    }
  },
  bio: {
    type: DataTypes.STRING(500),
    allowNull: true,
    validate: {
      len: {
        args: [0, 500],
        msg: 'Bio must be less than 500 characters'
      }
    }
  },
  profile_image_url: {
    type: DataTypes.STRING,
    allowNull: true
  },
  preferred_positions: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: []
  },
  preferred_skill_level: {
    type: DataTypes.ENUM('beginner', 'intermediate', 'advanced', 'expert', 'national', 'worldclass', 'legend'),
    allowNull: true
  },
  location: {
    type: DataTypes.STRING,
    allowNull: true
  },
  phone: {
    type: DataTypes.STRING,
    allowNull: true
  },
  email: {
    type: DataTypes.STRING,
    allowNull: true,
    validate: {
      isEmail: {
        msg: 'Invalid email format'
      }
    }
  }
}, {
  tableName: 'user_profiles',
  indexes: [
    {
      fields: ['user_id']
    }
  ]
});

module.exports = UserProfile;
