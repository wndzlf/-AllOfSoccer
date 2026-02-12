# AllOfSoccer - AI 작업 컨텍스트 문서

이 문서는 AI가 프로젝트를 이어서 작업할 때 필요한 컨텍스트를 제공합니다.

## 프로젝트 의도 및 목표

### 핵심 문제
축구 회장들이 매주 경기를 잡을 때 **같은 정보를 매번 입력하는 것이 너무 불편**함

### 핵심 솔루션
1. 모바일에서 간편하게 경기 등록
2. **이전에 올린 매치를 다시 불러올 수 있는 기능** (가장 중요!)
3. 빠른 검색과 필터링
4. 실시간 소통

### 타겟 사용자
- 축구 동호회 회장/관리자
- 매주 정기적으로 경기를 잡는 사람들
- 같은 장소, 비슷한 조건으로 경기를 반복적으로 등록하는 사람들

## 현재 구현 상태

### 완료된 것들
1. **백엔드 서버** (Server/)
   - PostgreSQL + Sequelize ORM으로 데이터베이스 구축
   - REST API 구현 (`/api/matches`, `/api/teams`, `/api/auth`)
   - Socket.io 실시간 통신 기본 구조
   - Apple Sign-In 인증
   - 매칭 CRUD 기본 기능

2. **iOS 앱** (iOS/AllOfSoccer/)
   - 로그인/회원가입 화면 완성
   - 매칭 리스트 화면 (`GameMatchingViewController`)
   - 매칭 등록 화면 (`FirstTeamRecruitmentViewController`, `SecondTeamRecruitmentViewController`)
   - 필터링 UI (`FilterDetailView`)
   - 네트워크 레이어 (`APIService`, `APITarget`)

### 아직 완성되지 않은 것들

#### 1. 이전 매치 불러오기 기능 (최우선!)
- **백엔드는 완성**: `GET /api/matches/my/created` 엔드포인트 구현됨
- **iOS 앱에서 작업 필요**:
  - `CallPreviusMatchingInformationView.swift` 파일이 있지만 완전히 연동되지 않음
  - `FirstTeamRecruitmentViewController`에 "이전 매치 불러오기" 버튼이 있음 (`callPreviousInformationButton`)
  - 이전 매치 목록을 보여주고 선택하면 해당 정보로 폼을 채우는 로직 필요

#### 2. 매칭 수정 기능
- 백엔드: `PUT /api/matches/:id` 구현됨
- iOS: 수정 UI 필요

#### 3. 실시간 채팅
- 백엔드: Socket.io 기본 구조만 있음
- iOS: 채팅 UI 미구현

## 코드 구조 이해하기

### iOS 앱 주요 파일

#### 1. 네트워크 레이어
- `Network/APIService.swift`: 네트워크 요청 처리
- `Network/APITarget.swift`: API 엔드포인트 정의
- `Network/MatchModels.swift`: 매칭 관련 모델
- `Network/Auth.swift`: 인증 처리

#### 2. 메인 화면
- `Main/GameMatchingViewController.swift`: 매칭 리스트 메인 화면
- `Main/GameMatchingViewModel.swift`: 매칭 리스트 로직
- `Main/GameMatchingTableViewCell.swift`: 매칭 아이템 셀

#### 3. 매칭 등록
- `Recruitment/TeamRecruitment/FirstTeamRecruitmentViewController.swift`:
  - 1단계: 날짜, 장소, 경기 종류, 성별, 신발, 비용 입력
  - `callPreviousInformationButton`: 이전 매치 불러오기 버튼 (작업 필요!)

- `Recruitment/TeamRecruitment/SecondTeamRecruitmentViewController.swift`:
  - 2단계: 연령대, 실력 레벨, 팀 소개 입력

- `Recruitment/Component/CallPreviusMatchingInformationView.swift`:
  - 이전 매치 불러오기 뷰 (연동 작업 필요!)

#### 4. 필터링
- `Main/GameMatchingSub/FilterDetail/FilterDetailView.swift`: 필터 UI
- `Main/FilterTagModel.swift`: 필터 태그 모델

### 백엔드 주요 파일

#### 1. 매칭 관련
- `src/routes/matches.js`: 매칭 API 라우터
  - `GET /api/matches`: 매칭 목록 (필터링, 페이징)
  - `POST /api/matches`: 매칭 생성
  - `GET /api/matches/:id`: 매칭 상세
  - `PUT /api/matches/:id`: 매칭 수정
  - `DELETE /api/matches/:id`: 매칭 삭제
  - `GET /api/matches/my/created`: **내가 등록한 매칭 목록** (중요!)

- `src/models/Match.js`: 매칭 데이터베이스 모델

#### 2. 팀 관련
- `src/routes/teams.js`: 팀 API 라우터
- `src/models/Team.js`: 팀 데이터베이스 모델

#### 3. 인증
- `src/routes/auth.js`: 인증 API
- `src/middleware/auth.js`: JWT 인증 미들웨어

## 다음에 작업할 것들

### 최우선 작업: 이전 매치 불러오기 완성

1. **iOS 작업**:
   ```swift
   // FirstTeamRecruitmentViewController에서
   // callPreviousInformationButton 탭 시:

   // 1. GET /api/matches/my/created 호출
   // 2. 매칭 목록을 팝업/모달로 표시
   // 3. 사용자가 선택하면 해당 정보로 폼 채우기
   //    - 장소 (placeTextField)
   //    - 경기 종류 (6vs6, 11vs11)
   //    - 성별 (남성, 여성, 혼성)
   //    - 신발 (풋살화, 축구화)
   //    - 비용 (priceTextField)
   // 4. 다음 화면(SecondTeamRecruitmentViewController)도 채우기
   //    - 연령대
   //    - 실력 레벨
   //    - 팀 소개
   ```

2. **API 응답 구조**:
   ```json
   {
     "success": true,
     "data": [
       {
         "id": "...",
         "title": "양원역 구장에서 11vs11 경기",
         "location": "양원역 구장",
         "match_type": "11v11",
         "gender_type": "mixed",
         "shoes_requirement": "any",
         "fee": 7000,
         "age_range_min": 20,
         "age_range_max": 35,
         "skill_level_min": "beginner",
         "skill_level_max": "intermediate",
         "team_introduction": "FC 캘란입니다...",
         "created_at": "2024-09-14T..."
       }
     ],
     "pagination": {...}
   }
   ```

### 다음 우선순위 작업

1. **매칭 수정 기능**:
   - 내가 등록한 매칭을 수정할 수 있는 UI
   - `PUT /api/matches/:id` 호출

2. **매칭 상세 화면 개선**:
   - `GameMatchingDetailViewController` 완성
   - 참가 신청/취소 기능

3. **실시간 채팅**:
   - Socket.io 연동
   - 채팅 UI 구현

## 데이터베이스 스키마 요약

### Matches 테이블 주요 필드
```javascript
{
  id: UUID,
  title: String,                    // 매칭 제목
  description: String,              // 설명
  date: Date,                       // 경기 날짜
  location: String,                 // 장소
  address: String,                  // 상세 주소
  fee: Integer,                     // 비용
  match_type: String,               // '6v6' | '11v11'
  gender_type: String,              // 'male' | 'female' | 'mixed'
  shoes_requirement: String,        // 'futsal' | 'soccer' | 'any'
  age_range_min: Integer,           // 최소 연령
  age_range_max: Integer,           // 최대 연령
  skill_level_min: String,          // 최소 실력
  skill_level_max: String,          // 최대 실력
  team_introduction: String,        // 팀 소개
  team_id: UUID,                    // 팀 ID
  status: String,                   // 'recruiting' | 'full' | 'completed' | 'cancelled'
  is_active: Boolean                // 삭제 여부
}
```

## 개발 팁

### 로컬 개발 환경

1. **백엔드 실행**:
   ```bash
   cd Server
   npm run dev  # http://localhost:3000
   ```

2. **iOS 시뮬레이터에서 로컬 서버 접근**:
   - `http://localhost:3000` 대신 `http://127.0.0.1:3000` 사용
   - 또는 맥의 IP 주소 사용 (예: `http://192.168.0.10:3000`)

3. **목데이터 생성**:
   ```bash
   curl -X POST http://localhost:3000/api/matches/seed
   ```

### 자주 사용하는 Git 커밋 메시지 패턴
- `로그인, 회원가입, 각종 버그수정`
- `✔ Step 1: ... ✔ Step 2: ... ✔ Step 3: ...`
- 명확한 한글 커밋 메시지 선호

## 주의사항

1. **필터링 성능**: 매칭이 많아지면 필터링 성능 최적화 필요
2. **이미지 업로드**: 프로필/팀 로고 업로드 시 파일 크기 제한 확인
3. **Socket.io**: 실시간 기능 구현 시 연결 관리 주의
4. **JWT 토큰**: 리프레시 토큰 로직 확인

## 참고 링크

- Server README: [Server/README.md](Server/README.md)
- iOS 앱 구조: [iOS/AllOfSoccer/](iOS/AllOfSoccer/)
- API 엔드포인트: [Server/src/routes/](Server/src/routes/)
