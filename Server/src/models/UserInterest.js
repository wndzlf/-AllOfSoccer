const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserInterest = sequelize.define('UserInterest', {
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
  match_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'matches',
      key: 'id'
    }
  },
  mercenary_request_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'mercenary_requests',
      key: 'id'
    }
  },
  interest_type: {
    type: DataTypes.ENUM('match', 'mercenary'),
    allowNull: false
  }
}, {
  tableName: 'user_interests',
  indexes: [
    {
      fields: ['user_id']
    },
    {
      fields: ['match_id']
    },
    {
      fields: ['mercenary_request_id']
    },
    {
      unique: true,
      fields: ['user_id', 'match_id'],
      where: { interest_type: 'match' }
    },
    {
      unique: true,
      fields: ['user_id', 'mercenary_request_id'],
      where: { interest_type: 'mercenary' }
    }
  ]
});

module.exports = UserInterest;
