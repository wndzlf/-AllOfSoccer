const User = require('./User');
const Team = require('./Team');
const TeamMember = require('./TeamMember');
const Match = require('./Match');
const MatchParticipant = require('./MatchParticipant');
const Comment = require('./Comment');

// User - Team 관계 (팀장)
User.hasMany(Team, { as: 'captainedTeams', foreignKey: 'captain_id' });
Team.belongsTo(User, { as: 'captain', foreignKey: 'captain_id' });

// User - TeamMember 관계
User.hasMany(TeamMember, { foreignKey: 'user_id' });
TeamMember.belongsTo(User, { foreignKey: 'user_id' });

// Team - TeamMember 관계
Team.hasMany(TeamMember, { foreignKey: 'team_id' });
TeamMember.belongsTo(Team, { foreignKey: 'team_id' });

// Team - Match 관계
Team.hasMany(Match, { foreignKey: 'team_id' });
Match.belongsTo(Team, { foreignKey: 'team_id' });

// User - MatchParticipant 관계
User.hasMany(MatchParticipant, { foreignKey: 'user_id' });
MatchParticipant.belongsTo(User, { foreignKey: 'user_id' });

// Match - MatchParticipant 관계
Match.hasMany(MatchParticipant, { foreignKey: 'match_id' });
MatchParticipant.belongsTo(Match, { foreignKey: 'match_id' });

// Team - MatchParticipant 관계
Team.hasMany(MatchParticipant, { foreignKey: 'team_id' });
MatchParticipant.belongsTo(Team, { foreignKey: 'team_id' });

// User - Comment 관계
User.hasMany(Comment, { foreignKey: 'user_id' });
Comment.belongsTo(User, { foreignKey: 'user_id' });

// Match - Comment 관계
Match.hasMany(Comment, { foreignKey: 'match_id' });
Comment.belongsTo(Match, { foreignKey: 'match_id' });

// Team - Comment 관계
Team.hasMany(Comment, { foreignKey: 'team_id' });
Comment.belongsTo(Team, { foreignKey: 'team_id' });

// Comment - Comment 관계 (대댓글)
Comment.hasMany(Comment, { as: 'replies', foreignKey: 'parent_id' });
Comment.belongsTo(Comment, { as: 'parent', foreignKey: 'parent_id' });

module.exports = {
  User,
  Team,
  TeamMember,
  Match,
  MatchParticipant,
  Comment
}; 