const User = require('./User');
const Team = require('./Team');
const TeamMember = require('./TeamMember');
const Match = require('./Match');
const MatchParticipant = require('./MatchParticipant');
const Comment = require('./Comment');
const MercenaryRequest = require('./MercenaryRequest');
const MercenaryApplication = require('./MercenaryApplication');
const MercenaryMatch = require('./MercenaryMatch');
const UserProfile = require('./UserProfile');
const UserInterest = require('./UserInterest');
const TeamReview = require('./TeamReview');

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
Match.belongsTo(Team, { as: 'team', foreignKey: 'team_id' });

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

// Team - MercenaryRequest 관계
Team.hasMany(MercenaryRequest, { foreignKey: 'team_id' });
MercenaryRequest.belongsTo(Team, { as: 'team', foreignKey: 'team_id' });

// User - MercenaryApplication 관계
User.hasMany(MercenaryApplication, { foreignKey: 'user_id' });
MercenaryApplication.belongsTo(User, { foreignKey: 'user_id' });

// MercenaryRequest - MercenaryMatch 관계
MercenaryRequest.hasMany(MercenaryMatch, { foreignKey: 'mercenary_request_id' });
MercenaryMatch.belongsTo(MercenaryRequest, { as: 'mercenaryRequest', foreignKey: 'mercenary_request_id' });

// User - MercenaryMatch 관계
User.hasMany(MercenaryMatch, { foreignKey: 'user_id' });
MercenaryMatch.belongsTo(User, { foreignKey: 'user_id' });

// User - UserProfile 관계 (1:1)
User.hasOne(UserProfile, { foreignKey: 'user_id' });
UserProfile.belongsTo(User, { foreignKey: 'user_id' });

// User - UserInterest 관계
User.hasMany(UserInterest, { foreignKey: 'user_id' });
UserInterest.belongsTo(User, { foreignKey: 'user_id' });

// Match - UserInterest 관계
Match.hasMany(UserInterest, { foreignKey: 'match_id' });
UserInterest.belongsTo(Match, { foreignKey: 'match_id' });

// MercenaryRequest - UserInterest 관계
MercenaryRequest.hasMany(UserInterest, { foreignKey: 'mercenary_request_id' });
UserInterest.belongsTo(MercenaryRequest, { foreignKey: 'mercenary_request_id' });

// TeamReview 관계
Match.hasMany(TeamReview, { foreignKey: 'match_id' });
TeamReview.belongsTo(Match, { foreignKey: 'match_id' });

Team.hasMany(TeamReview, { as: 'reviewsGiven', foreignKey: 'reviewer_team_id' });
TeamReview.belongsTo(Team, { as: 'reviewerTeam', foreignKey: 'reviewer_team_id' });

Team.hasMany(TeamReview, { as: 'reviewsReceived', foreignKey: 'reviewee_team_id' });
TeamReview.belongsTo(Team, { as: 'revieweeTeam', foreignKey: 'reviewee_team_id' });

User.hasMany(TeamReview, { foreignKey: 'reviewer_user_id' });
TeamReview.belongsTo(User, { as: 'reviewerUser', foreignKey: 'reviewer_user_id' });

module.exports = {
  User,
  Team,
  TeamMember,
  Match,
  MatchParticipant,
  Comment,
  MercenaryRequest,
  MercenaryApplication,
  MercenaryMatch,
  UserProfile,
  UserInterest,
  TeamReview
};
