const express = require('express');
const { Team, User, TeamMember, Comment } = require('../models');
const auth = require('../middleware/auth');
const { Op } = require('sequelize');

const router = express.Router();

// 팀 목록 조회
router.get('/', auth, async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      search,
      skill_level,
      age_min,
      age_max
    } = req.query;

    const offset = (page - 1) * limit;
    const where = { is_active: true };

    if (search) {
      where.name = { [Op.iLike]: `%${search}%` };
    }

    if (skill_level) {
      where.skill_level = skill_level;
    }

    if (age_min || age_max) {
      where.age_range_min = {};
      where.age_range_max = {};
      if (age_min) where.age_range_min[Op.gte] = parseInt(age_min);
      if (age_max) where.age_range_max[Op.lte] = parseInt(age_max);
    }

    const { count, rows: teams } = await Team.findAndCountAll({
      where,
      include: [
        {
          model: User,
          as: 'captain',
          attributes: ['id', 'name', 'profile_image']
        },
        {
          model: TeamMember,
          include: [
            {
              model: User,
              attributes: ['id', 'name', 'profile_image']
            }
          ]
        }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    res.json({
      success: true,
      data: teams,
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
      message: 'Failed to fetch teams',
      error: error.message
    });
  }
});

// 팀 생성
router.post('/', auth, async (req, res) => {
  try {
    const {
      name,
      description,
      logo,
      age_range_min,
      age_range_max,
      skill_level,
      introduction
    } = req.body;

    if (!name) {
      return res.status(400).json({
        success: false,
        message: 'Team name is required'
      });
    }

    const team = await Team.create({
      name,
      description,
      logo,
      captain_id: req.user.id,
      age_range_min,
      age_range_max,
      skill_level,
      introduction
    });

    // 팀장을 팀 멤버로 추가
    await TeamMember.create({
      team_id: team.id,
      user_id: req.user.id,
      role: 'captain'
    });

    // 팀 소개 코멘트가 있다면 저장
    if (introduction) {
      await Comment.create({
        content: introduction,
        user_id: req.user.id,
        team_id: team.id,
        type: 'team_introduction',
        order_index: 1
      });
    }

    const createdTeam = await Team.findByPk(team.id, {
      include: [
        {
          model: User,
          as: 'captain',
          attributes: ['id', 'name', 'profile_image']
        },
        {
          model: TeamMember,
          include: [
            {
              model: User,
              attributes: ['id', 'name', 'profile_image']
            }
          ]
        }
      ]
    });

    res.status(201).json({
      success: true,
      data: createdTeam,
      message: 'Team created successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to create team',
      error: error.message
    });
  }
});

// 팀 상세 조회
router.get('/:id', auth, async (req, res) => {
  try {
    const team = await Team.findByPk(req.params.id, {
      include: [
        {
          model: User,
          as: 'captain',
          attributes: ['id', 'name', 'profile_image']
        },
        {
          model: TeamMember,
          include: [
            {
              model: User,
              attributes: ['id', 'name', 'profile_image']
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

    if (!team) {
      return res.status(404).json({
        success: false,
        message: 'Team not found'
      });
    }

    res.json({
      success: true,
      data: team
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch team',
      error: error.message
    });
  }
});

// 팀 수정
router.put('/:id', auth, async (req, res) => {
  try {
    const team = await Team.findByPk(req.params.id);

    if (!team) {
      return res.status(404).json({
        success: false,
        message: 'Team not found'
      });
    }

    if (team.captain_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Only team captain can update team information'
      });
    }

    await team.update(req.body);

    const updatedTeam = await Team.findByPk(req.params.id, {
      include: [
        {
          model: User,
          as: 'captain',
          attributes: ['id', 'name', 'profile_image']
        }
      ]
    });

    res.json({
      success: true,
      data: updatedTeam,
      message: 'Team updated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update team',
      error: error.message
    });
  }
});

// 팀 멤버 추가
router.post('/:id/members', auth, async (req, res) => {
  try {
    const { user_id, role = 'member' } = req.body;

    const team = await Team.findByPk(req.params.id);

    if (!team) {
      return res.status(404).json({
        success: false,
        message: 'Team not found'
      });
    }

    if (team.captain_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Only team captain can add members'
      });
    }

    // 이미 멤버인지 확인
    const existingMember = await TeamMember.findOne({
      where: { team_id: req.params.id, user_id }
    });

    if (existingMember) {
      return res.status(400).json({
        success: false,
        message: 'User is already a member of this team'
      });
    }

    const member = await TeamMember.create({
      team_id: req.params.id,
      user_id,
      role
    });

    const createdMember = await TeamMember.findByPk(member.id, {
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'profile_image']
        }
      ]
    });

    res.status(201).json({
      success: true,
      data: createdMember,
      message: 'Member added successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to add member',
      error: error.message
    });
  }
});

// 팀 자가 가입 (팀원이 직접 "내가 이 팀원" 등록)
router.post('/:id/join', auth, async (req, res) => {
  try {
    const team = await Team.findByPk(req.params.id);

    if (!team || !team.is_active) {
      return res.status(404).json({
        success: false,
        message: 'Team not found'
      });
    }

    const existingMember = await TeamMember.findOne({
      where: {
        team_id: req.params.id,
        user_id: req.user.id
      }
    });

    if (existingMember && existingMember.is_active) {
      return res.status(400).json({
        success: false,
        message: 'You are already an active member of this team'
      });
    }

    if (existingMember && !existingMember.is_active) {
      await existingMember.update({
        is_active: true,
        role: existingMember.role || 'member',
        joined_at: new Date()
      });

      return res.json({
        success: true,
        data: existingMember,
        message: 'Joined team successfully'
      });
    }

    const member = await TeamMember.create({
      team_id: req.params.id,
      user_id: req.user.id,
      role: 'member'
    });

    res.status(201).json({
      success: true,
      data: member,
      message: 'Joined team successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to join team',
      error: error.message
    });
  }
});

// 팀 멤버 제거
router.delete('/:id/members/:userId', auth, async (req, res) => {
  try {
    const team = await Team.findByPk(req.params.id);

    if (!team) {
      return res.status(404).json({
        success: false,
        message: 'Team not found'
      });
    }

    if (team.captain_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Only team captain can remove members'
      });
    }

    const member = await TeamMember.findOne({
      where: {
        team_id: req.params.id,
        user_id: req.params.userId
      }
    });

    if (!member) {
      return res.status(404).json({
        success: false,
        message: 'Member not found'
      });
    }

    if (member.role === 'captain') {
      return res.status(400).json({
        success: false,
        message: 'Cannot remove team captain'
      });
    }

    await member.update({ is_active: false });

    res.json({
      success: true,
      message: 'Member removed successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to remove member',
      error: error.message
    });
  }
});

// 팀 자가 탈퇴
router.delete('/:id/leave', auth, async (req, res) => {
  try {
    const team = await Team.findByPk(req.params.id);

    if (!team || !team.is_active) {
      return res.status(404).json({
        success: false,
        message: 'Team not found'
      });
    }

    if (team.captain_id === req.user.id) {
      return res.status(400).json({
        success: false,
        message: 'Captain cannot leave the team directly. Transfer captain role first.'
      });
    }

    const member = await TeamMember.findOne({
      where: {
        team_id: req.params.id,
        user_id: req.user.id,
        is_active: true
      }
    });

    if (!member) {
      return res.status(404).json({
        success: false,
        message: 'Active team membership not found'
      });
    }

    await member.update({ is_active: false });

    res.json({
      success: true,
      message: 'Left team successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to leave team',
      error: error.message
    });
  }
});

// 내가 속한 팀 목록
router.get('/my/teams', auth, async (req, res) => {
  try {
    const teams = await Team.findAll({
      include: [
        {
          model: TeamMember,
          where: { user_id: req.user.id, is_active: true },
          include: [
            {
              model: User,
              attributes: ['id', 'name', 'profile_image']
            }
          ]
        },
        {
          model: User,
          as: 'captain',
          attributes: ['id', 'name', 'profile_image']
        }
      ],
      where: { is_active: true }
    });

    res.json({
      success: true,
      data: teams
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch my teams',
      error: error.message
    });
  }
});

module.exports = router; 
