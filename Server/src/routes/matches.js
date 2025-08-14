const express = require('express');
const { Op } = require('sequelize');
const { Match, Team, User, MatchParticipant, Comment } = require('../models');
const auth = require('../middleware/auth');

const router = express.Router();

// 매칭 목록 조회 (필터링, 정렬, 페이징)
router.get('/', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      location,
      date,
      match_type,
      gender_type,
      shoes_requirement,
      age_min,
      age_max,
      skill_level,
      fee_min,
      fee_max,
      status = 'recruiting',
      sort_by = 'created_at',
      sort_order = 'DESC'
    } = req.query;

    const offset = (page - 1) * limit;
    const where = { is_active: true };

    // 필터링 조건들
    if (location) {
      where.location = { [Op.iLike]: `%${location}%` };
    }

    if (date) {
      where.date = { [Op.gte]: new Date(date) };
    }

    if (match_type) {
      where.match_type = match_type;
    }

    if (gender_type) {
      where.gender_type = gender_type;
    }

    if (shoes_requirement) {
      where.shoes_requirement = shoes_requirement;
    }

    if (age_min || age_max) {
      where.age_range_min = {};
      where.age_range_max = {};
      if (age_min) where.age_range_min[Op.gte] = parseInt(age_min);
      if (age_max) where.age_range_max[Op.lte] = parseInt(age_max);
    }

    if (skill_level) {
      where.skill_level_min = { [Op.lte]: skill_level };
      where.skill_level_max = { [Op.gte]: skill_level };
    }

    if (fee_min || fee_max) {
      where.fee = {};
      if (fee_min) where.fee[Op.gte] = parseInt(fee_min);
      if (fee_max) where.fee[Op.lte] = parseInt(fee_max);
    }

    if (status) {
      where.status = status;
    }

    const { count, rows: matches } = await Match.findAndCountAll({
      where,
      include: [
        {
          model: Team,
          include: [
            {
              model: User,
              as: 'captain',
              attributes: ['id', 'name', 'profile_image']
            }
          ]
        }
      ],
      order: [[sort_by, sort_order]],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    res.json({
      success: true,
      data: matches,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: count,
        total_pages: Math.ceil(count / limit)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch matches',
      error: error.message
    });
  }
});

// 매칭 생성 (iOS FirstTeamRecruitmentViewController + SecondTeamRecruitmentViewController 기반)
router.post('/', auth, async (req, res) => {
  try {
    const {
      title,
      description,
      date,
      location,
      address,
      latitude,
      longitude,
      fee,
      max_participants,
      match_type,
      gender_type,
      shoes_requirement,
      age_range_min,
      age_range_max,
      skill_level_min,
      skill_level_max,
      team_introduction,
      team_id
    } = req.body;

    // 필수 필드 검증
    if (!title || !date || !location || !team_id) {
      return res.status(400).json({
        success: false,
        message: 'Title, date, location, and team_id are required'
      });
    }

    // 팀 소유권 확인
    const team = await Team.findOne({
      where: { id: team_id, captain_id: req.user.id }
    });

    if (!team) {
      return res.status(403).json({
        success: false,
        message: 'You can only create matches for your own team'
      });
    }

    const match = await Match.create({
      title,
      description,
      date: new Date(date),
      location,
      address,
      latitude,
      longitude,
      fee: fee || 0,
      max_participants: max_participants || (match_type === '6v6' ? 12 : 22),
      match_type: match_type || '11v11',
      gender_type: gender_type || 'mixed',
      shoes_requirement: shoes_requirement || 'any',
      age_range_min,
      age_range_max,
      skill_level_min,
      skill_level_max,
      team_introduction,
      team_id,
      status: 'recruiting'
    });

    // 팀 소개 코멘트가 있다면 저장
    if (team_introduction) {
      await Comment.create({
        content: team_introduction,
        user_id: req.user.id,
        team_id: team_id,
        type: 'team_introduction',
        order_index: 1
      });
    }

    const createdMatch = await Match.findByPk(match.id, {
      include: [
        {
          model: Team,
          as: 'team',
          include: [
            {
              model: User,
              as: 'captain',
              attributes: ['id', 'name', 'profile_image']
            }
          ]
        }
      ]
    });

    res.status(201).json({
      success: true,
      data: createdMatch,
      message: 'Match created successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to create match',
      error: error.message
    });
  }
});

// 매칭 상세 조회
router.get('/:id', auth, async (req, res) => {
  try {
    const match = await Match.findByPk(req.params.id, {
      include: [
        {
          model: Team,
          as: 'team',
          include: [
            {
              model: User,
              as: 'captain',
              attributes: ['id', 'name', 'profile_image']
            }
          ]
        },
        {
          model: MatchParticipant,
          include: [
            {
              model: User,
              attributes: ['id', 'name', 'profile_image']
            },
            {
              model: Team,
              attributes: ['id', 'name', 'logo']
            }
          ]
        },
        {
          model: Comment,
          where: { type: 'team_introduction' },
          required: false,
          include: [
            {
              model: User,
              attributes: ['id', 'name']
            }
          ],
          order: [['order_index', 'ASC']]
        }
      ]
    });

    if (!match) {
      return res.status(404).json({
        success: false,
        message: 'Match not found'
      });
    }

    res.json({
      success: true,
      data: match
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch match',
      error: error.message
    });
  }
});

// 매칭 수정
router.put('/:id', auth, async (req, res) => {
  try {
    const match = await Match.findByPk(req.params.id, {
      include: [
        {
          model: Team,
          as: 'team'
        }
      ]
    });

    if (!match) {
      return res.status(404).json({
        success: false,
        message: 'Match not found'
      });
    }

    // 팀 소유권 확인
    if (match.team.captain_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'You can only update matches for your own team'
      });
    }

    // 매칭이 이미 완료되었거나 취소된 경우 수정 불가
    if (match.status === 'completed' || match.status === 'cancelled') {
      return res.status(400).json({
        success: false,
        message: 'Cannot update completed or cancelled match'
      });
    }

    await match.update(req.body);

    const updatedMatch = await Match.findByPk(req.params.id, {
      include: [
        {
          model: Team,
          as: 'team',
          include: [
            {
              model: User,
              as: 'captain',
              attributes: ['id', 'name', 'profile_image']
            }
          ]
        }
      ]
    });

    res.json({
      success: true,
      data: updatedMatch,
      message: 'Match updated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update match',
      error: error.message
    });
  }
});

// 매칭 삭제
router.delete('/:id', auth, async (req, res) => {
  try {
    const match = await Match.findByPk(req.params.id, {
      include: [
        {
          model: Team,
          as: 'team'
        }
      ]
    });

    if (!match) {
      return res.status(404).json({
        success: false,
        message: 'Match not found'
      });
    }

    // 팀 소유권 확인
    if (match.team.captain_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete matches for your own team'
      });
    }

    await match.update({ is_active: false });

    res.json({
      success: true,
      message: 'Match deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to delete match',
      error: error.message
    });
  }
});

// 참가 신청
router.post('/:id/apply', auth, async (req, res) => {
  try {
    const match = await Match.findByPk(req.params.id);

    if (!match || !match.is_active) {
      return res.status(404).json({
        success: false,
        message: 'Match not found'
      });
    }

    if (match.status !== 'recruiting') {
      return res.status(400).json({
        success: false,
        message: 'Match is not accepting applications'
      });
    }

    if (match.current_participants >= match.max_participants) {
      return res.status(400).json({
        success: false,
        message: 'Match is full'
      });
    }

    // 이미 신청했는지 확인
    const existingApplication = await MatchParticipant.findOne({
      where: {
        match_id: req.params.id,
        user_id: req.user.id
      }
    });

    if (existingApplication) {
      return res.status(400).json({
        success: false,
        message: 'You have already applied for this match'
      });
    }

    const participant = await MatchParticipant.create({
      match_id: req.params.id,
      user_id: req.user.id,
      status: 'pending'
    });

    // 참가자 수 증가
    await match.increment('current_participants');

    res.status(201).json({
      success: true,
      data: participant,
      message: 'Application submitted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to apply for match',
      error: error.message
    });
  }
});

// 참가 취소
router.delete('/:id/apply', auth, async (req, res) => {
  try {
    const participant = await MatchParticipant.findOne({
      where: {
        match_id: req.params.id,
        user_id: req.user.id
      },
      include: [
        {
          model: Match,
          as: 'match'
        }
      ]
    });

    if (!participant) {
      return res.status(404).json({
        success: false,
        message: 'Application not found'
      });
    }

    await participant.update({ status: 'cancelled' });

    // 참가자 수 감소
    await participant.match.decrement('current_participants');

    res.json({
      success: true,
      message: 'Application cancelled successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to cancel application',
      error: error.message
    });
  }
});

// 참가자 목록 조회
router.get('/:id/participants', auth, async (req, res) => {
  try {
    const participants = await MatchParticipant.findAll({
      where: { match_id: req.params.id },
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'profile_image']
        },
        {
          model: Team,
          attributes: ['id', 'name', 'logo']
        }
      ],
      order: [['applied_at', 'ASC']]
    });

    res.json({
      success: true,
      data: participants
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch participants',
      error: error.message
    });
  }
});

module.exports = router; 