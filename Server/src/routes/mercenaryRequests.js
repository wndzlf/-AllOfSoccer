const express = require('express');
const { Op } = require('sequelize');
const { MercenaryRequest, Team, User, MercenaryMatch, UserInterest } = require('../models');
const auth = require('../middleware/auth');

const router = express.Router();

// UUID 형식 검증 헬퍼
const isValidUUID = (id) => /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id);

// UUID 파라미터 검증 미들웨어
const validateId = (req, res, next) => {
  if (req.params.id && !isValidUUID(req.params.id)) {
    return res.status(400).json({
      success: false,
      message: 'Invalid ID format'
    });
  }
  next();
};

const REGION_KEYWORDS = {
  서울북부: ['노원', '도봉', '강북', '성북', '중랑', '동대문', '광진', '종로', '은평', '서대문', '마포'],
  서울남부: ['강남', '서초', '송파', '강동', '강서', '양천', '영등포', '구로', '금천', '동작', '관악', '용산'],
  경기북부: ['고양', '파주', '의정부', '양주', '동두천', '연천', '포천', '가평', '남양주', '구리'],
  경기남부: ['성남', '수원', '용인', '화성', '평택', '안산', '안양', '과천', '군포', '의왕', '시흥', '광명', '오산', '이천', '안성', '하남', '광주'],
  인천부천: ['인천', '부천', '송도', '계양', '부평', '남동', '연수', '미추홀'],
  기타지역: ['천안', '아산', '청주', '대전', '대구', '부산', '울산', '광주', '전주', '제주', '강원', '충북', '충남', '전북', '전남', '경북', '경남']
};

const normalizeRegionKey = (rawLocation = '') => rawLocation.replace(/\s+/g, '').replace('/', '');

const normalizeBoolean = (value) => {
  if (value === undefined || value === null) return undefined;
  if (typeof value === 'boolean') return value;
  if (typeof value === 'string') {
    const normalized = value.trim().toLowerCase();
    if (normalized === 'true') return true;
    if (normalized === 'false') return false;
  }
  return Boolean(value);
};

const buildLocationWhere = (location) => {
  const normalized = normalizeRegionKey(location);
  const keywords = REGION_KEYWORDS[normalized];

  if (keywords && keywords.length > 0) {
    return {
      [Op.or]: [
        ...keywords.map((keyword) => ({ location: { [Op.iLike]: `%${keyword}%` } })),
        ...keywords.map((keyword) => ({ address: { [Op.iLike]: `%${keyword}%` } }))
      ]
    };
  }

  return {
    [Op.or]: [
      { location: { [Op.iLike]: `%${location}%` } },
      { address: { [Op.iLike]: `%${location}%` } }
    ]
  };
};

// 용병 모집 목록 조회 (필터링, 정렬, 페이징)
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
      status,
      sort_by = 'created_at',
      sort_order = 'DESC'
    } = req.query;

    const offset = (page - 1) * limit;
    const where = { is_active: true };

    // 필터링 조건들
    if (location) {
      Object.assign(where, buildLocationWhere(location));
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
      // Range overlap: [request_min, request_max] overlaps [filter_min, filter_max]
      // if request_max >= filter_min AND request_min <= filter_max
      const conditions = [];
      if (age_min) {
        conditions.push({ age_range_max: { [Op.gte]: parseInt(age_min) } });
      }
      if (age_max) {
        conditions.push({ age_range_min: { [Op.lte]: parseInt(age_max) } });
      }
      if (conditions.length > 0) {
        where[Op.and] = conditions;
      }
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

if (process.env.NODE_ENV === 'development') {
  router.post('/seed', async (req, res) => {
    try {
      console.log('🌱 용병 모집 목데이터 생성 시작...');
      const buildFutureDate = (daysFromNow, hour = 20) => {
        const date = new Date();
        date.setDate(date.getDate() + daysFromNow);
        date.setHours(hour, 0, 0, 0);
        return date.toISOString();
      };

      await User.bulkCreate([
        {
          id: '550e8400-e29b-41d4-a716-446655440001',
          name: '김팀장',
          email: 'captain1@example.com',
          phone: '010-1234-5678',
          profile_image: null
        },
        {
          id: '550e8400-e29b-41d4-a716-446655440002',
          name: '박팀장',
          email: 'captain2@example.com',
          phone: '010-2345-6789',
          profile_image: null
        },
        {
          id: '550e8400-e29b-41d4-a716-446655440003',
          name: '이팀장',
          email: 'captain3@example.com',
          phone: '010-3456-7890',
          profile_image: null
        }
      ], { ignoreDuplicates: true });

      await Team.bulkCreate([
        {
          id: '660e8400-e29b-41d4-a716-446655440001',
          name: 'FC 캘란',
          captain_id: '550e8400-e29b-41d4-a716-446655440001',
          is_active: true
        },
        {
          id: '660e8400-e29b-41d4-a716-446655440002',
          name: 'FC 바르셀로나',
          captain_id: '550e8400-e29b-41d4-a716-446655440002',
          is_active: true
        },
        {
          id: '660e8400-e29b-41d4-a716-446655440003',
          name: 'FC 뮌헨',
          captain_id: '550e8400-e29b-41d4-a716-446655440003',
          is_active: true
        }
      ], { ignoreDuplicates: true });

      const requestSeedData = [
        {
          id: '880e8400-e29b-41d4-a716-446655440001',
          team_id: '660e8400-e29b-41d4-a716-446655440001',
          title: '서울북부 주말 매치 용병 2명 구합니다',
          description: '태릉 근처 매치, 매너 좋은 분 환영',
          date: buildFutureDate(2, 19),
          location: '태릉중학교',
          address: '서울시 노원구 태릉로 456',
          fee: 15000,
          mercenary_count: 2,
          positions_needed: { MF: 1, FW: 1 },
          skill_level_min: 'beginner',
          skill_level_max: 'advanced',
          has_former_player: false,
          match_type: '11v11',
          gender_type: 'male',
          shoes_requirement: 'soccer',
          status: 'recruiting',
          current_applicants: 1,
          is_active: true
        },
        {
          id: '880e8400-e29b-41d4-a716-446655440002',
          team_id: '660e8400-e29b-41d4-a716-446655440002',
          title: '경기남부 평일 풋살 용병 모집',
          description: '분당 풋살장, 빠른 템포 경기',
          date: buildFutureDate(4, 21),
          location: '분당 정자동 풋살장',
          address: '경기도 성남시 분당구 정자동',
          fee: 10000,
          mercenary_count: 3,
          positions_needed: { DF: 1, MF: 1, FW: 1 },
          skill_level_min: 'intermediate',
          skill_level_max: 'expert',
          has_former_player: true,
          match_type: '6v6',
          gender_type: 'mixed',
          shoes_requirement: 'futsal',
          status: 'recruiting',
          current_applicants: 0,
          is_active: true
        },
        {
          id: '880e8400-e29b-41d4-a716-446655440003',
          team_id: '660e8400-e29b-41d4-a716-446655440003',
          title: '인천 주말 경기 용병 모집 마감',
          description: '모집 완료된 샘플 데이터',
          date: buildFutureDate(6, 18),
          location: '인천 송도 국제도시 구장',
          address: '인천 연수구 송도동',
          fee: 12000,
          mercenary_count: 2,
          positions_needed: { GK: 1, DF: 1 },
          skill_level_min: 'beginner',
          skill_level_max: 'intermediate',
          has_former_player: false,
          match_type: '11v11',
          gender_type: 'mixed',
          shoes_requirement: 'any',
          status: 'closed',
          current_applicants: 2,
          is_active: true
        }
      ];

      for (const requestData of requestSeedData) {
        await MercenaryRequest.upsert(requestData);
      }

      res.json({
        success: true,
        message: '용병 모집 목데이터 생성 완료',
        data: {
          users: 3,
          teams: 3,
          mercenary_requests: requestSeedData.length
        }
      });
    } catch (error) {
      console.error('❌ 용병 모집 목데이터 생성 실패:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create mercenary request seed data',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  });
}

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
      match_type,
      gender_type,
      shoes_requirement,
      age_range_min,
      age_range_max,
      skill_level_min,
      skill_level_max,
      has_former_player,
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
      match_type: match_type || '11v11',
      gender_type: gender_type || 'mixed',
      shoes_requirement: shoes_requirement || 'any',
      age_range_min,
      age_range_max,
      skill_level_min: skill_level_min || 'beginner',
      skill_level_max: skill_level_max || 'expert',
      has_former_player: normalizeBoolean(has_former_player) ?? false,
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 용병 모집 상세 조회
router.get('/:id', validateId, async (req, res) => {
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

    // 현재 로그인한 사용자의 관심 여부 확인
    let is_interested_by_user = false;
    if (req.headers.authorization) {
      try {
        const token = req.headers.authorization.replace('Bearer ', '');
        const decoded = require('jsonwebtoken').verify(token, process.env.JWT_SECRET || 'test-secret');
        const userId = decoded.userId || decoded.id;
        if (userId) {
          const interest = await UserInterest.findOne({
            where: {
              user_id: userId,
              mercenary_request_id: req.params.id,
              interest_type: 'mercenary'
            }
          });
          is_interested_by_user = !!interest;
        }
      } catch (e) {
        // Token validation failed, set to false
        is_interested_by_user = false;
      }
    }

    const responseData = {
      ...request.toJSON(),
      team_introduction: request.team ? request.team.introduction : null,
      team_captain_name: request.team && request.team.captain ? request.team.captain.name : null,
      team_captain_image: request.team && request.team.captain ? request.team.captain.profile_image : null,
      is_interested_by_user
    };

    res.json({
      success: true,
      data: responseData
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch mercenary request',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 용병 모집 수정
router.put('/:id', validateId, auth, async (req, res) => {
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

    // 허용된 필드만 업데이트 (mass assignment 방지)
    const allowedFields = [
      'title', 'description', 'date', 'location', 'address',
      'latitude', 'longitude', 'fee', 'mercenary_count', 'positions_needed',
      'match_type', 'gender_type', 'shoes_requirement',
      'age_range_min', 'age_range_max', 'skill_level_min', 'skill_level_max',
      'has_former_player',
      'status'
    ];
    const updateData = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        if (field === 'has_former_player') {
          const normalized = normalizeBoolean(req.body[field]);
          if (normalized !== undefined) {
            updateData[field] = normalized;
          }
        } else {
          updateData[field] = req.body[field];
        }
      }
    }
    await request.update(updateData);

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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 용병 모집 삭제
router.delete('/:id', validateId, auth, async (req, res) => {
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 용병 지원하기
router.post('/:id/apply', validateId, auth, async (req, res) => {
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 용병 지원 취소
router.delete('/:id/apply', validateId, auth, async (req, res) => {
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 용병 지원자 목록 조회
router.get('/:id/applicants', validateId, auth, async (req, res) => {
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 지원자 승인
router.post('/:id/accept/:userId', validateId, auth, async (req, res) => {
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 용병 모집 관심 추가
router.post('/:id/like', validateId, auth, async (req, res) => {
  try {
    const request = await MercenaryRequest.findByPk(req.params.id);

    if (!request || !request.is_active) {
      return res.status(404).json({
        success: false,
        message: 'Mercenary request not found'
      });
    }

    // 이미 관심 표시했는지 확인
    const existingInterest = await UserInterest.findOne({
      where: {
        user_id: req.user.id,
        mercenary_request_id: req.params.id,
        interest_type: 'mercenary'
      }
    });

    if (existingInterest) {
      return res.status(400).json({
        success: false,
        message: 'You have already marked this mercenary request as interested'
      });
    }

    const interest = await UserInterest.create({
      user_id: req.user.id,
      mercenary_request_id: req.params.id,
      interest_type: 'mercenary'
    });

    res.status(201).json({
      success: true,
      data: interest,
      message: 'Mercenary request marked as interested'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to mark mercenary request as interested',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 용병 모집 관심 제거
router.delete('/:id/like', validateId, auth, async (req, res) => {
  try {
    const interest = await UserInterest.findOne({
      where: {
        user_id: req.user.id,
        mercenary_request_id: req.params.id,
        interest_type: 'mercenary'
      }
    });

    if (!interest) {
      return res.status(404).json({
        success: false,
        message: 'Interest not found'
      });
    }

    await interest.destroy();

    res.json({
      success: true,
      message: 'Interest removed successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to remove interest',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router;
