const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Comment = sequelize.define('Comment', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  content: {
    type: DataTypes.TEXT,
    allowNull: false
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
  team_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'teams',
      key: 'id'
    }
  },
  parent_id: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'comments',
      key: 'id'
    }
  },
  type: {
    type: DataTypes.ENUM('team_introduction', 'match_comment', 'general'),
    defaultValue: 'general'
  },
  order_index: {
    type: DataTypes.INTEGER,
    allowNull: true
  },
  is_active: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'comments',
  indexes: [
    {
      fields: ['user_id']
    },
    {
      fields: ['match_id']
    },
    {
      fields: ['team_id']
    },
    {
      fields: ['parent_id']
    },
    {
      fields: ['type']
    },
    {
      fields: ['order_index']
    }
  ]
});

module.exports = Comment; 