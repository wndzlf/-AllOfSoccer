const { User, Team, Match } = require('../models');

async function seedMatches() {
  try {
    console.log('🌱 매칭 시드 데이터 생성 시작...');

    // 1. 사용자 생성 (팀장들)
    const users = await User.bulkCreate([
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
    const teams = await Team.bulkCreate([
      {
        id: '660e8400-e29b-41d4-a716-446655440001',
        name: 'FC 캘란',
        description: 'FC 캘란입니다. 실력 하하 매너 최상상!',
        logo: null,
        captain_id: users[0].id,
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
        captain_id: users[1].id,
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
        captain_id: users[2].id,
        age_range_min: 20,
        age_range_max: 30,
        skill_level: 'beginner',
        introduction: 'FC 뮌헨입니다. 즐겁게 축구하실 분들 모집합니다!',
        is_active: true
      }
    ], { ignoreDuplicates: true });

    console.log('✅ 팀 생성 완료');

    // 3. 매칭 생성 (iOS 목데이터 기반)
    const matches = await Match.bulkCreate([
      {
        id: '770e8400-e29b-41d4-a716-446655440001',
        title: '양원역 구장에서 11vs11 경기',
        description: '11대 11 실력 하하 구장비 7천원',
        date: '2024-09-14T22:00:00.000Z', // 9월 14일 22:00
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
        team_id: teams[0].id
      },
      {
        id: '770e8400-e29b-41d4-a716-446655440002',
        title: '태릉중학교에서 11vs11 경기',
        description: '11대 11 실력 하하 구장비 5만원',
        date: '2024-09-14T22:00:00.000Z', // 9월 14일 22:00
        location: '태릉중학교',
        address: '서울시 노원구 태릉로 456 태릉중학교 운동장',
        latitude: 37.6185,
        longitude: 127.0778,
        fee: 50000,
        max_participants: 22,
        current_participants: 0,
        match_type: '11v11',
        gender_type: 'male',
        shoes_requirement: 'cleats',
        age_range_min: 25,
        age_range_max: 40,
        skill_level_min: 'intermediate',
        skill_level_max: 'expert',
        team_introduction: 'FC 바르셀로나입니다. 실력 있는 분들과 함께하는 경기를 선호합니다.',
        status: 'recruiting',
        is_active: true,
        team_id: teams[1].id
      },
      {
        id: '770e8400-e29b-41d4-a716-446655440003',
        title: '용산 아이파크몰에서 11vs11 경기',
        description: '11대 11 실력 하하 구장비 7천원',
        date: '2024-09-14T22:00:00.000Z', // 9월 14일 22:00
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
        status: 'recruiting',
        is_active: true,
        team_id: teams[2].id
      }
    ], { ignoreDuplicates: true });

    console.log('✅ 매칭 생성 완료');
    console.log(`📊 총 ${matches.length}개의 매칭이 생성되었습니다.`);

  } catch (error) {
    console.error('❌ 시드 데이터 생성 실패:', error);
    throw error;
  }
}

// 스크립트가 직접 실행될 때만 실행
if (require.main === module) {
  const dbConfig = require('../config/database');
  
  dbConfig.authenticate()
    .then(() => {
      console.log('데이터베이스 연결 성공');
      return dbConfig.sync({ alter: true });
    })
    .then(() => {
      console.log('데이터베이스 동기화 완료');
      return seedMatches();
    })
    .then(() => {
      console.log('🎉 모든 시드 데이터 생성 완료!');
      process.exit(0);
    })
    .catch(err => {
      console.error('시드 데이터 생성 중 오류 발생:', err);
      process.exit(1);
    });
}

module.exports = { seedMatches }; 