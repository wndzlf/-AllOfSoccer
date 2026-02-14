const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MercenaryRequest = sequelize.define('MercenaryRequest', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  team_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'teams',
      key: 'id'
    }
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  date: {
    type: DataTypes.DATE,
    allowNull: false
  },
  location: {
    type: DataTypes.STRING,
    allowNull: false
  },
  address: {
    type: DataTypes.STRING,
    allowNull: true
  },
  latitude: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: true
  },
  longitude: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: true
  },
  fee: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0
  },
  mercenary_count: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 1,
    validate: {
      min: 1,
      max: 100
    }
  },
  positions_needed: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: {}
  },
  skill_level_min: {
    type: DataTypes.ENUM('beginner', 'intermediate', 'advanced', 'expert', 'national', 'worldclass', 'legend'),
    allowNull: true,
    defaultValue: 'beginner'
  },
  skill_level_max: {
    type: DataTypes.ENUM('beginner', 'intermediate', 'advanced', 'expert', 'national', 'worldclass', 'legend'),
    allowNull: true,
    defaultValue: 'expert'
  },
  has_former_player: {
    type: DataTypes.BOOLEAN,
    allowNull: true,
    defaultValue: false
  },
  current_applicants: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0
  },
  match_type: {
    type: DataTypes.ENUM('6v6', '11v11'),
    allowNull: true,
    defaultValue: '11v11'
  },
  gender_type: {
    type: DataTypes.ENUM('male', 'female', 'mixed'),
    allowNull: true,
    defaultValue: 'mixed'
  },
  shoes_requirement: {
    type: DataTypes.ENUM('futsal', 'soccer', 'any'),
    allowNull: true,
    defaultValue: 'any'
  },
  age_range_min: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  age_range_max: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('recruiting', 'closed'),
    defaultValue: 'recruiting'
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'mercenary_requests',
  indexes: [
    {
      fields: ['date']
    },
    {
      fields: ['location']
    },
    {
      fields: ['status']
    },
    {
      fields: ['team_id']
    },
    {
      fields: ['skill_level_min']
    }
  ]
});

module.exports = MercenaryRequest;
