# AllOfSoccer - 아키텍처 문서

## 시스템 아키텍처

```
┌─────────────────┐
│   iOS App       │
│   (Swift)       │
└────────┬────────┘
         │ HTTP/REST
         │ Socket.io
         │
┌────────▼────────────────────────────────────┐
│   Node.js Server (Express)                  │
│                                              │
│   ┌──────────────┐    ┌──────────────┐     │
│   │   Routes     │    │  Middleware  │     │
│   │   (API)      │    │  (Auth, etc) │     │
│   └──────┬───────┘    └──────────────┘     │
│          │                                   │
│   ┌──────▼───────┐    ┌──────────────┐     │
│   │   Models     │◄───┤  Socket.io   │     │
│   │  (Sequelize) │    │   Handler    │     │
│   └──────┬───────┘    └──────────────┘     │
└──────────┼──────────────────────────────────┘
           │
    ┌──────┴──────┐
    │             │
┌───▼────┐   ┌───▼────┐
│ Postgre│   │ Redis  │
│  SQL   │   │ Cache  │
└────────┘   └────────┘
```

---

## 백엔드 아키텍처

### 기술 스택

#### 핵심 프레임워크
- **Node.js** (v18+): JavaScript 런타임
- **Express.js**: 웹 프레임워크
- **Sequelize**: PostgreSQL ORM
- **Socket.io**: 실시간 양방향 통신

#### 데이터베이스
- **PostgreSQL**: 메인 데이터베이스
  - 사용자, 팀, 매칭, 코멘트 등 모든 데이터 저장
  - 트랜잭션 지원
  - 복잡한 쿼리 (필터링, 조인)

- **Redis**: 캐싱 및 세션 관리
  - JWT 토큰 블랙리스트
  - 세션 데이터 캐싱
  - 실시간 데이터 임시 저장

#### 보안 및 인증
- **JWT (jsonwebtoken)**: 토큰 기반 인증
- **bcryptjs**: 비밀번호 해싱
- **helmet**: HTTP 헤더 보안
- **express-rate-limit**: API 요청 제한

#### 파일 처리
- **multer**: 파일 업로드 (프로필 이미지, 팀 로고)

#### 기타
- **cors**: CORS 처리
- **morgan**: HTTP 로깅
- **dotenv**: 환경 변수 관리
- **swagger-jsdoc, swagger-ui-express**: API 문서

### 디렉토리 구조

```
Server/
├── src/
│   ├── config/              # 설정 파일
│   │   ├── database.js      # PostgreSQL 설정
│   │   └── redis.js         # Redis 설정
│   │
│   ├── models/              # 데이터베이스 모델
│   │   ├── index.js         # 모델 관계 설정
│   │   ├── User.js          # 사용자 모델
│   │   ├── Team.js          # 팀 모델
│   │   ├── TeamMember.js    # 팀 멤버 관계
│   │   ├── Match.js         # 매칭 모델
│   │   ├── MatchParticipant.js  # 매칭 참가자
│   │   └── Comment.js       # 코멘트 모델
│   │
│   ├── routes/              # API 라우터
│   │   ├── auth.js          # 인증 API
│   │   ├── users.js         # 사용자 API
│   │   ├── teams.js         # 팀 API
│   │   ├── matches.js       # 매칭 API
│   │   ├── chats.js         # 채팅 API
│   │   ├── notifications.js # 알림 API
│   │   └── uploads.js       # 파일 업로드 API
│   │
│   ├── middleware/          # 미들웨어
│   │   ├── auth.js          # JWT 인증 미들웨어
│   │   └── errorHandler.js # 에러 핸들링
│   │
│   ├── socket/              # Socket.io
│   │   └── socketHandler.js # 실시간 통신 핸들러
│   │
│   └── app.js               # 메인 애플리케이션
│
├── uploads/                 # 업로드된 파일 저장
├── package.json
├── .env                     # 환경 변수 (비공개)
└── README.md
```

### 데이터베이스 스키마

#### Users (사용자)
```javascript
{
  id: UUID,                     // 기본 키
  apple_user_id: String,        // Apple Sign-In ID
  name: String,                 // 이름
  email: String,                // 이메일
  phone: String,                // 전화번호
  profile_image: String,        // 프로필 이미지 URL
  fcm_token: String,            // FCM 푸시 토큰
  created_at: Date,
  updated_at: Date
}
```

#### Teams (팀)
```javascript
{
  id: UUID,
  name: String,                 // 팀 이름
  description: Text,            // 팀 설명
  logo: String,                 // 팀 로고 URL
  captain_id: UUID,             // 팀장 (User FK)
  age_range_min: Integer,       // 연령대 최소
  age_range_max: Integer,       // 연령대 최대
  skill_level: String,          // 실력 레벨
  introduction: Text,           // 팀 소개
  is_active: Boolean,           // 활성 상태
  created_at: Date,
  updated_at: Date
}
```

#### TeamMembers (팀 멤버)
```javascript
{
  id: UUID,
  team_id: UUID,                // Team FK
  user_id: UUID,                // User FK
  role: String,                 // 'captain' | 'member'
  joined_at: Date,
  created_at: Date,
  updated_at: Date
}
```

#### Matches (매칭)
```javascript
{
  id: UUID,
  title: String,                // 매칭 제목
  description: Text,            // 설명
  date: Date,                   // 경기 날짜
  location: String,             // 장소
  address: String,              // 상세 주소
  latitude: Float,              // 위도
  longitude: Float,             // 경도
  fee: Integer,                 // 비용
  max_participants: Integer,    // 최대 인원
  current_participants: Integer,// 현재 인원
  match_type: String,           // '6v6' | '11v11'
  gender_type: String,          // 'male' | 'female' | 'mixed'
  shoes_requirement: String,    // 'futsal' | 'soccer' | 'any'
  age_range_min: Integer,       // 연령대 최소
  age_range_max: Integer,       // 연령대 최대
  skill_level_min: String,      // 실력 최소
  skill_level_max: String,      // 실력 최대
  team_introduction: Text,      // 팀 소개
  team_id: UUID,                // Team FK
  status: String,               // 'recruiting' | 'full' | 'completed' | 'cancelled'
  is_active: Boolean,           // 활성 상태 (삭제 여부)
  created_at: Date,
  updated_at: Date
}
```

#### MatchParticipants (매칭 참가자)
```javascript
{
  id: UUID,
  match_id: UUID,               // Match FK
  user_id: UUID,                // User FK
  team_id: UUID,                // Team FK (optional)
  status: String,               // 'pending' | 'approved' | 'rejected' | 'cancelled'
  payment_status: String,       // 'pending' | 'paid' | 'refunded'
  applied_at: Date,
  created_at: Date,
  updated_at: Date
}
```

#### Comments (코멘트)
```javascript
{
  id: UUID,
  content: Text,                // 코멘트 내용
  user_id: UUID,                // User FK
  team_id: UUID,                // Team FK (optional)
  type: String,                 // 'team_introduction' | 'match_comment'
  order_index: Integer,         // 순서
  parent_id: UUID,              // 대댓글용 (optional)
  created_at: Date,
  updated_at: Date
}
```

### API 인증 플로우

```
1. iOS App → Apple Sign-In
   └─> Apple ID Token 획득

2. iOS App → POST /api/auth/apple-signin
   └─> Apple ID Token 전송

3. Server → Apple 서버
   └─> 토큰 검증

4. Server → 사용자 조회/생성
   └─> DB에서 사용자 찾기 또는 생성

5. Server → JWT 생성
   └─> Access Token + Refresh Token

6. Server → iOS App
   └─> 토큰 반환

7. iOS App → API 요청
   └─> Authorization: Bearer {access_token}

8. Server → JWT 검증 (middleware/auth.js)
   └─> 요청 처리
```

### 실시간 통신 플로우 (Socket.io)

```
1. iOS App 연결
   ├─> socket.connect()
   └─> 인증 토큰 전송

2. Server 인증
   ├─> 토큰 검증
   └─> 소켓 연결 승인

3. 매칭 룸 참가
   ├─> emit('join_match', { match_id })
   └─> Server: socket.join(match_id)

4. 메시지 전송
   ├─> emit('send_message', { match_id, message })
   └─> Server: io.to(match_id).emit('new_message', data)

5. 실시간 알림
   ├─> Server: io.to(match_id).emit('match_updated', data)
   └─> iOS App: 알림 수신 및 UI 업데이트
```

---

## iOS 앱 아키텍처

### 기술 스택

- **Swift**: 프로그래밍 언어
- **UIKit**: UI 프레임워크
- **URLSession**: 네트워크 통신
- **Codable**: JSON 인코딩/디코딩

### 아키텍처 패턴

**MVVM (Model-View-ViewModel)**

```
┌──────────────┐
│     View     │  (ViewController)
│  Controller  │
└──────┬───────┘
       │ Binding
┌──────▼───────┐
│  ViewModel   │  (GameMatchingViewModel)
└──────┬───────┘
       │ Data
┌──────▼───────┐
│    Model     │  (MatchModels)
└──────┬───────┘
       │ API
┌──────▼───────┐
│ APIService   │
└──────────────┘
```

### 디렉토리 구조

```
iOS/AllOfSoccer/
├── Application/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
│
├── Network/                    # 네트워크 레이어
│   ├── APIService.swift        # 네트워크 요청 처리
│   ├── APITarget.swift         # API 엔드포인트 정의
│   ├── MatchModels.swift       # 매칭 모델
│   ├── Auth.swift              # 인증 토큰 관리
│   └── RootResponse.swift      # 공통 응답 모델
│
├── Login/                      # 로그인/회원가입
│   ├── SignInViewController.swift
│   ├── SignUpViewController.swift
│   └── Model/
│       ├── Login.swift
│       └── SignInModel.swift
│
├── Main/                       # 메인 화면
│   ├── MainTabBarController.swift
│   ├── GameMatchingViewController.swift
│   ├── GameMatchingViewModel.swift
│   ├── GameMatchingTableViewCell.swift
│   ├── GameMatchingFilterCollectionViewCell.swift
│   ├── FilterTagModel.swift
│   └── GameMatchingSub/
│       ├── FilterDetail/
│       │   └── FilterDetailView.swift
│       └── HorizontalCalendar/
│           ├── HorizontalCalendarCollectionViewCell.swift
│           └── HorizontalCalendarViewModel.swift
│
├── Recruitment/                # 매칭 등록
│   ├── TeamRecruitment/
│   │   ├── FirstTeamRecruitmentViewController.swift
│   │   ├── SecondTeamRecruitmentViewController.swift
│   │   ├── GameOptionCell.swift
│   │   └── TeamIntroductionTableViewCell.swift
│   └── Component/
│       ├── CallPreviusMatchingInformationView.swift
│       ├── SearchPlaceView.swift
│       └── RecruitmentCalendarView.swift
│
├── GamematchingDetail/         # 매칭 상세
│   ├── GameMatchingDetailViewController.swift
│   └── GameMatchingDetailViewModel.swift
│
├── MyPage/                     # 마이페이지
│   ├── MyPageViewController.swift
│   ├── MyinformationView/
│   ├── TeamInformationView/
│   ├── MyWritingViewController/
│   ├── MyFavoriteViewController/
│   ├── NoticeView/
│   ├── QuestionsView/
│   └── VersionView/
│
├── Components/                 # 공통 컴포넌트
│   ├── RoundButton.swift
│   ├── RoundView.swift
│   ├── BlockingActivityIndicator.swift
│   └── ...
│
├── Extension/                  # Extension
│   ├── UIView+Extension.swift
│   ├── Date+Extension.swift
│   └── ...
│
└── Base/
    └── BaseViewController.swift
```

### 네트워크 레이어 설계

#### APIService.swift
```swift
// 네트워크 요청 처리
class APIService {
    static let shared = APIService()

    func request<T: Decodable>(
        target: APITarget,
        completion: @escaping (Result<T, Error>) -> Void
    )
}
```

#### APITarget.swift
```swift
// API 엔드포인트 정의
enum APITarget {
    case getMatches(filters: MatchFilters)
    case createMatch(match: CreateMatchRequest)
    case getMatch(id: String)
    case updateMatch(id: String, match: UpdateMatchRequest)
    case deleteMatch(id: String)
    case getMyCreatedMatches(page: Int, limit: Int)
    // ...

    var baseURL: String { ... }
    var path: String { ... }
    var method: HTTPMethod { ... }
    var parameters: [String: Any]? { ... }
}
```

#### MatchModels.swift
```swift
// 매칭 관련 모델
struct Match: Codable {
    let id: String
    let title: String
    let location: String
    let date: Date
    let matchType: String
    let genderType: String
    let fee: Int
    // ...
}

struct CreateMatchRequest: Encodable {
    let title: String
    let date: Date
    let location: String
    // ...
}
```

### 화면 흐름

```
┌─────────────────┐
│  Sign In        │
│  (로그인)        │
└────────┬────────┘
         │
┌────────▼────────────────────────────┐
│  MainTabBarController               │
│  ┌──────────────────────────────┐   │
│  │  GameMatching (매칭 리스트)   │   │
│  │  - 필터링                     │   │
│  │  - 캘린더                     │   │
│  │  - 정렬                       │   │
│  └──────────┬───────────────────┘   │
│             │                        │
│  ┌──────────▼───────────────────┐   │
│  │  MyPage (마이페이지)          │   │
│  │  - 내 정보                    │   │
│  │  - 팀 관리                    │   │
│  │  - 내가 등록한 매칭           │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
         │                 │
         │                 │
┌────────▼────────┐   ┌────▼─────────────────┐
│ Matching Detail │   │  Team Recruitment    │
│ (매칭 상세)      │   │  (매칭 등록)          │
│ - 참가 신청      │   │  1단계: 기본 정보     │
│ - 채팅          │   │  2단계: 상세 정보     │
└─────────────────┘   └──────────────────────┘
```

---

## 보안 고려사항

### 1. 인증 및 권한
- JWT 토큰 사용 (Access Token + Refresh Token)
- 토큰 만료 시간: Access Token 1시간, Refresh Token 7일
- 민감한 API는 인증 미들웨어 필수

### 2. API 보안
- Helmet으로 HTTP 헤더 보안 강화
- CORS 설정으로 허용된 도메인만 접근
- Rate Limiting으로 DDoS 방어 (15분당 100 요청)

### 3. 데이터 보안
- 비밀번호 bcrypt 해싱 (현재 Apple Sign-In만 사용)
- SQL Injection 방어 (Sequelize ORM)
- XSS 방어 (입력 값 검증)

### 4. 파일 업로드
- 파일 크기 제한: 10MB
- 허용된 MIME 타입만 업로드
- 파일명 랜덤 생성

---

## 성능 최적화

### 1. 데이터베이스
- 인덱스 생성: `location`, `date`, `match_type`, `status`
- 페이징으로 대량 데이터 처리
- Redis 캐싱으로 자주 조회되는 데이터 캐싱

### 2. API
- 응답 압축 (gzip)
- 불필요한 데이터 제외 (select specific fields)
- N+1 쿼리 문제 해결 (Sequelize include)

### 3. iOS 앱
- 이미지 캐싱
- 테이블뷰 셀 재사용
- 비동기 네트워크 요청

---

## 배포 환경

### 개발 환경
- Node.js: v18+
- PostgreSQL: v14+
- Redis: v7+
- iOS: v14+

### 환경 변수 (.env)
```bash
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
JWT_SECRET=...
JWT_EXPIRES_IN=1h
REFRESH_TOKEN_EXPIRES_IN=7d
CORS_ORIGIN=http://localhost:3000
```

### 프로덕션 환경 (예정)
- Docker 컨테이너화
- AWS ECS 또는 EC2
- RDS PostgreSQL
- ElastiCache Redis
- CloudFront CDN (이미지)
- Route53 DNS
