const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MercenaryApplication = sequelize.define('MercenaryApplication', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',
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
  available_dates: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: []
  },
  preferred_locations: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: []
  },
  positions: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: []
  },
  skill_level: {
    type: DataTypes.ENUM('beginner', 'intermediate', 'advanced', 'expert', 'national', 'worldclass', 'legend'),
    allowNull: true,
    defaultValue: 'beginner'
  },
  preferred_fee_min: {
    type: DataTypes.INTEGER,
    allowNull: true,
    defaultValue: 0
  },
  preferred_fee_max: {
    type: DataTypes.INTEGER,
    allowNull: true,
    defaultValue: 100000
  },
  status: {
    type: DataTypes.ENUM('available', 'matched', 'unavailable'),
    defaultValue: 'available'
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'mercenary_applications',
  indexes: [
    {
      fields: ['user_id']
    },
    {
      fields: ['status']
    },
    {
      fields: ['skill_level']
    }
  ]
});

module.exports = MercenaryApplication;
