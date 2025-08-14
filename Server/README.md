# AllOfSoccer Backend Server

축구 상대팀 매칭 플랫폼 "AllOfSoccer"의 백엔드 서버입니다.

## 기술 스택

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: PostgreSQL + Sequelize ORM
- **Cache**: Redis
- **Real-time**: Socket.io
- **Authentication**: JWT + Apple Sign-In
- **File Upload**: Multer
- **Documentation**: Swagger/OpenAPI

## 프로젝트 구조

```
src/
├── config/          # 설정 파일들
│   ├── database.js  # 데이터베이스 설정
│   └── redis.js     # Redis 설정
├── controllers/     # 컨트롤러 (추후 추가)
├── middleware/      # 미들웨어
│   ├── auth.js      # JWT 인증
│   └── errorHandler.js # 에러 핸들링
├── models/          # 데이터베이스 모델
│   ├── User.js      # 사용자 모델
│   ├── Team.js      # 팀 모델
│   ├── TeamMember.js # 팀 멤버 모델
│   ├── Match.js     # 매칭 모델
│   ├── MatchParticipant.js # 매칭 참가자 모델
│   ├── Comment.js   # 코멘트 모델
│   └── index.js     # 모델 관계 설정
├── routes/          # API 라우터
│   ├── auth.js      # 인증 관련
│   ├── users.js     # 사용자 관련
│   ├── teams.js     # 팀 관련
│   ├── matches.js   # 매칭 관련
│   ├── chats.js     # 채팅 관련
│   ├── notifications.js # 알림 관련
│   └── uploads.js   # 파일 업로드 관련
├── services/        # 비즈니스 로직 (추후 추가)
├── socket/          # Socket.io 핸들러
│   └── socketHandler.js
├── utils/           # 유틸리티 함수 (추후 추가)
└── app.js           # 메인 애플리케이션 파일
```

## 설치 및 실행

### 1. 의존성 설치

```bash
npm install
```

### 2. 환경 변수 설정

```bash
cp env.example .env
```

`.env` 파일을 편집하여 필요한 설정을 입력하세요.

### 3. 데이터베이스 설정

PostgreSQL 데이터베이스를 생성하고 연결 정보를 `.env` 파일에 설정하세요.

### 4. 서버 실행

#### 개발 모드
```bash
npm run dev
```

#### 프로덕션 모드
```bash
npm start
```

## API 엔드포인트

### 인증
- `POST /api/auth/apple-signin` - Apple Sign-In
- `POST /api/auth/refresh` - 토큰 갱신
- `POST /api/auth/logout` - 로그아웃
- `GET /api/auth/profile` - 프로필 조회
- `PUT /api/auth/profile` - 프로필 수정
- `DELETE /api/auth/profile` - 회원탈퇴

### 사용자
- `GET /api/users` - 사용자 목록 조회
- `GET /api/users/:id` - 특정 사용자 조회

### 팀
- `GET /api/teams` - 팀 목록 조회
- `POST /api/teams` - 팀 생성
- `GET /api/teams/:id` - 팀 상세 조회
- `PUT /api/teams/:id` - 팀 수정
- `POST /api/teams/:id/members` - 팀 멤버 추가
- `DELETE /api/teams/:id/members/:userId` - 팀 멤버 제거
- `GET /api/teams/my/teams` - 내가 속한 팀 목록

### 매칭
- `GET /api/matches` - 매칭 목록 조회 (필터링, 정렬, 페이징)
- `POST /api/matches` - 매칭 생성
- `GET /api/matches/:id` - 매칭 상세 조회
- `PUT /api/matches/:id` - 매칭 수정
- `DELETE /api/matches/:id` - 매칭 삭제
- `POST /api/matches/:id/apply` - 참가 신청
- `DELETE /api/matches/:id/apply` - 참가 취소
- `GET /api/matches/:id/participants` - 참가자 목록 조회

### 파일 업로드
- `POST /api/uploads/profile-image` - 프로필 이미지 업로드
- `POST /api/uploads/team-logo` - 팀 로고 업로드

## 데이터베이스 스키마

### Users
- 사용자 정보 (Apple Sign-In 지원)
- 프로필 이미지, FCM 토큰 등

### Teams
- 팀 정보 (팀장, 설명, 로고 등)
- 연령대, 실력 레벨 설정

### TeamMembers
- 팀 멤버 관계 (팀장/멤버 역할)

### Matches
- 매칭 정보 (iOS 앱의 FirstTeamRecruitmentViewController, SecondTeamRecruitmentViewController 기반)
- 경기 종류 (6:6, 11:11), 성별 구분, 신발 요구사항
- 연령대, 실력 레벨 필터링
- 팀 소개 코멘트

### MatchParticipants
- 매칭 참가자 정보
- 참가 상태, 결제 상태 등

### Comments
- 팀 소개 코멘트 (iOS의 TeamIntroductionTableViewCell 기반)
- 순서 관리, 계층 구조 지원

## Socket.io 이벤트

### 클라이언트 → 서버
- `join_match` - 매칭 룸 참가
- `leave_match` - 매칭 룸 나가기
- `send_message` - 채팅 메시지 전송
- `match_status_changed` - 매칭 상태 변경 알림
- `match_application` - 참가 신청 알림

### 서버 → 클라이언트
- `new_message` - 새 채팅 메시지
- `match_updated` - 매칭 정보 업데이트
- `new_application` - 새 참가 신청
- `new_match_available` - 새 매칭 생성 알림
- `match_is_full` - 매칭 정원 마감 알림

## iOS 앱 연동

이 서버는 iOS 앱의 다음 화면들과 연동됩니다:

### FirstTeamRecruitmentViewController
- 경기 종류 선택 (6:6, 11:11)
- 성별 구분 (남성, 여성, 혼성)
- 신발 요구사항 (풋살화, 축구화)
- 날짜, 장소, 비용 설정

### SecondTeamRecruitmentViewController
- 연령대 범위 설정
- 실력 레벨 설정
- 팀 소개 코멘트 관리 (순서 변경, 삭제)

### TeamIntroductionTableViewCell
- 팀 소개 코멘트 표시
- 순서 변경, 삭제 기능

## 개발 가이드

### 새로운 API 추가
1. `src/routes/` 디렉토리에 라우터 파일 생성
2. `src/app.js`에 라우터 등록
3. 필요한 모델이나 서비스 추가

### 새로운 모델 추가
1. `src/models/` 디렉토리에 모델 파일 생성
2. `src/models/index.js`에 관계 설정 추가

### 테스트
```bash
npm test
```

## 배포

### Docker (추후 추가)
```bash
docker build -t allofsoccer-server .
docker run -p 3000:3000 allofsoccer-server
```

### 환경별 설정
- `NODE_ENV=development` - 개발 환경
- `NODE_ENV=production` - 프로덕션 환경

## 라이선스

MIT License 