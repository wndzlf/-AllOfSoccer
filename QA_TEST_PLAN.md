# allOfSoccer QA 테스트 계획

**작성일**: 2026-02-06
**담당**: qa-lead
**버전**: v1.0

---

## 1. 테스트 전략

### 1.1 테스트 레벨

```
┌────────────────────────────────────────────┐
│  E2E 테스트 (End-to-End)                    │  10%
│  - 실제 사용자 시나리오                      │
│  - 전체 흐름 검증                           │
└────────────────────────────────────────────┘
            ↑
┌────────────────────────────────────────────┐
│  통합 테스트 (Integration)                   │  20%
│  - API ↔ DB 상호작용                       │
│  - 컴포넌트 간 통신                         │
└────────────────────────────────────────────┘
            ↑
┌────────────────────────────────────────────┐
│  UI 테스트 (UI/Component)                   │  30%
│  - ViewController 동작                      │
│  - 화면 전환 검증                          │
└────────────────────────────────────────────┘
            ↑
┌────────────────────────────────────────────┐
│  단위 테스트 (Unit)                         │  40%
│  - 비즈니스 로직                            │
│  - 함수/메서드                              │
└────────────────────────────────────────────┘
```

### 1.2 테스트 도구

#### iOS
- **XCTest**: 단위 & UI 테스트
- **XCUITest**: 자동화된 UI 테스트
- **Swift Testing**: 신 테스트 프레임워크 (iOS 18+)

#### 백엔드
- **Jest**: 단위 테스트
- **Supertest**: HTTP 통합 테스트
- **Sequelize Test Utilities**: ORM 테스트

---

## 2. iOS 테스트 계획

### 2.1 팀 매칭 기능 테스트

#### TC-001: 필터 없음 상태에서 모든 매칭 표시

**사전 조건:**
- 앱 설치 및 로그인 완료
- 백엔드 데이터 5개 이상의 매칭 존재

**테스트 케이스:**
```swift
func testLoadAllMatches() {
  // Given: 필터가 적용되지 않은 상태
  let viewModel = TeamMatchViewModel()

  // When: 화면 로드
  viewModel.fetchMatches(filters: .default)

  // Then: 모든 매칭이 표시됨
  XCTAssertGreaterThanOrEqual(viewModel.matches.count, 5)
  XCTAssertTrue(viewModel.isLoading == false)
}
```

**예상 결과:**
- ✅ 매칭 목록 표시됨
- ✅ 로딩 표시기 사라짐
- ✅ 각 항목이 올바르게 표시됨

**테스트 환경:**
- iOS 15+
- iPhone 12/13/14/15

---

#### TC-002: 위치 필터 동작 확인

**테스트 케이스:**
```swift
func testFilterByLocation() {
  // Given: 팀 매칭 화면
  let vc = TeamMatchViewController()
  vc.loadViewIfNeeded()

  // When: 위치 필터 "강남구" 선택
  viewModel.applyFilter(.location("강남구"))

  // Then: 강남구 매칭만 표시
  let filtered = viewModel.matches
  XCTAssert(filtered.allSatisfy { $0.location.contains("강남구") })
  XCTAssertLessThan(filtered.count, originalCount)
}
```

**테스트 데이터:**
```
입력: location = "강남구"
예상 결과: 강남구 관련 매칭 3개 반환
```

---

#### TC-003: 날짜 범위 필터 확인

**테스트 케이스:**
```swift
func testFilterByDateRange() {
  // Given: 오늘부터 7일 후까지의 범위
  let startDate = Date()
  let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!

  // When: 날짜 필터 적용
  viewModel.applyFilter(.dateRange(startDate...endDate))

  // Then: 범위 내의 매칭만 표시
  let filtered = viewModel.matches
  XCTAssert(filtered.allSatisfy { matchDate in
    matchDate >= startDate && matchDate <= endDate
  })
}
```

---

#### TC-004: 다중 필터 조합

**테스트 케이스:**
```swift
func testMultipleFiltersApplied() {
  // Given: 여러 필터 선택
  let filters = MatchFilter(
    location: "강남",
    genderType: "mixed",
    skillLevel: "intermediate",
    feeMax: 10000
  )

  // When: 필터 적용
  viewModel.applyFilter(filters)

  // Then: 모든 필터 조건을 만족하는 매칭만 표시
  let filtered = viewModel.matches
  XCTAssert(filtered.allSatisfy { match in
    match.location.contains("강남") &&
    match.genderType == "mixed" &&
    match.skillLevel >= "intermediate" &&
    match.fee <= 10000
  })
}
```

---

#### TC-005: 페이지네이션 동작

**테스트 케이스:**
```swift
func testPaginationLoading() {
  // Given: 첫 페이지 로드됨 (20개 항목)
  let firstPageCount = viewModel.matches.count
  XCTAssertEqual(firstPageCount, 20)

  // When: 스크롤하여 다음 페이지 로드
  viewModel.loadNextPage()

  // Then: 추가 항목 로드됨
  DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    XCTAssertGreaterThan(self.viewModel.matches.count, firstPageCount)
  }
}
```

---

#### TC-006: 상세 화면 이동

**UI 테스트:**
```swift
func testNavigationToDetailScreen() {
  let app = XCUIApplication()
  app.launch()

  // When: 매칭 항목 탭
  app.tables.cells.element(boundBy: 0).tap()

  // Then: 상세 화면으로 이동
  let detailTitle = app.navigationBars["팀 매치 상세"]
  XCTAssert(detailTitle.exists)
}
```

---

#### TC-007: 즐겨찾기(좋아요) 토글

**테스트 케이스:**
```swift
func testToggleFavorite() {
  // Given: 매칭 항목 화면
  let initialState = viewModel.isFavorite(at: 0)

  // When: 하트 버튼 탭
  viewModel.toggleFavorite(at: 0)

  // Then: 상태 변경됨
  let newState = viewModel.isFavorite(at: 0)
  XCTAssertNotEqual(initialState, newState)

  // And: 백엔드에 저장됨
  XCTAssertEqual(viewModel.favoriteStatus[0], newState)
}
```

---

### 2.2 용병 모집 기능 테스트

#### TC-008: 캘린더 날짜 선택

**테스트 케이스:**
```swift
func testCalendarDateSelection() {
  // Given: 캘린더 뷰 표시됨
  let vc = MercenaryMatchViewController()
  vc.loadViewIfNeeded()

  // When: 15일 날짜 탭
  let calendar = vc.horizontalCalendarView
  calendar.selectDate(15)

  // Then: 선택된 날짜가 강조됨
  let selectedCell = calendar.cellForItem(at: IndexPath(item: 15, section: 0))
  XCTAssertEqual(selectedCell?.backgroundColor, UIColor.black)
}
```

---

#### TC-009: 필터 적용 및 초기화

**테스트 케이스:**
```swift
func testFilterApplyAndReset() {
  // Given: 필터 패널 열림
  viewModel.showFilterPanel()

  // When: 위치와 실력 필터 선택
  viewModel.applyFilter(.position("DF"))
  viewModel.applyFilter(.skillLevel("advanced"))

  // Then: 필터 태그 표시됨
  XCTAssertEqual(viewModel.activeTags.count, 2)

  // When: 초기화 버튼 탭
  viewModel.resetFilters()

  // Then: 모든 필터 제거됨
  XCTAssertEqual(viewModel.activeTags.count, 0)
}
```

---

#### TC-010: 필터 상태 지속성

**테스트 케이스:**
```swift
func testFilterStatePersistence() {
  // Given: 필터 적용된 상태
  viewModel.applyFilter(.location("강남"))

  // When: 다른 화면 이동 후 돌아옴
  let navVC = UINavigationController(rootViewController: vc)
  navVC.pushViewController(detailVC, animated: true)
  navVC.popViewController(animated: true)

  // Then: 필터가 유지됨
  XCTAssertTrue(viewModel.filters.contains { $0.type == .location })
}
```

---

### 2.3 팀 모집 기능 테스트

#### TC-011: 1단계 폼 유효성 검사

**테스트 케이스:**
```swift
func testFirstStepValidation() {
  let vc = FirstTeamRecruitmentViewController()

  // Given: 필수 필드가 비어있음
  let isValid = vc.validateFirstStep()
  XCTAssertFalse(isValid)

  // When: 필수 필드 입력
  vc.dateTextField.text = "2026-03-01"
  vc.locationTextField.text = "강남구"
  vc.feeTextField.text = "5000"

  // Then: 유효성 검사 통과
  XCTAssertTrue(vc.validateFirstStep())
}
```

---

#### TC-012: 1단계에서 2단계로 전환

**테스트 케이스:**
```swift
func testStageTransition() {
  // Given: 1단계 완료
  fillFirstStepForm()

  // When: 다음 버튼 탭
  vc.nextButton.tap()

  // Then: 2단계 화면 표시
  XCTAssert(vc.presentedViewController is SecondTeamRecruitmentViewController)
}
```

---

#### TC-013: 2단계 모든 필드 입력 및 제출

**테스트 케이스:**
```swift
func testSecondStepSubmission() {
  let vc = SecondTeamRecruitmentViewController()

  // Given: 1단계 데이터 전달됨
  vc.matchData = getFirstStepData()

  // When: 모든 필드 입력
  vc.teamNameTextField.text = "FC Seoul"
  vc.ageSlider.selectedMinimum = 20
  vc.ageSlider.selectedMaximum = 50
  vc.skillSlider.value = 5
  vc.contactTextField.text = "01012345678"
  vc.informationCheckButton.isSelected = true

  // When: 등록 버튼 탭
  vc.registerButton.tap()

  // Then: API 호출됨
  wait(for: [apiCallExpectation], timeout: 2.0)
}
```

---

#### TC-014: 이전 매칭 불러오기

**테스트 케이스:**
```swift
func testLoadPreviousMatching() {
  // Given: "이전 경기 불러오기" 버튼 표시됨
  let vc = FirstTeamRecruitmentViewController()
  vc.loadViewIfNeeded()

  // When: 버튼 탭
  vc.callPreviousButton.tap()

  // Then: 템플릿 선택 모달 열림
  XCTAssert(vc.presentedViewController is MatchTemplateViewController)

  // And: 최근 템플릿 표시됨
  let templateVC = vc.presentedViewController as! MatchTemplateViewController
  XCTAssertGreaterThan(templateVC.templates.count, 0)
}
```

---

### 2.4 에러 처리 테스트

#### TC-015: 네트워크 오류 처리

**테스트 케이스:**
```swift
func testNetworkErrorHandling() {
  // Given: 네트워크 연결 안 됨
  mockNetworkSession.simulateNetworkError()

  // When: 매칭 조회
  viewModel.fetchMatches()

  // Then: 에러 알림 표시
  DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    XCTAssert(self.vc.presentedViewController is UIAlertController)
    let alert = self.vc.presentedViewController as! UIAlertController
    XCTAssert(alert.title?.contains("네트워크 오류") ?? false)
  }
}
```

---

#### TC-016: 서버 에러 처리

**테스트 케이스:**
```swift
func testServerErrorHandling() {
  // Given: 서버가 500 에러 반환
  mockNetworkSession.statusCode = 500

  // When: 폼 제출
  vc.submitForm()

  // Then: 사용자 친화적 에러 메시지 표시
  let alert = getLastAlert()
  XCTAssert(alert.message?.contains("다시 시도하세요") ?? false)
}
```

---

### 2.5 성능 테스트

#### TC-017: 대량 데이터 렌더링

**테스트 케이스:**
```swift
func testLargeDatasetPerformance() {
  // Given: 1000개의 매칭 데이터
  viewModel.matches = generateMockMatches(count: 1000)

  // When: 테이블 뷰 렌더링
  let startTime = Date()
  tableView.reloadData()
  let duration = Date().timeIntervalSince(startTime)

  // Then: 1초 이내에 렌더링 완료
  XCTAssertLessThan(duration, 1.0)
}
```

---

#### TC-018: 메모리 누수 감지

**테스트 케이스:**
```swift
func testMemoryLeakDetection() {
  // Given: ViewController 할당
  let vc = MercenaryMatchViewController()

  // When: 화면 표시 및 해제 반복 10회
  for _ in 0..<10 {
    showViewController(vc)
    dismissViewController(vc)
  }

  // Then: 메모리 사용량 증가하지 않음
  let finalMemory = getMemoryUsage()
  XCTAssertLessThan(finalMemory, initialMemory + 10_000_000)
  // 10MB 이상 증가하면 실패
}
```

---

## 3. 백엔드 API 테스트

### 3.1 팀 매칭 API 테스트

#### BT-001: 필터 없음 조회

**테스트:**
```javascript
describe('GET /api/matches', () => {
  it('should return all active matches without filters', async () => {
    const res = await request(app)
      .get('/api/matches')
      .expect(200);

    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.pagination).toHaveProperty('total');
  });
});
```

---

#### BT-002: 위치 필터

**테스트:**
```javascript
it('should filter matches by location (case-insensitive)', async () => {
  const res = await request(app)
    .get('/api/matches?location=강남')
    .expect(200);

  expect(res.body.data).toHaveLength(3);
  res.body.data.forEach(match => {
    expect(match.location.toLowerCase()).toContain('강남');
  });
});
```

---

#### BT-003: 날짜 필터

**테스트:**
```javascript
it('should filter matches by date (gte)', async () => {
  const futureDate = new Date();
  futureDate.setDate(futureDate.getDate() + 7);

  const res = await request(app)
    .get(`/api/matches?date=${futureDate.toISOString()}`)
    .expect(200);

  res.body.data.forEach(match => {
    expect(new Date(match.date).getTime())
      .toBeGreaterThanOrEqual(futureDate.getTime());
  });
});
```

---

#### BT-004: 다중 필터 조합

**테스트:**
```javascript
it('should apply multiple filters correctly', async () => {
  const res = await request(app)
    .get('/api/matches?location=강남&match_type=6v6&gender_type=mixed&fee_min=0&fee_max=10000')
    .expect(200);

  res.body.data.forEach(match => {
    expect(match.location).toContain('강남');
    expect(match.match_type).toBe('6v6');
    expect(match.gender_type).toBe('mixed');
    expect(match.fee).toBeLessThanOrEqual(10000);
  });
});
```

---

#### BT-005: 페이지네이션

**테스트:**
```javascript
it('should paginate results correctly', async () => {
  const res = await request(app)
    .get('/api/matches?page=1&limit=5')
    .expect(200);

  expect(res.body.data).toHaveLength(5);
  expect(res.body.pagination.page).toBe(1);
  expect(res.body.pagination.limit).toBe(5);

  const res2 = await request(app)
    .get('/api/matches?page=2&limit=5')
    .expect(200);

  expect(res2.body.pagination.page).toBe(2);
});
```

---

#### BT-006: 매칭 생성

**테스트:**
```javascript
it('should create a new match', async () => {
  const res = await request(app)
    .post('/api/matches')
    .set('Authorization', `Bearer ${token}`)
    .send({
      title: 'Test Match',
      date: new Date(),
      location: '강남',
      match_type: '6v6',
      gender_type: 'mixed',
      fee: 5000,
      team_name: 'Test Team'
    })
    .expect(201);

  expect(res.body.success).toBe(true);
  expect(res.body.data.id).toBeDefined();
});
```

---

#### BT-007: 매칭 신청

**테스트:**
```javascript
it('should apply to a match', async () => {
  const matchId = testMatch.id;
  const userId = testUser.id;

  const res = await request(app)
    .post(`/api/matches/${matchId}/apply`)
    .set('Authorization', `Bearer ${token}`)
    .expect(200);

  const participant = await MatchParticipant.findOne({
    where: { match_id: matchId, user_id: userId }
  });

  expect(participant).toBeDefined();
  expect(participant.status).toBe('pending');
});
```

---

### 3.2 용병 모집 API 테스트

#### BT-008: 필터 패리티 확인

**테스트:**
```javascript
describe('GET /api/mercenary-requests with parity filters', () => {
  it('should filter by match_type', async () => {
    const res = await request(app)
      .get('/api/mercenary-requests?match_type=6v6')
      .expect(200);

    res.body.data.forEach(request => {
      expect(request.match_type).toBe('6v6');
    });
  });

  it('should filter by gender_type', async () => {
    const res = await request(app)
      .get('/api/mercenary-requests?gender_type=female')
      .expect(200);

    res.body.data.forEach(request => {
      expect(request.gender_type).toBe('female');
    });
  });

  it('should filter by age_range', async () => {
    const res = await request(app)
      .get('/api/mercenary-requests?age_min=20&age_max=40')
      .expect(200);

    // 검증 로직...
  });
});
```

---

#### BT-009: 용병 신청 및 승인

**테스트:**
```javascript
it('should accept a mercenary applicant', async () => {
  // 1. 신청 생성
  const applyRes = await request(app)
    .post(`/api/mercenary-requests/${mercenaryId}/apply`)
    .set('Authorization', `Bearer ${playerToken}`)
    .expect(200);

  const applicationId = applyRes.body.data.id;

  // 2. 팀장이 신청 승인
  const acceptRes = await request(app)
    .post(`/api/mercenary-requests/${mercenaryId}/accept/${playerId}`)
    .set('Authorization', `Bearer ${captainToken}`)
    .expect(200);

  expect(acceptRes.body.success).toBe(true);

  // 3. 상태 확인
  const application = await MercenaryMatch.findByPk(applicationId);
  expect(application.status).toBe('accepted');
});
```

---

### 3.3 데이터 일관성 테스트

#### BT-010: Soft Delete 확인

**테스트:**
```javascript
it('should not return soft-deleted matches', async () => {
  // 1. 매칭 생성
  const match = await Match.create({...});

  // 2. Soft delete
  await match.update({ is_active: false });

  // 3. 조회 시 나타나지 않아야 함
  const res = await request(app)
    .get('/api/matches')
    .expect(200);

  const matchIds = res.body.data.map(m => m.id);
  expect(matchIds).not.toContain(match.id);
});
```

---

#### BT-011: 참가자 수 동기화

**테스트:**
```javascript
it('should keep current_participants in sync', async () => {
  const match = await Match.create({...});

  // 초기값
  expect(match.current_participants).toBe(0);

  // 신청 1: +1
  await MatchParticipant.create({
    match_id: match.id,
    user_id: userId1
  });
  await match.reload();
  expect(match.current_participants).toBe(1);

  // 신청 2: +1
  await MatchParticipant.create({
    match_id: match.id,
    user_id: userId2
  });
  await match.reload();
  expect(match.current_participants).toBe(2);
});
```

---

### 3.4 성능 테스트

#### BT-012: 대량 데이터 조회 성능

**테스트:**
```javascript
it('should query 10000 matches within 1 second', async () => {
  // 1. 테스트 데이터 생성 (10,000개)
  const startTime = Date.now();

  const res = await request(app)
    .get('/api/matches?page=1&limit=100')
    .expect(200);

  const duration = Date.now() - startTime;

  // 1초 이내 응답
  expect(duration).toBeLessThan(1000);
  expect(res.body.data).toHaveLength(100);
});
```

---

#### BT-013: 쿼리 성능 (복합 필터)

**테스트:**
```javascript
it('should handle complex filters efficiently', async () => {
  const startTime = Date.now();

  const res = await request(app)
    .get('/api/matches?location=강남&date=2026-03-01&match_type=6v6&gender_type=mixed&fee_max=10000&skill_level=intermediate')
    .expect(200);

  const duration = Date.now() - startTime;

  // 500ms 이내
  expect(duration).toBeLessThan(500);
});
```

---

## 4. 통합 테스트

### IT-001: 팀 매칭 전체 플로우

**시나리오:**
```
1. 팀장이 팀 매칭 생성 (이름: "FC Test")
2. 선수가 매칭 조회 (필터: 강남, 6v6)
3. 선수가 매칭 신청
4. 팀장이 선수 확인
5. 팀장이 선수 승인
6. 매칭이 가득참 상태로 변경
```

**테스트 코드:**
```swift
func testTeamMatchingFlow() {
  // 1. 팀장 로그인
  loginAs(.captain)

  // 2. 팀 매칭 생성
  let matchId = createTeamMatch(
    location: "강남",
    matchType: "6v6",
    maxParticipants: 6
  )

  // 3. 선수 로그인
  loginAs(.player)

  // 4. 매칭 검색
  searchMatches(filter: .location("강남"), .matchType("6v6"))
  XCTAssertTrue(matchIsInResults(matchId))

  // 5. 매칭 신청
  applyToMatch(matchId)
  XCTAssertEqual(getApplicationStatus(), "pending")

  // 6. 팀장으로 돌아와서 승인
  loginAs(.captain)
  approveApplication(matchId, playerId: playerUUID)

  // 7. 상태 확인
  let match = getMatch(matchId)
  XCTAssertEqual(match.currentParticipants, 1)
  XCTAssertEqual(getApplicationStatus(), "approved")
}
```

---

### IT-002: 용병 모집 전체 플로우

**시나리오:**
```
1. 팀장이 용병 모집 공고 생성
2. 선수가 용병 모집 검색 (필터 적용)
3. 선수가 용병 신청
4. 팀장이 선수 조회
5. 팀장이 선수 승인
6. 신청자 수 증가
```

---

## 5. 버그 체크리스트

### 심각도: 🔴 높음

- [ ] **BUG-001**: TeamMatchViewController가 API 미연동
  - 현상: 샘플 데이터만 표시
  - 영향: 기능 미작동
  - 우선순위: P0 (즉시)

- [ ] **BUG-002**: Age 필터 로직 오류
  - 현상: 나이 범위 필터가 정확하지 않음
  - 영향: 검색 부정확
  - 우선순위: P0 (높음)

- [ ] **BUG-003**: 용병 필터 불완전
  - 현상: match_type, gender_type, shoes_requirement 필터 없음
  - 영향: 필터 기능 부족
  - 우선순위: P1 (높음)

### 심각도: 🟡 중간

- [ ] **BUG-004**: 파일명 오타
  - 현상: `CallPreviusMatchingInformationView` (Previus → Previous)
  - 영향: 코드 유지보수 어려움
  - 우선순위: P2

- [ ] **BUG-005**: 하드코딩된 색상
  - 현상: UIColor(red: 0.2, green: 0.6, blue: 1.0) 등 매직 숫자
  - 영향: 디자인 시스템 미준수
  - 우선순위: P3

### 심각도: 🟢 낮음

- [ ] **BUG-006**: 테스트 커버리지 부족
  - 현상: 1개 테스트 파일만 존재
  - 영향: 회귀 테스트 불가
  - 우선순위: P4

---

## 6. 테스트 실행 일정

| 주차 | 작업 | 담당 | 완료일 |
|------|------|------|--------|
| 1주 | 단위 테스트 (iOS) | ios-developer | 2026-02-13 |
| 1주 | 단위 테스트 (BE) | server-developer | 2026-02-13 |
| 2주 | 통합 테스트 | qa-lead | 2026-02-20 |
| 2주 | UI 테스트 | ios-developer | 2026-02-20 |
| 3주 | E2E 테스트 | qa-lead | 2026-02-27 |
| 3주 | 성능 테스트 | qa-lead | 2026-02-27 |
| 4주 | 회귀 테스트 | qa-lead | 2026-03-06 |

---

## 7. 테스트 성공 기준

### iOS 앱
- ✅ 모든 단위 테스트 통과 (100% 필수 로직)
- ✅ 주요 UI 플로우 테스트 통과 (화면 전환, 데이터 표시)
- ✅ 메모리 누수 없음
- ✅ 성능: 대량 데이터 1초 내 렌더링

### 백엔드 API
- ✅ 모든 필터링 로직 정확성 검증
- ✅ 다중 필터 조합 동작 확인
- ✅ 페이지네이션 정확성
- ✅ 데이터 일관성 보장
- ✅ 성능: 복합 쿼리 500ms 이내

### 통합
- ✅ E2E 주요 시나리오 통과
- ✅ 에러 처리 일관성
- ✅ 데이터 동기화

---

**문서 작성**: qa-lead
**최종 검토**: 필요
**테스트 시작**: 2026-02-13
