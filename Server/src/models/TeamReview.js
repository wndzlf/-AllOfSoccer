const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const TeamReview = sequelize.define('TeamReview', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  match_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'matches',
      key: 'id'
    }
  },
  reviewer_team_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'teams',
      key: 'id'
    }
  },
  reviewee_team_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'teams',
      key: 'id'
    }
  },
  reviewer_user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  manner_score: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 5
    }
  },
  skill_score: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 5
    }
  },
  comment: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'team_reviews',
  indexes: [
    {
      unique: true,
      fields: ['match_id', 'reviewer_team_id', 'reviewee_team_id']
    },
    {
      fields: ['reviewee_team_id']
    },
    {
      fields: ['reviewer_team_id']
    }
  ]
});

module.exports = TeamReview;
