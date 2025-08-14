const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MatchParticipant = sequelize.define('MatchParticipant', {
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
  user_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  team_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'teams',
      key: 'id'
    }
  },
  status: {
    type: DataTypes.ENUM('pending', 'approved', 'rejected', 'cancelled'),
    defaultValue: 'pending'
  },
  applied_at: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  approved_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  cancelled_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  payment_status: {
    type: DataTypes.ENUM('pending', 'paid', 'refunded'),
    defaultValue: 'pending'
  },
  payment_amount: {
    type: DataTypes.INTEGER,
    allowNull: true
  }
}, {
  tableName: 'match_participants',
  indexes: [
    {
      unique: true,
      fields: ['match_id', 'user_id']
    },
    {
      fields: ['match_id']
    },
    {
      fields: ['user_id']
    },
    {
      fields: ['status']
    }
  ]
});

module.exports = MatchParticipant; 