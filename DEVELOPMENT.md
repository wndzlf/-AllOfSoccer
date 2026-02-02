# AllOfSoccer - 개발 진행 상황

## 현재 상태 (2026-02-02)

### 백엔드 서버
- ✅ **서버 실행 중**: `npm run dev` (포트 3000)
- ✅ **목데이터 생성**: 3명의 팀장, 3개의 팀, 3개의 매칭
- ✅ **API 구현**: 모든 주요 엔드포인트 완성
  - 인증 API (`/api/auth/*`)
  - 매칭 CRUD (`/api/matches`)
  - 팀 관리 (`/api/teams`)
  - 파일 업로드 (`/api/uploads`)
- ✅ **보안**: Seed 엔드포인트를 개발 환경에서만 활성화

### iOS 앱
- ✅ **서버 연결 설정**: 맥 IP (172.30.1.76:3000)으로 변경
- ✅ **네트워크 레이어**: APIService로 모든 API 호출 구현
- ✅ **매칭 조회**: getMatches() 함수 구현 완료
- 🚧 **로컬 서버 데이터 표시**: 아직 목데이터만 표시 중
- 🚧 **매치 생성**: SecondTeamRecruitmentViewController에서 호출 준비 완료

## 즉시 해결해야 할 문제

### 1. iOS 앱이 로컬 서버에 접근 가능한지 확인
**상태**: 미확인
**확인 방법**:
- iOS 시뮬레이터에서 앱 실행
- MainViewController 로딩 시 서버 데이터 표시 여부 확인
- 콘솔 로그에서 네트워크 에러 메시지 확인

**예상 문제**:
- iOS 시뮬레이터가 172.30.1.76:3000 접근 불가
- 해결책: 다른 IP 또는 localhost 대체 방법 필요

### 2. 매치 생성 시 서버 저장 확인
**상태**: 구현됨, 미테스트
**필요 작업**:
- SecondTeamRecruitmentViewController에서 registerButton 탭
- createMatch API 호출 확인
- 서버 로그에서 성공 메시지 확인
- 데이터베이스에 실제 저장 확인

## 개발 환경 설정

### 로컬 서버 시작
```bash
cd Server
npm run dev
# 결과: 🚀 AllOfSoccer Server is running on port 3000
```

### 목데이터 생성
```bash
curl -X POST http://172.30.1.76:3000/api/matches/seed
```

### 매칭 목록 조회 (테스트)
```bash
curl http://172.30.1.76:3000/api/matches?status=recruiting
```

### 정보
- **맥 IP**: 172.30.1.76
- **서버 포트**: 3000
- **데이터베이스**: PostgreSQL (localhost)
- **캐시**: Redis (localhost)

## 주요 파일 위치

### 백엔드
- 서버 메인: `Server/src/app.js`
- 매칭 API: `Server/src/routes/matches.js`
- 매칭 모델: `Server/src/models/Match.js`
- 환경 변수: `Server/.env`

### iOS 앱
- API 클라이언트: `iOS/AllOfSoccer/Network/APIService.swift`
- 매칭 ViewModel: `iOS/AllOfSoccer/Main/GameMatchingViewModel.swift`
- 매칭 리스트 화면: `iOS/AllOfSoccer/Main/GameMatchingViewController.swift`
- 매칭 등록 1단계: `iOS/AllOfSoccer/Recruitment/TeamRecruitment/FirstTeamRecruitmentViewController.swift`
- 매칭 등록 2단계: `iOS/AllOfSoccer/Recruitment/TeamRecruitment/SecondTeamRecruitmentViewController.swift`

## 다음 작업 순서

### Phase 1: 기본 연결 확인
1. ✅ 로컬 서버 시작
2. ✅ iOS 앱 baseURL 변경
3. 🚧 iOS 시뮬레이터에서 서버 데이터 표시 확인
4. 🚧 네트워크 연결 문제 해결

### Phase 2: 매치 생성 기능 완성
1. 🚧 iOS에서 매치 생성 테스트
2. 🚧 서버 데이터 저장 확인
3. 🚧 에러 메시지 개선
4. 🚧 성공/실패 UI 개선

### Phase 3: 이전 매치 불러오기
1. 🚧 `GET /api/matches/my/created` API 확인
2. 🚧 iOS에서 이전 매치 목록 조회
3. 🚧 목데이터 기반 목록 표시
4. 🚧 목데이터 선택 시 폼 자동 채우기

### Phase 4: 자잘한 버그 수정
1. 필터링 로직 개선
2. 날짜/시간 포맷 통일
3. 에러 핸들링 개선
4. UI/UX 개선

## 알려진 문제

### iOS Compiler Errors
- APIService.swift에서 타입 인식 오류 (Xcode 캐시 문제 가능)
- 해결책: 빌드 폴더 정리 및 재컴파일

### 네트워크 연결
- iOS 시뮬레이터에서 localhost 접근 불가
- 현재 172.30.1.76 IP로 설정 (확인 필요)
- 대체안: 10.0.2.2 (Android), localhost (실제 디바이스)

## 테스트 체크리스트

- [ ] iOS 시뮬레이터 실행
- [ ] MainViewController 로딩 (서버 데이터 표시 여부)
- [ ] 매칭 상세 조회
- [ ] 필터링 기능
- [ ] 매치 생성 (1단계)
- [ ] 매치 생성 (2단계)
- [ ] 매치 등록 및 서버 저장 확인
- [ ] 이전 매치 목록 조회
- [ ] 이전 매치 선택 후 폼 채우기
- [ ] 에러 메시지 표시

## 개발 팁

### 서버 로그 모니터링
```bash
# 터미널에서 계속 실행 중
tail -f /private/tmp/claude-*/tasks/b028d2e.output
```

### iOS 시뮬레이터 네트워크 테스트
```bash
# 시뮬레이터 내에서 curl 테스트 (Console에서)
# 또는 Xcode의 Network Link Conditioner 사용
```

### API 응답 형식
모든 API는 다음 형식으로 응답:
```json
{
  "success": true/false,
  "data": {...} or [...],
  "message": "optional error message",
  "pagination": {...} // 목록 조회 시만
}
```

## 질문 및 결정사항

### 1. 기존 목데이터 유지 여부
- 결정: 서버 목데이터는 유지, seed 엔드포인트는 개발 전용으로 제한
- 이유: 개발 편의성 + 보안

### 2. iOS 앱의 목데이터
- 결정: 서버 연결 실패 시에만 목데이터 표시
- 이유: 실제 서버 데이터를 우선으로 사용

### 3. 인증 처리
- 현재: JWT 토큰 기반 (Apple Sign-In)
- 테스트 시: 임시 토큰 필요 또는 인증 스킵 가능하게 수정
