# AllOfSoccer - 축구 매칭 플랫폼

축구 회장들이 매주 경기를 쉽게 등록하고 관리할 수 있는 모바일 축구 매칭 플랫폼입니다.

## 프로젝트 개요

### 문제점
축구 회장들이 매주 경기를 잡을 때 매번 같은 정보를 입력하는 것이 불편함

### 해결책
- 모바일에서 간편하게 경기 등록
- 이전에 올린 매치 정보를 불러와서 재사용 가능
- 필터링을 통한 빠른 매치 검색
- 실시간 채팅으로 소통

## 프로젝트 구조

```
allOfSoccer/
├── iOS/                    # iOS 앱 (Swift)
│   └── AllOfSoccer/
│       ├── Main/           # 메인 화면 (매칭 리스트)
│       ├── Recruitment/    # 매칭 등록 화면
│       ├── Login/          # 로그인/회원가입
│       ├── MyPage/         # 마이페이지
│       └── Network/        # API 통신
│
└── Server/                 # Node.js 백엔드
    └── src/
        ├── models/         # 데이터베이스 모델
        ├── routes/         # API 라우터
        ├── middleware/     # 미들웨어
        └── socket/         # Socket.io 핸들러
```

## 주요 기능

### 1. 로그인/회원가입
- Apple Sign-In 지원
- JWT 기반 인증

### 2. 매칭 등록
- **FirstTeamRecruitmentViewController**: 기본 정보 입력
  - 경기 날짜/시간
  - 장소
  - 경기 종류 (6:6, 11:11)
  - 성별 (남성, 여성, 혼성)
  - 신발 요구사항 (풋살화, 축구화)
  - 비용

- **SecondTeamRecruitmentViewController**: 상세 정보 입력
  - 연령대 범위
  - 실력 레벨
  - 팀 소개 코멘트

### 3. 매칭 조회/검색
- 필터링: 날짜, 장소, 경기 종류, 성별, 연령대, 실력 레벨, 비용
- 정렬: 날짜순, 거리순, 생성일순
- 페이징 지원

### 4. 이전 매치 불러오기
- 내가 등록한 매칭 목록 조회 (`GET /api/matches/my/created`)
- 이전 매치 정보를 불러와서 새 매칭에 활용

### 5. 팀 관리
- 팀 생성/수정
- 팀원 관리
- 팀 소개

### 6. 실시간 기능
- Socket.io 기반 실시간 채팅
- 매칭 상태 업데이트 알림
- 참가 신청 알림

## 기술 스택

### iOS 앱
- Swift
- UIKit
- URLSession (네트워크)

### 백엔드
- Node.js + Express.js
- PostgreSQL + Sequelize ORM
- Redis (캐싱)
- Socket.io (실시간 통신)
- JWT (인증)
- Multer (파일 업로드)

## 시작하기

### 백엔드 서버

```bash
cd Server
npm install
cp env.example .env
# .env 파일 설정 후
npm run dev
```

자세한 내용은 [Server/README.md](Server/README.md) 참조

### iOS 앱

Xcode에서 `iOS/AllOfSoccer.xcodeproj` 열기

## API 문서

주요 API 엔드포인트:

### 인증
- `POST /api/auth/apple-signin` - Apple Sign-In
- `GET /api/auth/profile` - 프로필 조회
- `PUT /api/auth/profile` - 프로필 수정

### 매칭
- `GET /api/matches` - 매칭 목록 (필터링 지원)
- `POST /api/matches` - 매칭 생성
- `GET /api/matches/:id` - 매칭 상세
- `PUT /api/matches/:id` - 매칭 수정
- `DELETE /api/matches/:id` - 매칭 삭제
- `GET /api/matches/my/created` - 내가 등록한 매칭 목록

### 팀
- `GET /api/teams` - 팀 목록
- `POST /api/teams` - 팀 생성
- `GET /api/teams/my/teams` - 내가 속한 팀 목록

## 개발 상태

### 완료된 기능
- ✅ 서버 로컬 환경 세팅
- ✅ 로그인 플로우 완성
- ✅ 매칭 리스트 서버 연동
- ✅ 로그인, 회원가입
- ✅ 각종 버그 수정

### 진행 중/예정
- 🚧 이전 매치 불러오기 UI 완성
- 🚧 매칭 수정 기능
- 🚧 실시간 채팅 UI
- 🚧 푸시 알림

## 더 많은 문서

- [CONTEXT.md](CONTEXT.md) - AI가 다음에 작업할 때 참고할 프로젝트 컨텍스트
- [FEATURES.md](FEATURES.md) - 주요 기능 상세 설명
- [ARCHITECTURE.md](ARCHITECTURE.md) - 아키텍처 및 기술 설계

## 라이선스

MIT License
