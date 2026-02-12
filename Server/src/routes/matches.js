const express = require('express');
const { Op } = require('sequelize');
const { Match, Team, User, MatchParticipant, Comment, UserInterest } = require('../models');
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
      // Range overlap: [match_min, match_max] overlaps [filter_min, filter_max]
      // if match_max >= filter_min AND match_min <= filter_max
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

    const { count, rows: matches } = await Match.findAndCountAll({
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 목데이터 생성 API는 개발 환경에서만 활성화 (NODE_ENV=development)
// 프로덕션에서는 비활성화됨
if (process.env.NODE_ENV === 'development') {
  router.post('/seed', async (req, res) => {
    try {
      console.log('🌱 매칭 목데이터 생성 시작...');
      const buildFutureDate = (daysFromNow, hour = 20) => {
        const date = new Date();
        date.setDate(date.getDate() + daysFromNow);
        date.setHours(hour, 0, 0, 0);
        return date.toISOString();
      };

      // 1. 사용자 생성 (팀장들)
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

      console.log('✅ 사용자 생성 완료');

      // 2. 팀 생성
      await Team.bulkCreate([
        {
          id: '660e8400-e29b-41d4-a716-446655440001',
          name: 'FC 캘란',
          description: 'FC 캘란입니다. 실력 하하 매너 최상상!',
          logo: null,
          captain_id: '550e8400-e29b-41d4-a716-446655440001',
          age_range_min: 20,
          age_range_max: 35,
          skill_level: 'intermediate',
          introduction: 'FC 캘란입니다. 실력 하하 매너 최상상!',
          is_active: true
        },
        {
          id: '660e8400-e29b-41d4-a716-446655440002',
          name: 'FC 바르셀로나',
          description: 'FC 바르셀로나입니다. 실력 있는 분들과 함께하는 경기를 선호합니다.',
          logo: null,
          captain_id: '550e8400-e29b-41d4-a716-446655440002',
          age_range_min: 25,
          age_range_max: 40,
          skill_level: 'advanced',
          introduction: 'FC 바르셀로나입니다. 실력 있는 분들과 함께하는 경기를 선호합니다.',
          is_active: true
        },
        {
          id: '660e8400-e29b-41d4-a716-446655440003',
          name: 'FC 뮌헨',
          description: 'FC 뮌헨입니다. 즐겁게 축구하실 분들 모집합니다!',
          logo: null,
          captain_id: '550e8400-e29b-41d4-a716-446655440003',
          age_range_min: 20,
          age_range_max: 30,
          skill_level: 'beginner',
          introduction: 'FC 뮌헨입니다. 즐겁게 축구하실 분들 모집합니다!',
          is_active: true
        }
      ], { ignoreDuplicates: true });

      console.log('✅ 팀 생성 완료');

      // 3. 매칭 생성 (iOS 목데이터 기반)
      const matchSeedData = [
        {
          id: '770e8400-e29b-41d4-a716-446655440001',
          title: '양원역 구장에서 11vs11 경기',
          description: '11대 11 실력 하하 구장비 7천원',
          date: buildFutureDate(1, 19),
          location: '양원역 구장',
          address: '서울시 노원구 양원역 근처 구장',
          latitude: 37.6065,
          longitude: 127.0728,
          fee: 7000,
          max_participants: 22,
          current_participants: 0,
          match_type: '11v11',
          gender_type: 'mixed',
          shoes_requirement: 'any',
          age_range_min: 20,
          age_range_max: 35,
          skill_level_min: 'beginner',
          skill_level_max: 'intermediate',
          team_introduction: 'FC 캘란입니다. 실력 하하 매너 최상상!',
          status: 'recruiting',
          is_active: true,
          team_id: '660e8400-e29b-41d4-a716-446655440001'
        },
        {
          id: '770e8400-e29b-41d4-a716-446655440002',
          title: '태릉중학교에서 11vs11 경기',
          description: '11대 11 실력 하하 구장비 5만원',
          date: buildFutureDate(3, 21),
          location: '태릉중학교',
          address: '서울시 노원구 태릉로 456 태릉중학교 운동장',
          latitude: 37.6185,
          longitude: 127.0778,
          fee: 50000,
          max_participants: 22,
          current_participants: 0,
          match_type: '11v11',
          gender_type: 'male',
          shoes_requirement: 'soccer',
          age_range_min: 25,
          age_range_max: 40,
          skill_level_min: 'intermediate',
          skill_level_max: 'expert',
          team_introduction: 'FC 바르셀로나입니다. 실력 있는 분들과 함께하는 경기를 선호합니다.',
          status: 'full',
          is_active: true,
          team_id: '660e8400-e29b-41d4-a716-446655440002'
        },
        {
          id: '770e8400-e29b-41d4-a716-446655440003',
          title: '용산 아이파크몰에서 11vs11 경기',
          description: '11대 11 실력 하하 구장비 7천원',
          date: buildFutureDate(7, 18),
          location: '용산 아이파크몰',
          address: '서울시 용산구 한강대로23길 55',
          latitude: 37.5295,
          longitude: 126.9648,
          fee: 7000,
          max_participants: 22,
          current_participants: 0,
          match_type: '11v11',
          gender_type: 'mixed',
          shoes_requirement: 'any',
          age_range_min: 20,
          age_range_max: 30,
          skill_level_min: 'beginner',
          skill_level_max: 'intermediate',
          team_introduction: 'FC 뮌헨입니다. 즐겁게 축구하실 분들 모집합니다!',
          status: 'completed',
          is_active: true,
          team_id: '660e8400-e29b-41d4-a716-446655440003'
        }
      ];

      for (const matchData of matchSeedData) {
        await Match.upsert(matchData);
      }

      console.log('✅ 매칭 생성 완료');
      console.log(`📊 총 ${matchSeedData.length}개의 매칭이 생성되었습니다.`);

      res.json({
        success: true,
        message: '목데이터 생성 완료',
        data: {
          users: 3,
          teams: 3,
          matches: matchSeedData.length
        }
      });

    } catch (error) {
      console.error('❌ 목데이터 생성 실패:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create seed data',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  });
}

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
      team_id,
      team_name
    } = req.body;

    // 필수 필드 검증
    if (!title || !date || !location) {
      return res.status(400).json({
        success: false,
        message: 'Title, date, and location are required'
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
        age_range_min,
        age_range_max,
        skill_level: skill_level_min, // 최소 실력을 팀 실력으로 설정
        introduction: team_introduction,
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
          message: 'You can only create matches for your own team'
        });
      }
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
      team_id: finalTeamId,
      status: 'recruiting'
    });

    // 팀 소개 코멘트가 있다면 저장
    if (team_introduction) {
      await Comment.create({
        content: team_introduction,
        user_id: req.user.id,
        team_id: finalTeamId,
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
    console.error('매칭 생성 에러:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create match',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 매칭 상세 조회
router.get('/:id', validateId, auth, async (req, res) => {
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

    // 현재 사용자의 관심 여부 확인
    const interest = await UserInterest.findOne({
      where: {
        user_id: req.user.id,
        match_id: req.params.id,
        interest_type: 'match'
      }
    });

    const responseData = {
      ...match.toJSON(),
      is_interested_by_user: !!interest
    };

    res.json({
      success: true,
      data: responseData
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch match',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 매칭 수정
router.put('/:id', validateId, auth, async (req, res) => {
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

    // 허용된 필드만 업데이트 (mass assignment 방지)
    const allowedFields = [
      'title', 'description', 'date', 'location', 'address',
      'latitude', 'longitude', 'fee', 'max_participants',
      'match_type', 'gender_type', 'shoes_requirement',
      'age_range_min', 'age_range_max', 'skill_level_min', 'skill_level_max',
      'team_introduction', 'status'
    ];
    const updateData = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    }
    await match.update(updateData);

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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 매칭 삭제
router.delete('/:id', validateId, auth, async (req, res) => {
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 참가 신청
router.post('/:id/apply', validateId, auth, async (req, res) => {
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 참가 취소
router.delete('/:id/apply', validateId, auth, async (req, res) => {
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 참가자 목록 조회
router.get('/:id/participants', validateId, auth, async (req, res) => {
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
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 내가 등록한 매칭 목록 조회
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

    // 내 팀으로 등록한 매칭 조회
    const { count, rows: matches } = await Match.findAndCountAll({
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
      message: 'Failed to fetch my matches',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 팀 매칭 관심 추가
router.post('/:id/like', validateId, auth, async (req, res) => {
  try {
    const match = await Match.findByPk(req.params.id);

    if (!match || !match.is_active) {
      return res.status(404).json({
        success: false,
        message: 'Match not found'
      });
    }

    // 이미 관심 표시했는지 확인
    const existingInterest = await UserInterest.findOne({
      where: {
        user_id: req.user.id,
        match_id: req.params.id,
        interest_type: 'match'
      }
    });

    if (existingInterest) {
      return res.status(400).json({
        success: false,
        message: 'You have already marked this match as interested'
      });
    }

    const interest = await UserInterest.create({
      user_id: req.user.id,
      match_id: req.params.id,
      interest_type: 'match'
    });

    res.status(201).json({
      success: true,
      data: interest,
      message: 'Match marked as interested'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to mark match as interested',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// 팀 매칭 관심 제거
router.delete('/:id/like', validateId, auth, async (req, res) => {
  try {
    const interest = await UserInterest.findOne({
      where: {
        user_id: req.user.id,
        match_id: req.params.id,
        interest_type: 'match'
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
    });
  }
});

module.exports = router; 
