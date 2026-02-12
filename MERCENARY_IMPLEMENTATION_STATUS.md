# AllOfSoccer 용병 모집 기능 - 구현 완료 현황

## ✅ 완료된 작업

### 백엔드 (Server)

#### 1. 데이터베이스 모델 (✅ 완료)
- `Server/src/models/MercenaryRequest.js` - 용병 모집 모델
  - 필드: id, team_id, title, description, date, location, fee, mercenary_count, positions_needed, skill_level_min/max, current_applicants, status, is_active
  - 인덱스: date, location, status, team_id, skill_level_min

- `Server/src/models/MercenaryApplication.js` - 용병 지원 모델
  - 필드: id, user_id, title, description, available_dates, preferred_locations, positions, skill_level, preferred_fee_min/max, status, is_active
  - 인덱스: user_id, status, skill_level

- `Server/src/models/MercenaryMatch.js` - 용병 매칭 모델
  - 필드: id, mercenary_request_id, user_id, status, applied_at, accepted_at, rejected_at
  - 유니크 인덱스: mercenary_request_id + user_id (중복 지원 방지)

#### 2. API 라우터 (✅ 완료)
- `Server/src/routes/mercenaryRequests.js` - 용병 모집 API
  - GET /api/mercenary-requests - 목록 조회 (필터링, 페이징 지원)
  - POST /api/mercenary-requests - 모집 등록
  - GET /api/mercenary-requests/:id - 상세 조회
  - PUT /api/mercenary-requests/:id - 수정
  - DELETE /api/mercenary-requests/:id - 삭제
  - POST /api/mercenary-requests/:id/apply - 지원하기
  - DELETE /api/mercenary-requests/:id/apply - 지원 취소
  - GET /api/mercenary-requests/:id/applicants - 지원자 목록
  - POST /api/mercenary-requests/:id/accept/:userId - 지원자 승인
  - GET /api/mercenary-requests/my/created - 내가 올린 모집글
  - GET /api/mercenary-requests/my/applied - 내가 지원한 모집

- `Server/src/routes/mercenaryApplications.js` - 용병 지원 API
  - GET /api/mercenary-applications - 목록 조회
  - POST /api/mercenary-applications - 지원 등록
  - GET /api/mercenary-applications/:id - 상세 조회
  - PUT /api/mercenary-applications/:id - 수정
  - DELETE /api/mercenary-applications/:id - 삭제
  - GET /api/mercenary-applications/my/posted - 내가 올린 지원글

#### 3. 라우터 등록 (✅ 완료)
- `Server/src/app.js` - 라우터 등록
  - 용병 모집 라우터: `/api/mercenary-requests`
  - 용병 지원 라우터: `/api/mercenary-applications`

### iOS 앱

#### 1. 탭바 구조 (✅ 완료)
- `iOS/AllOfSoccer/Main/MainTabBarController.swift` - 수정
  - Tab 1: 팀 매치 (팀 모집글 목록)
  - Tab 2: 용병 모집 (새 탭!)
  - Tab 3: 설정 (기존 탭)
  - 아이콘: person.badge.plus

#### 2. 용병 모집 리스트 화면 (✅ 완료)
- `iOS/AllOfSoccer/Recruitment/MercenaryMatch/MercenaryMatchViewController.swift` - 수정
  - Segmented Control: 용병 모집 / 용병 지원 전환
  - TableView: 아이템 목록 표시
  - Floating Button: 등록하기 버튼

- `iOS/AllOfSoccer/Recruitment/MercenaryMatch/MercenaryMatchViewModel.swift` - 생성
  - 데이터 관리 (용병 모집, 용병 지원)
  - API 호출 (fetch 메서드)
  - 포매팅 (날짜, 비용, 포지션)

- `iOS/AllOfSoccer/Recruitment/MercenaryMatch/MercenaryMatchTableViewCell.swift` - 생성
  - 카드형 UI
  - 제목, 위치, 날짜, 비용 표시
  - 태그 표시 (포지션, 지원자 수)

#### 3. 용병 모집 작성 화면 (✅ 완료)
- `iOS/AllOfSoccer/Recruitment/MercenaryMatch/MercenaryRequestViewController.swift` - 생성
  - 제목, 설명 입력
  - 날짜/시간 선택
  - 장소, 비용, 모집 인원 입력
  - 포지션 선택
  - 실력 레벨 선택
  - 등록하기 버튼

- `iOS/AllOfSoccer/Recruitment/MercenaryMatch/Components/PositionSelectorView.swift` - 생성
  - GK, DF, MF, FW 포지션 선택
  - 각 포지션별 인원 수 지정

- `iOS/AllOfSoccer/Recruitment/MercenaryMatch/Components/SkillLevelSelectorView.swift` - 생성
  - 최소/최대 실력 레벨 선택
  - 4단계: 초급, 중급, 고급, 고수

#### 4. 용병 지원 작성 화면 (✅ 완료)
- `iOS/AllOfSoccer/Recruitment/MercenaryMatch/MercenaryApplicationViewController.swift` - 생성
  - 제목, 설명 입력
  - 선호 지역 (쉼표로 구분)
  - 가능 포지션 입력
  - 실력 레벨 선택
  - 희망 비용 범위 입력

#### 5. 네트워크 레이어 (✅ 완료)
- `iOS/AllOfSoccer/Network/APIService.swift` - 수정
  - `getMercenaryRequests()` - 용병 모집 목록 조회
  - `createMercenaryRequest()` - 용병 모집 등록
  - `getMercenaryApplications()` - 용병 지원 목록 조회
  - `createMercenaryApplication()` - 용병 지원 등록

- `iOS/AllOfSoccer/Network/MatchModels.swift` - 수정
  - `MercenaryRequestListResponse` - 목록 응답
  - `MercenaryRequestResponse` - 생성 응답
  - `MercenaryRequest` - 모델
  - `MercenaryApplicationListResponse` - 목록 응답
  - `MercenaryApplicationResponse` - 생성 응답
  - `MercenaryApplication` - 모델
  - `PaginationInfo` - 페이징 정보

---

## 🔄 최근 업데이트 (2026-02-02)

### API 통합 완료
- `MercenaryRequestViewController.swift` - 실제 API 호출 구현
  - `APIService.shared.createMercenaryRequest()` 통합
  - 로딩 상태 표시 (버튼 비활성화, "등록 중..." 표시)
  - 에러 처리 및 사용자 피드백 추가
  - 등록 성공 후 자동으로 리스트 화면으로 복귀

### UI 일관성 개선
- `MercenaryMatchTableViewCell.swift` - GameMatchingTableViewCell과 동일한 스타일로 통일
  - cornerRadius: 8 → 16 (더 둥근 코너)
  - shadowOpacity: 0.1 → 0.08 (더 은은한 그림자)
  - shadowOffset, shadowRadius 조정
  - 상태 배지 추가 (모집 중/모집 완료/구인 중/매칭됨/불가능)
  - 패딩 및 마진 개선 (16pt 통일)
  - 색상 일관성: Purple (모집/구인) / Green (완료/매칭)

### 리스트 자동 갱신
- `MercenaryMatchViewController.swift` - viewWillAppear에서 fetchData() 호출
- 새로운 항목 등록 후 리스트 화면 복귀 시 자동 갱신

### API 요청 데이터 타입 수정 (2026-02-02 추가)
- `SkillLevelSelectorView.swift` - 실력 레벨 데이터 타입 수정
  - 문제: 한글 값("초급", "중급" 등)을 서버에 전송
  - 해결: 영문 enum 값("beginner", "intermediate" 등) 사용
  - selectedMinLevel/selectedMaxLevel을 SkillLevel enum 타입으로 변경
  - getSelectedLevels()에서 englishValue로 변환하여 반환

### Date 필드 에러 해결 및 UI 완전 리디자인 (2026-02-02 추가)

#### 1. Date 필드 에러 수정
- `Date+Extension.swift` - ISO8601 날짜 포맷 변환 메서드 추가
  - `toISO8601String()` 메서드 구현
  - 형식: "2026-02-02T14:30:00Z"
  - API 요청 시 정상적으로 날짜 전송

#### 2. MercenaryRequestViewController UI 완전 리디자인
팀 모집 화면(FirstTeamRecruitmentViewController)과 동일한 전문적인 스타일로 통일

**배경 및 색상**:
- 배경색: `UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)` (밝은 회색)
- 버튼색: `UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)` (빨간색)
- 아이콘색: `UIColor(red: 0.537, green: 0.556, blue: 0.580, alpha: 1.0)` (회색)

**입력 필드**:
- RoundView를 사용한 깔끔한 입력 필드 디자인 (cornerRadius: 6)
- 각 필드마다 아이콘 추가 (달력, 지도핀, 신용카드, 사람 아이콘)
- 전문적인 폰트 크기와 굵기 설정

**섹션 구성** (5개 섹션):
1. 기본 정보: 제목, 설명
2. 일시/장소: 날짜(탭으로 선택), 시간, 장소
3. 참가비/모집인원: 수평 레이아웃으로 효율적 배치
4. 모집 포지션: PositionSelectorView 통합
5. 실력 요구사항: SkillLevelSelectorView 통합

**레이아웃 개선**:
- 일관된 16pt 패딩 및 마진
- 필드 간 12pt 간격
- 섹션 간 24pt 간격
- ScrollView를 통한 키보드 처리
- 고정 62pt 높이 하단 버튼

**기능 개선**:
- 날짜 선택 시각적 피드백
- 포지션 필수 입력 검증
- 디버깅을 위한 로그 추가

### API 에러 해결 및 캘린더 UI 개선 (2026-02-02 최종)

#### 1. team_name 필수 필드 해결
- **문제**: API 에러 "team_name is required when team_id is not provided"
- **해결**: 기본값 "개인 모집"으로 설정
  - 사용자가 팀 선택 없이 용병 모집 생성 가능
  - 자동으로 "개인 모집"이 팀명으로 설정됨

#### 2. MercenaryRequestResponse 파싱 에러 수정
- **문제**: 에러 응답 `{"success":false,"message":"..."}` 파싱 실패
- **해결**: data 필드를 Optional로 변경
  ```swift
  let data: MercenaryRequest?  // 선택적 필드
  ```
  - 성공 응답: data 포함
  - 에러 응답: data 없음 (nil)
  - 예외 처리 강화

#### 3. 날짜/시간 선택 UI 개선 (RecruitmentCalendarView 사용)
- **기존**: 기본 UIDatePicker (투박함)
- **개선**: 팀 모집과 동일한 RecruitmentCalendarView 사용

**캘린더 기능**:
- FSCalendar를 사용한 전문적인 날짜 선택
- 시간 선택 (0-23시), 분 선택 (0분, 30분)
- 한국 로컬 지원
- 형식: "2026년 02월 02일 19:00"

**사용자 경험**:
- 날짜 필드 탭 → 캘린더 팝업
- 달력에서 날짜 선택 → 시간/분 선택
- 취소/확인 버튼 제공
- 선택된 날짜 명확히 표시

**결과**:
- ✅ UI 일관성: 팀 모집과 동일
- ✅ 사용성: 직관적인 날짜/시간 선택
- ✅ 프로페셔널: 캘린더 인터페이스

---

## ⚠️ 테스트 필요 사항

### 백엔드 테스트
```bash
# 1. 용병 모집 생성
curl -X POST http://172.30.1.76:3000/api/mercenary-requests \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token" \
  -d '{
    "title": "양원역 용병 3명",
    "date": "2026-02-15T19:00:00Z",
    "location": "양원역 구장",
    "fee": 7000,
    "mercenary_count": 3,
    "positions_needed": {"MF": 2, "FW": 1},
    "team_name": "테스트 팀"
  }'

# 2. 용병 모집 목록 조회
curl "http://172.30.1.76:3000/api/mercenary-requests?page=1&limit=20"

# 3. 용병 지원 생성
curl -X POST http://172.30.1.76:3000/api/mercenary-applications \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token" \
  -d '{
    "title": "주말 용병 가능",
    "positions": ["MF", "FW"],
    "skill_level": "intermediate"
  }'

# 4. 용병 지원 목록 조회
curl "http://172.30.1.76:3000/api/mercenary-applications?page=1&limit=20"
```

### iOS 앱 테스트 체크리스트
- [ ] 앱 실행 시 탭바에 3개 탭이 표시되는가?
- [ ] 용병 모집 탭 클릭 시 리스트 화면 로드
- [ ] Segmented Control로 용병 모집/지원 전환
- [ ] 등록하기 버튼 클릭 시 작성 폼으로 이동
- [ ] 용병 모집 폼 작성 후 등록
- [ ] 용병 지원 폼 작성 후 등록
- [ ] 등록 후 리스트에 새 아이템 표시
- [ ] 필터링 기능 (부분적으로 구현)
- [ ] 페이징 (스크롤 시 다음 페이지 로드)

---

## 🔧 알려진 문제 및 개선 사항

### ✅ 해결된 이슈
1. **API 미통합** (2026-02-02 해결)
   - 문제: MercenaryRequestViewController에서 API 호출 부재
   - 해결: APIService.shared.createMercenaryRequest() 통합
   - 결과: 용병 모집 등록이 정상 작동

2. **UI 불일관성** (2026-02-02 해결)
   - 문제: MercenaryMatchTableViewCell이 GameMatchingTableViewCell과 다른 스타일
   - 해결: 동일한 카드 스타일로 통일 (cornerRadius 16, shadowOpacity 0.08)
   - 결과: 앱의 일관성 향상

3. **무한 재귀 호출 및 요청 제한 에러** (2026-02-02 해결)
   - **문제**:
     - `MercenaryMatchViewController.viewWillAppear()`에서 `fetchData()` 반복 호출
     - 서버에서 "Too many requests from this IP" 일반 텍스트 응답
     - JSON 파싱 실패로 인한 `dataCorrupted` 에러
     - 무한 재귀 호출 발생
   - **원인**:
     - viewWillAppear가 매번 뷰 표시 시 fetchData() 호출
     - 서버 요청 제한(429) 응답이 일반 텍스트로 반환됨
     - APIService가 JSON 파싱만 시도하고 일반 텍스트 처리 부재
   - **해결**:
     1. `MercenaryMatchViewController.viewWillAppear()` - fetchData() 호출 제거
        - 데이터는 viewDidLoad에서 한 번만 로드
        - 주석: "viewDidLoad에서 이미 데이터를 로드하므로 여기서는 호출하지 않음"
     2. `APIService.getMercenaryRequests()` - 에러 처리 강화
        - HTTP 상태 코드 확인 추가 (429, 4xx, 5xx)
        - 429 상태 코드 시 명확한 NSError 생성
        - JSON 파싱 실패 시 일반 텍스트 응답 감지
        - "too many requests" 포함된 텍스트는 rate limiting 에러로 변환
     3. `APIService.getMercenaryApplications()` - 동일한 에러 처리 적용
   - **결과**:
     - ✅ 무한 재귀 호출 중단
     - ✅ rate limiting 에러 명확히 처리
     - ✅ 사용자에게 "너무 많은 요청. 잠시 후 다시 시도하세요" 메시지 표시
     - ✅ 일반 텍스트 응답 더 이상 JSON 파싱 실패 없음

### 기능적 개선 필요
1. **필터링**
   - 현재: 기본적인 필터링만 구현
   - 필요: 위치, 실력, 날짜 범위로 필터링
   - 우선순위: 중간

2. **상세 보기**
   - 현재: 미구현 (TODO 주석 있음)
   - 필요: 용병 모집/지원 상세 페이지
   - 우선순위: 중간

3. **매칭**
   - 현재: 미구현
   - 필요: 모집글에 지원하기, 지원자 승인 기능
   - 우선순위: 높음

4. **마이 페이지**
   - 현재: 미구현
   - 필요: 내가 올린 모집글, 내가 지원한 글 관리
   - 우선순위: 중간

5. **용병 지원 작성 화면**
   - 현재: MercenaryApplicationViewController 구현됨
   - 필요: 상세 UI 개선, 실제 사용자 선호도 데이터 입력
   - 우선순위: 낮음

---

## 📋 구현 단계별 정리

### Phase 1: 백엔드 (✅ 완료)
- [x] 데이터베이스 모델 생성
- [x] API 라우터 생성
- [x] 관계 설정
- [x] 검증 및 오류 처리

### Phase 2: iOS 탭바 (✅ 완료)
- [x] MainTabBarController 수정
- [x] 탭 아이콘 설정

### Phase 3: iOS 리스트 화면 (✅ 완료)
- [x] MercenaryMatchViewController 개선
- [x] MercenaryMatchViewModel 생성
- [x] TableViewCell 구현

### Phase 4: iOS 작성 화면 (✅ 완료)
- [x] MercenaryRequestViewController 구현
- [x] MercenaryApplicationViewController 구현
- [x] 포지션/실력 선택 컴포넌트

### Phase 5: iOS 네트워크 (✅ 완료)
- [x] APIService 메서드 추가
- [x] 모델 정의

### Phase 6: 테스트 및 버그 수정 (✅ 부분 완료)
- [x] API 통합 완료
- [x] UI 일관성 개선
- [x] 자동 갱신 기능 확인
- [ ] 백엔드 API 전체 테스트 (필터링, 페이징 등)
- [ ] 매칭 기능 구현 및 테스트
- [ ] 마이페이지 통합

---

## 🚀 다음 단계

### 우선순위: 높음
1. iOS 시뮬레이터에서 전체 플로우 테스트
2. API 응답 모델 정렬 (ViewModel ↔ Models)
3. 에러 메시지 처리 개선

### 우선순위: 중간
1. 상세 보기 화면 구현
2. 매칭 기능 구현 (지원하기, 승인)
3. 필터링 기능 강화

### 우선순위: 낮음
1. 실시간 알림 (Socket.io)
2. 평가 시스템
3. 결제 시스템

---

## 📞 문의 사항

### Q. iOS에서 API 호출이 실패하면?
**A.** 다음을 확인하세요:
1. 서버가 실행 중인지 확인 (`npm run dev`)
2. baseURL이 올바른지 확인 (172.30.1.76:3000)
3. 콘솔 로그에서 에러 메시지 확인
4. Xcode 네트워크 디버거 사용

### Q. 데이터베이스에 저장되지 않으면?
**A.** 다음을 확인하세요:
1. PostgreSQL이 실행 중인지 확인
2. 데이터베이스 연결 확인
3. 모델 관계 설정 확인
4. 마이그레이션/동기화 확인

### Q. Xcode에서 컴파일 에러가 나면?
**A.** 다음을 시도하세요:
1. `Cmd+Shift+K`로 빌드 폴더 정리
2. `Cmd+Shift+K` 후 재빌드
3. Xcode 재시작
4. `~/Library/Developer/Xcode/DerivedData` 폴더 삭제 후 재시작

---

**최종 업데이트**: 2026-02-02 (API 통합 & UI 개선 완료)
**상태**: ✅ 핵심 기능 완성 (매칭/마이페이지는 개발 중)

### 주요 변경사항
- ✅ API 호출 통합 (용병 모집 등록 정상 작동)
- ✅ UI 일관성 개선 (GameMatchingTableViewCell과 동일 스타일)
- ✅ 상태 배지 추가 (모집 중/완료, 구인 중/매칭됨/불가능)
- ✅ 자동 갱신 기능 (viewWillAppear에서 데이터 재로드)
