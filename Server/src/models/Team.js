const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Team = sequelize.define('Team', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  logo: {
    type: DataTypes.STRING,
    allowNull: true
  },
  captain_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  age_range_min: {
    type: DataTypes.INTEGER,
    allowNull: true,
    validate: {
      min: 10,
      max: 100
    }
  },
  age_range_max: {
    type: DataTypes.INTEGER,
    allowNull: true,
    validate: {
      min: 10,
      max: 100
    }
  },
  skill_level: {
    type: DataTypes.ENUM('beginner', 'intermediate', 'advanced', 'expert', 'national', 'worldclass', 'legend'),
    allowNull: true
  },
  introduction: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'teams'
});

module.exports = Team; 