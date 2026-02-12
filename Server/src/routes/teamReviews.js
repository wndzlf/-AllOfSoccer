const express = require('express');
const { Op, fn, col } = require('sequelize');
const { TeamReview, Match, Team, TeamMember, User } = require('../models');
const auth = require('../middleware/auth');

const router = express.Router();

const REVIEWABLE_MATCH_STATUSES = ['completed', 'full'];

const resolveReviewerTeam = async (userId, reviewerTeamId) => {
  const where = {
    user_id: userId,
    is_active: true
  };

  if (reviewerTeamId) {
    where.team_id = reviewerTeamId;
  }

  const memberships = await TeamMember.findAll({ where });
  if (!memberships.length) return null;

  if (reviewerTeamId) return memberships[0].team_id;
  if (memberships.length === 1) return memberships[0].team_id;
  return 'MULTIPLE_TEAMS';
};

// 팀 평점 요약 조회
router.get('/summary/:teamId', async (req, res) => {
  try {
    const team = await Team.findByPk(req.params.teamId);
    if (!team || !team.is_active) {
      return res.status(404).json({
        success: false,
        message: 'Team not found'
      });
    }

    const stats = await TeamReview.findOne({
      where: { reviewee_team_id: req.params.teamId, is_active: true },
      attributes: [
        [fn('COUNT', col('id')), 'review_count'],
        [fn('AVG', col('manner_score')), 'manner_avg'],
        [fn('AVG', col('skill_score')), 'skill_avg']
      ],
      raw: true
    });

    const recentReviews = await TeamReview.findAll({
      where: { reviewee_team_id: req.params.teamId, is_active: true },
      include: [
        {
          model: Team,
          as: 'reviewerTeam',
          attributes: ['id', 'name']
        },
        {
          model: User,
          as: 'reviewerUser',
          attributes: ['id', 'name', 'profile_image']
        }
      ],
      order: [['created_at', 'DESC']],
      limit: 20
    });

    res.json({
      success: true,
      data: {
        team_id: team.id,
        team_name: team.name,
        review_count: parseInt(stats.review_count || 0, 10),
        manner_avg: stats.manner_avg ? parseFloat(stats.manner_avg).toFixed(2) : null,
        skill_avg: stats.skill_avg ? parseFloat(stats.skill_avg).toFixed(2) : null,
        recent_reviews: recentReviews
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch team review summary',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 특정 매치 리뷰 목록 조회
router.get('/match/:matchId', async (req, res) => {
  try {
    const reviews = await TeamReview.findAll({
      where: {
        match_id: req.params.matchId,
        is_active: true
      },
      include: [
        { model: Team, as: 'reviewerTeam', attributes: ['id', 'name'] },
        { model: Team, as: 'revieweeTeam', attributes: ['id', 'name'] },
        { model: User, as: 'reviewerUser', attributes: ['id', 'name', 'profile_image'] }
      ],
      order: [['created_at', 'DESC']]
    });

    res.json({
      success: true,
      data: reviews
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch match reviews',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 팀 리뷰 등록
router.post('/', auth, async (req, res) => {
  try {
    const {
      match_id,
      reviewer_team_id,
      reviewee_team_id,
      manner_score,
      skill_score,
      comment
    } = req.body;

    if (!match_id || !reviewee_team_id || !manner_score || !skill_score) {
      return res.status(400).json({
        success: false,
        message: 'match_id, reviewee_team_id, manner_score, skill_score are required'
      });
    }

    if (manner_score < 1 || manner_score > 5 || skill_score < 1 || skill_score > 5) {
      return res.status(400).json({
        success: false,
        message: 'Scores must be between 1 and 5'
      });
    }

    const match = await Match.findByPk(match_id);
    if (!match) {
      return res.status(404).json({
        success: false,
        message: 'Match not found'
      });
    }

    if (REVIEWABLE_MATCH_STATUSES.indexOf(match.status) === -1) {
      return res.status(400).json({
        success: false,
        message: 'Reviews are only allowed after match is completed/full'
      });
    }

    const resolvedReviewerTeamId = await resolveReviewerTeam(req.user.id, reviewer_team_id);
    if (!resolvedReviewerTeamId) {
      return res.status(403).json({
        success: false,
        message: 'You must belong to a team to leave a review'
      });
    }

    if (resolvedReviewerTeamId === 'MULTIPLE_TEAMS') {
      return res.status(400).json({
        success: false,
        message: 'reviewer_team_id is required when user belongs to multiple teams'
      });
    }

    if (resolvedReviewerTeamId === reviewee_team_id) {
      return res.status(400).json({
        success: false,
        message: 'Self review is not allowed'
      });
    }

    const revieweeTeam = await Team.findByPk(reviewee_team_id);
    if (!revieweeTeam || !revieweeTeam.is_active) {
      return res.status(404).json({
        success: false,
        message: 'Review target team not found'
      });
    }

    const [review, created] = await TeamReview.findOrCreate({
      where: {
        match_id,
        reviewer_team_id: resolvedReviewerTeamId,
        reviewee_team_id
      },
      defaults: {
        reviewer_user_id: req.user.id,
        manner_score,
        skill_score,
        comment
      }
    });

    if (!created) {
      await review.update({
        reviewer_user_id: req.user.id,
        manner_score,
        skill_score,
        comment
      });
    }

    const fullReview = await TeamReview.findByPk(review.id, {
      include: [
        { model: Team, as: 'reviewerTeam', attributes: ['id', 'name'] },
        { model: Team, as: 'revieweeTeam', attributes: ['id', 'name'] },
        { model: User, as: 'reviewerUser', attributes: ['id', 'name', 'profile_image'] }
      ]
    });

    res.status(created ? 201 : 200).json({
      success: true,
      data: fullReview,
      message: created ? 'Team review created successfully' : 'Team review updated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to create team review',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router;
