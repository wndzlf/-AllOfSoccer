const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const MercenaryMatch = sequelize.define('MercenaryMatch', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  mercenary_request_id: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'mercenary_requests',
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
  status: {
    type: DataTypes.ENUM('pending', 'accepted', 'rejected'),
    defaultValue: 'pending'
  },
  applied_at: {
    type: DataTypes.DATE,
    allowNull: false,
    defaultValue: DataTypes.NOW
  },
  accepted_at: {
    type: DataTypes.DATE,
    allowNull: true
  },
  rejected_at: {
    type: DataTypes.DATE,
    allowNull: true
  }
}, {
  tableName: 'mercenary_matches',
  indexes: [
    {
      fields: ['mercenary_request_id']
    },
    {
      fields: ['user_id']
    },
    {
      fields: ['status']
    },
    {
      unique: true,
      fields: ['mercenary_request_id', 'user_id']
    }
  ]
});

module.exports = MercenaryMatch;
