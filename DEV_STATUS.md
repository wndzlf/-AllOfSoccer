# AllOfSoccer - 현재 개발 진행상황 (2026-02-02)

## 완료된 작업

### 백엔드
- ✅ **로컬 서버 실행**: `npm run dev` (포트 3000)
- ✅ **API 에러 수정**: Sequelize Team relationship 'as' 키워드 추가
- ✅ **매칭 목록 조회**: GET /api/matches 정상 작동
- ✅ **목데이터**: 여러 개의 매칭 데이터 존재
- ✅ **보안**: Seed 엔드포인트를 개발 전용으로 제한

### iOS 앱
- ✅ **서버 연결**: 맥 IP 주소 (172.30.1.76:3000)로 설정
- ✅ **모델 호환성**: Team CodingKey 수정 (createdAt, updatedAt 추가)
- ✅ **네트워크 레이어**: APIService.getMatches() 구현

## 즉시 해결 필요한 항목

### 1. iOS 앱 인증 처리
**문제**: 매칭 생성/조회 시 JWT 토큰 필요
**현재 상태**: APIService에서 Auth.accessToken() 호출
**필요 작업**:
- [ ] Apple Sign-In 구현 또는 테스트 토큰 생성
- [ ] 또는 인증 생략 모드 추가 (개발 환경)

### 2. iOS 시뮬레이터 네트워크 테스트
**상태**: 미확인
**필요 작업**:
- [ ] iOS 시뮬레이터에서 앱 실행
- [ ] MainViewController 로드 시 서버 데이터 표시 확인
- [ ] 콘솔 로그에서 네트워크 에러 확인

### 3. 매칭 생성 기능
**상태**: 구현됨, 미테스트
**필요 작업**:
- [ ] SecondTeamRecruitmentViewController 테스트
- [ ] 데이터베이스 저장 확인
- [ ] 생성된 매칭을 매칭 리스트에서 확인

## 버그 및 개선사항

### 우선 순위: 높음

#### [Bug] iOS 컴파일 에러
- **파일**: iOS/AllOfSoccer/Network/APIService.swift
- **증상**: SourceKit에서 타입 인식 오류 (Xcode 캐시 문제 가능)
- **해결책**: Xcode 재시작 또는 build folder 정리

#### [Bug] iOS Simulator 네트워크 연결
- **파일**: iOS/AllOfSoccer/Network/APIService.swift:14
- **현재**: baseURL = "http://172.30.1.76:3000"
- **문제**: iOS Simulator가 호스트 머신 IP에 접근 불가능할 수 있음
- **대체안**:
  - localhost (실제 디바이스에서만 작동)
  - 10.0.2.2 (Android Emulator에서만 작동)
  - host.docker.internal (Docker에서만 작동)

### 우선 순위: 중간

#### [Feature] 이전 매치 불러오기
- **상태**: API 구현 완료 (GET /api/matches/my/created)
- **iOS 작업**: 아직 미구현
- **필요 파일**:
  - CallPreviusMatchingInformationView.swift
  - FirstTeamRecruitmentViewController.swift

#### [Feature] 매칭 수정
- **상태**: API 구현 완료 (PUT /api/matches/:id)
- **iOS 작업**: 아직 미구현

#### [Feature] 실시간 알림
- **상태**: Socket.io 기본 구조만 있음
- **필요 작업**: 실제 구현

### 우선 순위: 낮음

#### [Improvement] API 응답 형식 문서화
- 모든 엔드포인트의 응답 형식 정의

#### [Improvement] 에러 처리 개선
- 더 구체적인 에러 메시지
- 네트워크 상태에 따른 처리

#### [Improvement] 로딩 상태 표시
- 스피너 또는 스켈레톤 로딩

## 테스트 결과

### API 테스트
```bash
# 매칭 목록 조회 (성공)
curl "http://172.30.1.76:3000/api/matches?page=1&limit=20&status=recruiting"

# 응답:
# {
#   "success": true,
#   "data": [7개의 매칭 데이터],
#   "pagination": {...}
# }
```

### 목데이터
- 기존: 처음 생성한 3개 매칭
- 현재: 총 7개 매칭 (다른 사용자 생성분 포함)
- 상태: 모두 "recruiting"

## 다음 단계 계획

### 이번 주 (2월 2주)
1. iOS Simulator 네트워크 연결 확인
2. 매칭 생성 기능 테스트
3. 로그인 플로우 정리
4. 기본 데이터 표시 확인

### 다음주 (2월 3주)
1. 이전 매치 불러오기 구현
2. 필터링 기능 개선
3. UI/UX 개선

### 3월
1. 실시간 기능 (Socket.io)
2. 결제 시스템
3. 푸시 알림

## 개발 팁 & 트러블슈팅

### 서버 로그 확인
```bash
# 터미널에서 실시간 로그 보기
tail -f /private/tmp/claude-*/tasks/bbe5c2c.output
```

### iOS Simulator 네트워크 디버깅
1. Xcode의 Network Link Conditioner 사용
2. 또는 실제 iOS 디바이스에서 테스트
3. Safari에서 http://172.30.1.76:3000/health 접근 테스트

### API 응답 확인
```bash
# JSON 형식 확인
curl -s "http://172.30.1.76:3000/api/matches?limit=1" | jq .

# 특정 필드만 보기
curl -s "http://172.30.1.76:3000/api/matches?limit=1" | jq '.data[0].team'
```

## 중요 파일 수정 이력

### 2026-02-02
1. **iOS/AllOfSoccer/Network/APIService.swift**
   - baseURL 변경: "http://localhost:3000" → "http://172.30.1.76:3000"

2. **iOS/AllOfSoccer/Network/MatchModels.swift**
   - Match CodingKeys 수정: "Team" → "team"
   - "createdAt", "updatedAt" 매핑 추가

3. **Server/src/routes/matches.js**
   - findAndCountAll include에 'as: "team"' 추가
   - Sequelize 에러 해결

## 문의 및 질문

### Q1: iOS Simulator에서 172.30.1.76에 접근 불가능하면?
**A**: 다음 방법 중 선택:
1. 실제 iOS 디바이스에서 테스트
2. ngrok 같은 터널링 서비스 사용
3. 로컬 네트워크 공유 설정 변경
4. Docker를 사용한 격리된 네트워크 테스트

### Q2: 인증 토큰 없이 테스트할 수 있나?
**A**: 가능한 방법:
1. 미들웨어에서 테스트 모드 추가
2. `NODE_ENV=test` 환경에서 인증 스킵
3. 임시 토큰 생성 엔드포인트 추가 (개발 전용)

### Q3: 목데이터 다시 생성하려면?
**A**:
```bash
curl -X POST http://172.30.1.76:3000/api/matches/seed
```
(개발 환경에서만 작동)
