const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Match = sequelize.define('Match', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
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
  max_participants: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 22 // 11:11 기본값
  },
  current_participants: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0
  },
  status: {
    type: DataTypes.ENUM('recruiting', 'full', 'completed', 'cancelled'),
    defaultValue: 'recruiting'
  },
  team_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'teams',
      key: 'id'
    }
  },
  // iOS FirstTeamRecruitmentViewController 필드들
  match_type: {
    type: DataTypes.ENUM('6v6', '11v11'),
    allowNull: false,
    defaultValue: '11v11'
  },
  gender_type: {
    type: DataTypes.ENUM('male', 'female', 'mixed'),
    allowNull: false,
    defaultValue: 'mixed'
  },
  shoes_requirement: {
    type: DataTypes.ENUM('futsal', 'soccer', 'any'),
    allowNull: false,
    defaultValue: 'any'
  },
  // iOS SecondTeamRecruitmentViewController 필드들
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
  skill_level_min: {
    type: DataTypes.ENUM('beginner', 'intermediate', 'advanced', 'expert', 'national', 'worldclass', 'legend'),
    allowNull: true
  },
  skill_level_max: {
    type: DataTypes.ENUM('beginner', 'intermediate', 'advanced', 'expert', 'national', 'worldclass', 'legend'),
    allowNull: true
  },
  team_introduction: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'matches',
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
      fields: ['match_type']
    },
    {
      fields: ['gender_type']
    }
  ]
});

module.exports = Match; 