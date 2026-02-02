const express = require('express');
const { Op } = require('sequelize');
const { MercenaryRequest, Team, User, MercenaryMatch } = require('../models');
const auth = require('../middleware/auth');

const router = express.Router();

// 용병 모집 목록 조회 (필터링, 정렬, 페이징)
router.get('/', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      location,
      date,
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

    const { count, rows: requests } = await MercenaryRequest.findAndCountAll({
      where,
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
      ],
      order: [[sort_by, sort_order]],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    res.json({
      success: true,
      data: requests,
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
      message: 'Failed to fetch mercenary requests',
      error: error.message
    });
  }
});

// 용병 모집 등록
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
      mercenary_count,
      positions_needed,
      skill_level_min,
      skill_level_max,
      team_id,
      team_name
    } = req.body;

    // 필수 필드 검증
    if (!title || !date || !location || !mercenary_count) {
      return res.status(400).json({
        success: false,
        message: 'Title, date, location, and mercenary_count are required'
      });
    }

    let finalTeamId = team_id;

    // team_id가 없으면 자동으로 팀 생성
    if (!team_id) {
      if (!team_name) {
        return res.status(400).json({
          success: false,
          message: 'team_name is required when team_id is not provided'
        });
      }

      const newTeam = await Team.create({
        name: team_name,
        captain_id: req.user.id,
        is_active: true
      });

      finalTeamId = newTeam.id;
    } else {
      // 팀 소유권 확인
      const team = await Team.findOne({
        where: { id: team_id, captain_id: req.user.id }
      });

      if (!team) {
        return res.status(403).json({
          success: false,
          message: 'You can only create mercenary requests for your own team'
        });
      }
    }

    const request = await MercenaryRequest.create({
      team_id: finalTeamId,
      title,
      description,
      date: new Date(date),
      location,
      address,
      latitude,
      longitude,
      fee: fee || 0,
      mercenary_count,
      positions_needed: positions_needed || {},
      skill_level_min: skill_level_min || 'beginner',
      skill_level_max: skill_level_max || 'expert',
      status: 'recruiting',
      current_applicants: 0
    });

    const createdRequest = await MercenaryRequest.findByPk(request.id, {
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
      data: createdRequest,
      message: 'Mercenary request created successfully'
    });
  } catch (error) {
    console.error('용병 모집 등록 에러:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create mercenary request',
      error: error.message
    });
  }
});

// 용병 모집 상세 조회
router.get('/:id', async (req, res) => {
  try {
    const request = await MercenaryRequest.findByPk(req.params.id, {
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
          model: MercenaryMatch,
          include: [
            {
              model: User,
              attributes: ['id', 'name', 'profile_image']
            }
          ]
        }
      ]
    });

    if (!request) {
      return res.status(404).json({
        success: false,
        message: 'Mercenary request not found'
      });
    }

    res.json({
      success: true,
      data: request
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch mercenary request',
      error: error.message
    });
  }
});

// 용병 모집 수정
router.put('/:id', auth, async (req, res) => {
  try {
    const request = await MercenaryRequest.findByPk(req.params.id, {
      include: [
        {
          model: Team,
          as: 'team'
        }
      ]
    });

    if (!request) {
      return res.status(404).json({
        success: false,
        message: 'Mercenary request not found'
      });
    }

    // 팀 소유권 확인
    if (request.team.captain_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'You can only update your own mercenary requests'
      });
    }

    // 모집이 종료된 경우 수정 불가
    if (request.status === 'closed') {
      return res.status(400).json({
        success: false,
        message: 'Cannot update closed mercenary request'
      });
    }

    await request.update(req.body);

    const updatedRequest = await MercenaryRequest.findByPk(req.params.id, {
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
      data: updatedRequest,
      message: 'Mercenary request updated successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to update mercenary request',
      error: error.message
    });
  }
});

// 용병 모집 삭제
router.delete('/:id', auth, async (req, res) => {
  try {
    const request = await MercenaryRequest.findByPk(req.params.id, {
      include: [
        {
          model: Team,
          as: 'team'
        }
      ]
    });

    if (!request) {
      return res.status(404).json({
        success: false,
        message: 'Mercenary request not found'
      });
    }

    // 팀 소유권 확인
    if (request.team.captain_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own mercenary requests'
      });
    }

    await request.update({ is_active: false });

    res.json({
      success: true,
      message: 'Mercenary request deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to delete mercenary request',
      error: error.message
    });
  }
});

// 용병 지원하기
router.post('/:id/apply', auth, async (req, res) => {
  try {
    const request = await MercenaryRequest.findByPk(req.params.id);

    if (!request || !request.is_active) {
      return res.status(404).json({
        success: false,
        message: 'Mercenary request not found'
      });
    }

    if (request.status !== 'recruiting') {
      return res.status(400).json({
        success: false,
        message: 'Mercenary request is not accepting applications'
      });
    }

    if (request.current_applicants >= request.mercenary_count) {
      return res.status(400).json({
        success: false,
        message: 'Mercenary request is full'
      });
    }

    // 이미 지원했는지 확인
    const existingMatch = await MercenaryMatch.findOne({
      where: {
        mercenary_request_id: req.params.id,
        user_id: req.user.id
      }
    });

    if (existingMatch) {
      return res.status(400).json({
        success: false,
        message: 'You have already applied for this mercenary request'
      });
    }

    const match = await MercenaryMatch.create({
      mercenary_request_id: req.params.id,
      user_id: req.user.id,
      status: 'pending'
    });

    // 지원자 수 증가
    await request.increment('current_applicants');

    res.status(201).json({
      success: true,
      data: match,
      message: 'Application submitted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to apply for mercenary request',
      error: error.message
    });
  }
});

// 용병 지원 취소
router.delete('/:id/apply', auth, async (req, res) => {
  try {
    const match = await MercenaryMatch.findOne({
      where: {
        mercenary_request_id: req.params.id,
        user_id: req.user.id
      },
      include: [
        {
          model: MercenaryRequest,
          as: 'mercenaryRequest'
        }
      ]
    });

    if (!match) {
      return res.status(404).json({
        success: false,
        message: 'Application not found'
      });
    }

    // pending 상태만 취소 가능
    if (match.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Cannot cancel already accepted or rejected application'
      });
    }

    await match.destroy();

    // 지원자 수 감소
    await match.mercenaryRequest.decrement('current_applicants');

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

// 용병 지원자 목록 조회
router.get('/:id/applicants', auth, async (req, res) => {
  try {
    const request = await MercenaryRequest.findByPk(req.params.id, {
      include: [
        {
          model: Team,
          as: 'team'
        }
      ]
    });

    if (!request) {
      return res.status(404).json({
        success: false,
        message: 'Mercenary request not found'
      });
    }

    // 팀 소유권 확인
    if (request.team.captain_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'You can only view applicants for your own mercenary requests'
      });
    }

    const applicants = await MercenaryMatch.findAll({
      where: { mercenary_request_id: req.params.id },
      include: [
        {
          model: User,
          attributes: ['id', 'name', 'profile_image', 'phone']
        }
      ],
      order: [['applied_at', 'ASC']]
    });

    res.json({
      success: true,
      data: applicants
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch applicants',
      error: error.message
    });
  }
});

// 지원자 승인
router.post('/:id/accept/:userId', auth, async (req, res) => {
  try {
    const match = await MercenaryMatch.findOne({
      where: {
        mercenary_request_id: req.params.id,
        user_id: req.params.userId
      },
      include: [
        {
          model: MercenaryRequest,
          as: 'mercenaryRequest',
          include: [
            {
              model: Team,
              as: 'team'
            }
          ]
        }
      ]
    });

    if (!match) {
      return res.status(404).json({
        success: false,
        message: 'Application not found'
      });
    }

    // 팀 소유권 확인
    if (match.mercenaryRequest.team.captain_id !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'You can only accept applications for your own mercenary requests'
      });
    }

    await match.update({
      status: 'accepted',
      accepted_at: new Date()
    });

    res.json({
      success: true,
      data: match,
      message: 'Application accepted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to accept application',
      error: error.message
    });
  }
});

// 내가 올린 용병 모집 목록 조회
router.get('/my/created', auth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    // 내가 캡틴인 팀들 찾기
    const myTeams = await Team.findAll({
      where: { captain_id: req.user.id },
      attributes: ['id']
    });

    const teamIds = myTeams.map(team => team.id);

    // 내 팀으로 올린 용병 모집 조회
    const { count, rows: requests } = await MercenaryRequest.findAndCountAll({
      where: {
        team_id: teamIds,
        is_active: true
      },
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
      ],
      order: [['created_at', 'DESC']],
      limit,
      offset
    });

    const totalPages = Math.ceil(count / limit);

    res.json({
      success: true,
      data: requests,
      pagination: {
        page,
        limit,
        total: count,
        total_pages: totalPages
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch my mercenary requests',
      error: error.message
    });
  }
});

// 내가 지원한 용병 모집 목록 조회
router.get('/my/applied', auth, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const { count, rows: matches } = await MercenaryMatch.findAndCountAll({
      where: { user_id: req.user.id },
      include: [
        {
          model: MercenaryRequest,
          as: 'mercenaryRequest',
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
        }
      ],
      order: [['applied_at', 'DESC']],
      limit,
      offset
    });

    const totalPages = Math.ceil(count / limit);

    res.json({
      success: true,
      data: matches,
      pagination: {
        page,
        limit,
        total: count,
        total_pages: totalPages
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch my applied mercenary requests',
      error: error.message
    });
  }
});

module.exports = router;
