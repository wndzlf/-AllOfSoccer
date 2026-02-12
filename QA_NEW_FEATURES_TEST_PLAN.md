# 새로운 기능 검증 계획

**작성일**: 2026-02-06
**담당**: qa-lead
**대상 기능**: 용병 상세화면, 사용자 프로필, 내 글 조회, 관심 글 조회
**예상 테스트 기간**: 2-3시간

---

## 개요

### 검증할 기능 (4개)

1. **용병 모집 상세 화면** - iOS UI + 백엔드 API
2. **사용자 프로필 등록/관리** - iOS UI + 백엔드 API + 이미지 업로드
3. **내가 쓴 글 조회** - iOS UI + 백엔드 API
4. **관심 글 조회** - iOS UI + 백엔드 API + 좋아요 기능

### 총 테스트 케이스

- **iOS UI 테스트**: 18개
- **백엔드 API 테스트**: 12개
- **통합 테스트**: 4개
- **총 28개 테스트 케이스**

---

## 1. 용병 모집 상세 화면

### 기능 설명
사용자가 용병 목록에서 특정 용병 모집 항목을 선택하면, 상세 정보를 보여주는 화면입니다.

### 필요한 백엔드 API

#### API-MER-001: GET /api/mercenary-requests/:id
```
엔드포인트: GET /api/mercenary-requests/{requestId}
인증: 필수 (JWT)
응답:
{
  "success": true,
  "data": {
    "id": "uuid",
    "team_id": "uuid",
    "team": {
      "name": "FC Test",
      "captain": {
        "id": "uuid",
        "name": "팀장",
        "profile_image": "..."
      }
    },
    "title": "용병 모집",
    "description": "용병 모집 설명",
    "date": "2026-03-01T19:00:00Z",
    "location": "강남",
    "address": "강남대로 123",
    "latitude": 37.4979,
    "longitude": 127.0276,
    "fee": 50000,
    "mercenary_count": 2,
    "positions_needed": ["FW", "MF"],
    "skill_level_min": "intermediate",
    "skill_level_max": "expert",
    "current_applicants": 3,
    "status": "recruiting",
    "created_at": "2026-02-06T10:00:00Z",
    "match_type": "11v11",
    "gender_type": "mixed",
    "shoes_requirement": "soccer"
  }
}
```

#### API-MER-002: POST /api/mercenary-requests/:id/apply
```
엔드포인트: POST /api/mercenary-requests/{requestId}/apply
인증: 필수 (JWT)
요청: {}
응답:
{
  "success": true,
  "data": {
    "id": "uuid",
    "mercenary_request_id": "uuid",
    "user_id": "uuid",
    "status": "pending",
    "created_at": "2026-02-06T10:00:00Z"
  },
  "message": "신청이 완료되었습니다"
}
```

#### API-MER-003: DELETE /api/mercenary-requests/:id/apply
```
엔드포인트: DELETE /api/mercenary-requests/{requestId}/apply
인증: 필수
응답:
{
  "success": true,
  "message": "신청이 취소되었습니다"
}
```

### iOS 테스트 케이스

#### TC-MER-001: 용병 목록에서 상세 화면으로 이동

**사전 조건:**
- 용병 목록 화면 표시됨
- 최소 1개 이상의 용병 모집 항목 있음

**테스트 단계:**
```swift
// 1. 용병 모집 셀 탭
let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
cell.tap()

// 2. 네비게이션 확인
XCTAssert(navigationController?.topViewController is MercenaryDetailViewController)

// 3. 상세 화면 데이터 로드 확인
let detailVC = navigationController?.topViewController as! MercenaryDetailViewController
XCTAssertTrue(detailVC.viewModel.isLoading == true initially)

// 4. API 호출 대기
wait(for: [apiCallExpectation], timeout: 2.0)

// 5. UI 업데이트 확인
XCTAssertTrue(detailVC.viewModel.isLoading == false)
XCTAssertNotNil(detailVC.viewModel.mercenaryRequest)
```

**예상 결과:**
- ✅ 상세 화면으로 네비게이션
- ✅ 로딩 표시기 표시
- ✅ API 호출 성공
- ✅ 데이터 로드됨

**검증 포인트:**
- 정확한 mercenary request ID 전달
- API 응답이 정확한 형식
- UI 상태 변화가 부드러움

---

#### TC-MER-002: 상세 정보 정확성 검증

**테스트 단계:**
```swift
let request = viewModel.mercenaryRequest

// 위치 정보 확인
XCTAssertEqual(locationLabel.text, request.location)
XCTAssertEqual(addressLabel.text, request.address)

// 날짜/시간 확인
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
let expectedDate = dateFormatter.string(from: request.date)
XCTAssertEqual(dateLabel.text, expectedDate)

// 경기 정보 확인
XCTAssertEqual(matchTypeLabel.text, request.match_type) // "11v11"
XCTAssertEqual(genderTypeLabel.text, request.gender_type) // "혼성"
XCTAssertEqual(shoesLabel.text, request.shoes_requirement) // "축구화"

// 팀 정보 확인
XCTAssertEqual(teamNameLabel.text, request.team.name)
XCTAssertEqual(captainLabel.text, request.team.captain.name)

// 신청 정보 확인
XCTAssertEqual(applicantsCountLabel.text, "현재 신청: 3명")
XCTAssertEqual(requiredCountLabel.text, "필요 인원: 2명")

// 포지션 정보 확인
let positionsText = request.positions_needed.joined(separator: ", ")
XCTAssertEqual(positionsLabel.text, positionsText) // "FW, MF"

// 비용 정보 확인
XCTAssertEqual(feeLabel.text, "50,000원")

// 실력 정보 확인
XCTAssertEqual(skillLevelLabel.text, "중급 ~ 고급")
```

**예상 결과:**
- ✅ 모든 정보가 정확하게 표시됨
- ✅ 날짜 포맷이 일관됨
- ✅ 숫자가 콤마로 포맷됨 (50,000)

**검증 포인트:**
- 날짜 타임존 처리
- 숫자 포맷팅 (통화, 숫자 구분)
- 텍스트 길이 제한 (overflow 없음)

---

#### TC-MER-003: 신청(Apply) 버튼 동작

**테스트 단계:**
```swift
// 1. Apply 버튼 상태 확인
let applyButton = detailVC.applyButton
XCTAssertEqual(applyButton.title(for: .normal), "신청하기")
XCTAssertTrue(applyButton.isEnabled)

// 2. Apply 버튼 탭
applyButton.sendActions(for: .touchUpInside)

// 3. 로딩 표시기 확인
XCTAssertTrue(detailVC.isLoadingApply)

// 4. API 호출 확인 및 대기
wait(for: [applyAPIExpectation], timeout: 2.0)

// 5. 성공 알림 확인
let alert = detailVC.presentedViewController as? UIAlertController
XCTAssertNotNil(alert)
XCTAssertEqual(alert?.message, "신청이 완료되었습니다")

// 6. 버튼 상태 변경 확인
XCTAssertEqual(applyButton.title(for: .normal), "신청 취소")

// 7. 신청자 수 증가 확인
XCTAssertEqual(Int(applicantsLabel.text?.dropFirst(5) ?? ""), 4)
```

**예상 결과:**
- ✅ 버튼이 탭 가능
- ✅ API 호출
- ✅ 성공 알림 표시
- ✅ 버튼 텍스트 변경 ("신청하기" → "신청 취소")
- ✅ 신청자 수 증가

**검증 포인트:**
- 이중 신청 방지
- 로딩 중 버튼 비활성화
- 네트워크 오류 처리

---

#### TC-MER-004: 로딩 상태 및 에러 처리

**테스트 시나리오 1: 정상 로드**
```swift
// 로딩 표시기 표시 → 데이터 로드 → 표시기 숨김
XCTAssertEqual(loadingIndicator.alpha, 1.0)
wait(for: [apiExpectation], timeout: 2.0)
XCTAssertEqual(loadingIndicator.alpha, 0.0)
```

**테스트 시나리오 2: 네트워크 오류**
```swift
// 네트워크 연결 끊김 시뮬레이션
mockNetworkSession.simulateNetworkError()

// 데이터 로드 시도
viewModel.fetchMercenaryRequest(id: testId)

// 에러 알림 확인
let alert = detailVC.presentedViewController as? UIAlertController
XCTAssertNotNil(alert)
XCTAssert(alert?.message?.contains("네트워크") ?? false)

// 재시도 버튼 확인
let retryAction = alert?.actions.first(where: { $0.title == "재시도" })
XCTAssertNotNil(retryAction)
```

**테스트 시나리오 3: 서버 오류 (404)**
```swift
mockNetworkSession.statusCode = 404

viewModel.fetchMercenaryRequest(id: invalidId)

let alert = detailVC.presentedViewController as? UIAlertController
XCTAssert(alert?.message?.contains("찾을 수 없음") ?? false)
```

**예상 결과:**
- ✅ 로딩 중 로딩 표시기 표시
- ✅ 네트워크 오류: 사용자 친화적 메시지
- ✅ 404 오류: 적절한 에러 메시지
- ✅ 재시도 버튼 제공

---

#### TC-MER-005: 공유 기능

**테스트 단계:**
```swift
// 1. 공유 버튼 확인
let shareButton = detailVC.shareButton
XCTAssertNotNil(shareButton)

// 2. 공유 버튼 탭
shareButton.tap()

// 3. 공유 메뉴 확인
let activityVC = detailVC.presentedViewController as? UIActivityViewController
XCTAssertNotNil(activityVC)

// 4. 공유 가능한 항목 확인
let activityItems = activityVC?.activityItems as? [String]
XCTAssertNotNil(activityItems)
XCTAssert(activityItems?.contains("FC Test - 용병 모집") ?? false)

// 5. 딥링크 확인
let deepLink = activityItems?.first(where: { $0.contains("mercenary") })
XCTAssertNotNil(deepLink)
```

**예상 결과:**
- ✅ 공유 메뉴 표시
- ✅ 제목, 설명 포함
- ✅ 딥링크 생성

---

### 백엔드 API 테스트

#### BT-MER-001: GET /api/mercenary-requests/:id

**테스트:**
```bash
curl -X GET "http://localhost:3000/api/mercenary-requests/{id}" \
  -H "Authorization: Bearer {token}"
```

**검증:**
- ✅ Status Code: 200
- ✅ 응답 구조 정확
- ✅ 모든 필드 포함
- ✅ 관계 데이터 포함 (team, captain)

**경계값 테스트:**
```javascript
// 유효하지 않은 ID
GET /api/mercenary-requests/invalid-id
응답: 400 Bad Request 또는 404 Not Found

// 존재하지 않는 ID
GET /api/mercenary-requests/00000000-0000-0000-0000-000000000000
응답: 404 Not Found
```

---

#### BT-MER-002: POST /api/mercenary-requests/:id/apply

**정상 케이스:**
```bash
curl -X POST "http://localhost:3000/api/mercenary-requests/{id}/apply" \
  -H "Authorization: Bearer {token}"
```

**검증:**
- ✅ 신청 생성됨
- ✅ 상태: "pending"
- ✅ current_applicants 증가

**에러 케이스:**
```javascript
// 이미 신청함
POST /api/mercenary-requests/{id}/apply
응답: 409 Conflict (중복 신청)

// 신청 마감
POST /api/mercenary-requests/{id}/apply (status=closed)
응답: 400 Bad Request (신청 마감)

// 팀원이 신청
POST /api/mercenary-requests/{id}/apply (팀원이 본인 팀의 요청에 신청)
응답: 403 Forbidden
```

---

#### BT-MER-003: DELETE /api/mercenary-requests/:id/apply

**정상 케이스:**
```bash
curl -X DELETE "http://localhost:3000/api/mercenary-requests/{id}/apply" \
  -H "Authorization: Bearer {token}"
```

**검증:**
- ✅ 신청 취소됨
- ✅ current_applicants 감소
- ✅ 상태 변경됨

---

## 2. 사용자 프로필 등록/관리

### 필요한 백엔드 API

#### API-PRO-001: GET /api/users/profile
```
엔드포인트: GET /api/users/profile
인증: 필수
응답:
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "phone": "010-1234-5678",
    "name": "홍길동",
    "profile_image": "https://...",
    "bio": "축구를 사랑하는 사람",
    "skill_level": "intermediate",
    "position": "FW",
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-02-06T10:00:00Z"
  }
}
```

#### API-PRO-002: PUT /api/users/profile
```
엔드포인트: PUT /api/users/profile
인증: 필수
요청:
{
  "name": "홍길동",
  "bio": "축구를 사랑하는 사람",
  "skill_level": "advanced",
  "position": "MF"
}
응답:
{
  "success": true,
  "data": { updated user object }
}
```

#### API-PRO-003: POST /api/users/profile-image
```
엔드포인트: POST /api/users/profile-image
인증: 필수
Content-Type: multipart/form-data
요청:
- image: File (JPEG, PNG)

응답:
{
  "success": true,
  "data": {
    "profile_image": "https://cdn.example.com/images/uuid.jpg"
  }
}
```

### iOS 테스트 케이스

#### TC-PRO-001: 프로필 이미지 업로드

**사전 조건:**
- 프로필 화면 표시됨
- 사용자가 로그인 상태

**테스트 단계:**
```swift
// 1. 프로필 이미지 버튼 탭
let imageButton = profileVC.profileImageButton
imageButton.tap()

// 2. 사진 선택 인터페이스 확인
let imagePicker = profileVC.presentedViewController as? UIImagePickerController
XCTAssertNotNil(imagePicker)

// 3. 테스트 이미지 선택
let testImage = UIImage(systemName: "person.fill")!
imagePicker?.delegate?.imagePicker?(
  imagePicker!,
  didFinishPickingMediaWithInfo: [
    .originalImage: testImage
  ]
)

// 4. 로딩 표시기 확인
wait(for: [uploadStartExpectation], timeout: 1.0)
XCTAssertTrue(profileVC.isUploadingImage)

// 5. 업로드 완료 확인
wait(for: [uploadCompleteExpectation], timeout: 3.0)
XCTAssertFalse(profileVC.isUploadingImage)

// 6. 이미지 표시 확인
XCTAssertNotNil(profileVC.profileImageView.image)
```

**예상 결과:**
- ✅ 사진 선택 인터페이스 표시
- ✅ 로딩 표시기 표시
- ✅ 이미지 업로드
- ✅ 프로필 사진 업데이트

**검증 포인트:**
- 파일 크기 제한 (5MB)
- 이미지 포맷 검증 (JPEG, PNG만)
- 업로드 진행률 표시
- 오류 시 사용자 알림

---

#### TC-PRO-002: 프로필 정보 저장

**테스트 단계:**
```swift
// 1. 프로필 필드 입력
profileVC.nameField.text = "김철수"
profileVC.bioField.text = "FC 팬"
profileVC.skillLevelPicker.selectedSegmentIndex = 1 // "중급"
profileVC.positionPicker.selectedSegmentIndex = 2 // "MF"

// 2. 저장 버튼 탭
let saveButton = profileVC.saveButton
saveButton.tap()

// 3. 유효성 검사
XCTAssertFalse(profileVC.nameField.text?.isEmpty ?? true)

// 4. API 호출 확인
wait(for: [saveAPIExpectation], timeout: 2.0)

// 5. 성공 알림 확인
let alert = profileVC.presentedViewController as? UIAlertController
XCTAssertEqual(alert?.message, "프로필이 저장되었습니다")

// 6. 필드 업데이트 확인
XCTAssertEqual(profileVC.viewModel.user.name, "김철수")
XCTAssertEqual(profileVC.viewModel.user.bio, "FC 팬")
```

**예상 결과:**
- ✅ 입력 유효성 검사
- ✅ API 호출
- ✅ 성공 알림
- ✅ 로컬 상태 업데이트

**검증 포인트:**
- 필수 필드 검증 (이름)
- 텍스트 길이 제한
- 중복 저장 방지

---

#### TC-PRO-003: 프로필 정보 수정

**테스트 단계:**
```swift
// 1. 초기 값 로드
let initialName = profileVC.viewModel.user.name
XCTAssertEqual(profileVC.nameField.text, initialName)

// 2. 정보 수정
profileVC.nameField.text = "박영희"
profileVC.bioField.text = "축구 초보"

// 3. 저장
profileVC.saveButton.tap()

// 4. API 호출 확인
wait(for: [updateAPIExpectation], timeout: 2.0)

// 5. 변경 확인
XCTAssertNotEqual(profileVC.viewModel.user.name, initialName)
XCTAssertEqual(profileVC.viewModel.user.name, "박영희")

// 6. UI 업데이트 확인
XCTAssertEqual(profileVC.userNameLabel.text, "박영희")
```

**예상 결과:**
- ✅ 기존 정보 로드됨
- ✅ 수정 가능
- ✅ API 호출 및 저장
- ✅ UI 즉시 업데이트

**검증 포인트:**
- 부분 수정 지원
- 캐시 무효화
- 동시성 문제 없음

---

### 백엔드 API 테스트

#### BT-PRO-001: GET /api/users/profile

**테스트:**
```bash
curl -X GET "http://localhost:3000/api/users/profile" \
  -H "Authorization: Bearer {token}"
```

**검증:**
- ✅ 현재 사용자 정보 반환
- ✅ 모든 필드 포함
- ✅ 이미지 URL 유효

---

#### BT-PRO-002: PUT /api/users/profile

**테스트:**
```bash
curl -X PUT "http://localhost:3000/api/users/profile" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "김철수",
    "bio": "축구 팬",
    "skill_level": "advanced"
  }'
```

**검증:**
- ✅ 정보 업데이트됨
- ✅ updated_at 변경됨
- ✅ 유효성 검사

---

#### BT-PRO-003: POST /api/users/profile-image

**테스트:**
```bash
curl -X POST "http://localhost:3000/api/users/profile-image" \
  -H "Authorization: Bearer {token}" \
  -F "image=@/path/to/image.jpg"
```

**검증:**
- ✅ 파일 업로드됨
- ✅ CDN URL 반환
- ✅ 파일 크기 제한 (5MB)
- ✅ 포맷 검증 (JPEG, PNG)

**에러 케이스:**
```javascript
// 너무 큰 파일
POST /api/users/profile-image (10MB)
응답: 413 Payload Too Large

// 지원하지 않는 포맷
POST /api/users/profile-image (GIF)
응답: 400 Bad Request (지원하지 않는 형식)
```

---

## 3. 내가 쓴 글 조회

### 필요한 백엔드 API

#### API-MY-001: GET /api/matches/my/created
```
엔드포인트: GET /api/matches/my/created?page=1&limit=20
인증: 필수
응답:
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "팀 모집",
      "date": "2026-03-01T19:00:00Z",
      "location": "강남",
      "match_type": "6v6",
      "fee": 5000,
      "current_participants": 10,
      "max_participants": 11,
      "status": "recruiting",
      "created_at": "2026-02-01T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "total_pages": 1
  }
}
```

#### API-MY-002: GET /api/mercenary-requests/my/created
```
유사한 구조, mercenary-requests 엔드포인트
```

### iOS 테스트 케이스

#### TC-MY-001: 팀 매칭글 목록 조회

**테스트 단계:**
```swift
// 1. 내 글 탭 클릭
let myTab = tabBarController.tabBar.items[2] // "내 글"
tabBarController.selectedIndex = 2

// 2. 팀 매칭 탭 선택
let teamMatchTab = viewController.segmentControl.selectedSegmentIndex
XCTAssertEqual(teamMatchTab, 0)

// 3. 로딩 표시기 확인
XCTAssertTrue(viewController.isLoading)

// 4. API 호출 확인
wait(for: [apiExpectation], timeout: 2.0)

// 5. 목록 표시 확인
XCTAssertEqual(viewController.matches.count, 5)
XCTAssert(viewController.tableView.numberOfRows(inSection: 0) > 0)

// 6. 셀 데이터 확인
let cell = viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
XCTAssertEqual(cell?.textLabel?.text, "팀 모집")
```

**예상 결과:**
- ✅ 팀 매칭 목록 로드
- ✅ 5개 항목 표시
- ✅ 각 항목에 필요한 정보 표시

---

#### TC-MY-002: 용병글 목록 조회

**테스트 단계:**
```swift
// 1. 용병 탭 선택
viewController.segmentControl.selectedSegmentIndex = 1

// 2. 로딩 및 API 호출
wait(for: [mercenaryAPIExpectation], timeout: 2.0)

// 3. 용병 목록 확인
XCTAssertEqual(viewController.mercenaryRequests.count, 3)
```

**예상 결과:**
- ✅ 용병 목록 로드
- ✅ 3개 항목 표시

---

#### TC-MY-003: 페이지네이션

**테스트 단계:**
```swift
// 1. 첫 페이지 로드 (limit=20)
XCTAssertEqual(viewController.matches.count, 20)

// 2. 마지막 항목까지 스크롤
tableView.scrollToRow(at: IndexPath(row: 19, section: 0), ...)

// 3. 다음 페이지 로드
wait(for: [nextPageExpectation], timeout: 2.0)

// 4. 추가 항목 확인
XCTAssertEqual(viewController.matches.count, 40)

// 5. 페이지네이션 정보 확인
XCTAssertEqual(viewController.pagination.page, 2)
XCTAssertTrue(viewController.pagination.has_next)
```

**예상 결과:**
- ✅ 처음 20개 항목 로드
- ✅ 스크롤 시 다음 페이지 자동 로드
- ✅ 누적 로드

---

#### TC-MY-004: 빈 상태 처리

**테스트 단계:**
```swift
// 작성한 글이 없는 사용자
// 1. 목록 조회
viewController.fetchMyMatches()

// 2. 빈 상태 UI 확인
XCTAssertTrue(viewController.emptyStateView.isHidden == false)
XCTAssertEqual(emptyStateLabel.text, "작성한 글이 없습니다")

// 3. 버튼 확인
let createButton = viewController.emptyStateView.subviews
  .first(where: { $0 is UIButton }) as? UIButton
XCTAssertNotNil(createButton)
XCTAssertEqual(createButton?.title(for: .normal), "지금 작성하기")

// 4. 버튼 탭 시 생성 화면으로 이동
createButton?.tap()
XCTAssert(viewController.navigationController?.topViewController
  is FirstTeamRecruitmentViewController)
```

**예상 결과:**
- ✅ 빈 상태 메시지 표시
- ✅ "지금 작성하기" 버튼 제공
- ✅ 버튼 클릭 시 생성 화면 이동

---

### 백엔드 API 테스트

#### BT-MY-001: GET /api/matches/my/created

**테스트:**
```bash
curl -X GET "http://localhost:3000/api/matches/my/created" \
  -H "Authorization: Bearer {token}"
```

**검증:**
- ✅ 현재 사용자가 생성한 매칭만 반환
- ✅ is_active=true인 것만 반환
- ✅ 페이지네이션 정확

---

#### BT-MY-002: GET /api/mercenary-requests/my/created

**테스트:**
```bash
curl -X GET "http://localhost:3000/api/mercenary-requests/my/created" \
  -H "Authorization: Bearer {token}"
```

**검증:**
- ✅ 현재 사용자의 팀이 생성한 요청만 반환
- ✅ 소프트 삭제 반영 (is_active=false 제외)

---

## 4. 관심 글 조회 (좋아요/즐겨찾기)

### 필요한 백엔드 API

#### API-INT-001: POST /api/matches/:id/like
```
엔드포인트: POST /api/matches/{matchId}/like
인증: 필수
요청: {}
응답:
{
  "success": true,
  "data": {
    "match_id": "uuid",
    "is_liked": true
  }
}
```

#### API-INT-002: DELETE /api/matches/:id/like
```
엔드포인트: DELETE /api/matches/{matchId}/like
인증: 필수
응답:
{
  "success": true,
  "data": {
    "match_id": "uuid",
    "is_liked": false
  }
}
```

#### API-INT-003: GET /api/matches/my/liked
```
엔드포인트: GET /api/matches/my/liked?page=1&limit=20
인증: 필수
응답:
{
  "success": true,
  "data": [
    { match object }
  ],
  "pagination": { ... }
}
```

#### API-INT-004: GET /api/mercenary-requests/my/liked

```
동일한 구조
```

### iOS 테스트 케이스

#### TC-INT-001: 팀 매칭 관심 추가

**테스트 단계:**
```swift
// 1. 팀 매칭 목록 또는 상세 화면
let match = viewController.matches[0]
let initialLikeCount = match.likes_count

// 2. 하트 버튼 탭
let heartButton = matchCell.heartButton
heartButton.tap()

// 3. 하트 아이콘 변경 확인
XCTAssertEqual(heartButton.image(for: .normal), UIImage(systemName: "heart.fill"))

// 4. API 호출 확인
wait(for: [likeAPIExpectation], timeout: 1.0)

// 5. 좋아요 수 증가 확인
XCTAssertEqual(match.likes_count, initialLikeCount + 1)

// 6. UI 업데이트 확인
XCTAssertEqual(likesLabel.text, "좋아요 \(initialLikeCount + 1)")
```

**예상 결과:**
- ✅ 하트 버튼 활성화 상태로 변경
- ✅ 좋아요 수 증가
- ✅ API 호출

**검증 포인트:**
- 이중 좋아요 방지
- 낙관적 업데이트 (UI 먼저 변경)
- 오류 시 롤백

---

#### TC-INT-002: 팀 매칭 관심 제거

**테스트 단계:**
```swift
// 1. 좋아요한 매칭 상태 확인
let match = viewController.matches[0]
XCTAssertTrue(match.is_liked)
let initialCount = match.likes_count

// 2. 하트 버튼 탭 (제거)
let heartButton = matchCell.heartButton
heartButton.tap()

// 3. 하트 아이콘 변경 확인
XCTAssertEqual(heartButton.image(for: .normal), UIImage(systemName: "heart"))

// 4. 좋아요 수 감소 확인
XCTAssertEqual(match.likes_count, initialCount - 1)

// 5. 목록에서 제거 확인 (관심 목록 화면인 경우)
if isInLikedListVC {
  wait(for: [removeExpectation], timeout: 1.0)
  XCTAssertFalse(viewController.matches.contains(match))
}
```

**예상 결과:**
- ✅ 하트 버튼 비활성화 상태로 변경
- ✅ 좋아요 수 감소
- ✅ 관심 목록에서 제거

---

#### TC-INT-003: 용병 관심 추가

**테스트 단계:**
```swift
// 용병 목록에서 하트 버튼 탭
let mercenaryRequest = viewController.mercenaryRequests[0]
let heartButton = mercenaryCell.heartButton
heartButton.tap()

// 좋아요 추가 확인
wait(for: [likeAPIExpectation], timeout: 1.0)
XCTAssertEqual(heartButton.image(for: .normal), UIImage(systemName: "heart.fill"))
```

**예상 결과:**
- ✅ 용병 관심 추가
- ✅ UI 업데이트

---

#### TC-INT-004: 용병 관심 제거

**테스트 단계:**
```swift
// 좋아요한 용병 제거
let heartButton = mercenaryCell.heartButton
heartButton.tap()

// 제거 확인
wait(for: [unlikeAPIExpectation], timeout: 1.0)
XCTAssertEqual(heartButton.image(for: .normal), UIImage(systemName: "heart"))
```

---

#### TC-INT-005: 관심 목록 조회

**테스트 단계:**
```swift
// 1. 관심 탭 클릭
let interestTab = tabBarController.tabBar.items[3] // "관심"
tabBarController.selectedIndex = 3

// 2. 팀 매칭 탭 선택
let teamMatchSegment = viewController.segmentControl.selectedSegmentIndex
XCTAssertEqual(teamMatchSegment, 0)

// 3. 로딩 및 API 호출
wait(for: [likedMatchesExpectation], timeout: 2.0)

// 4. 목록 확인
XCTAssertGreaterThan(viewController.likedMatches.count, 0)
XCTAssert(viewController.tableView.numberOfRows(inSection: 0) > 0)

// 5. 용병 탭 선택
viewController.segmentControl.selectedSegmentIndex = 1
wait(for: [likedMercenaryExpectation], timeout: 2.0)

// 6. 용병 목록 확인
XCTAssertGreaterThan(viewController.likedMercenaryRequests.count, 0)
```

**예상 결과:**
- ✅ 좋아요한 팀 매칭 목록 표시
- ✅ 좋아요한 용병 목록 표시
- ✅ 섹션 전환 시 데이터 로드

---

#### TC-INT-006: 관심 수 정확성

**테스트 단계:**
```swift
// 1. 매칭 목록에서 좋아요 수 확인
let match = viewController.matches[0]
let likesFromList = Int(match.likes_count)

// 2. 상세 화면 이동
match.tap()
let detailMatch = detailVC.match
let likesFromDetail = Int(detailMatch.likes_count)

// 3. 수치 일치 확인
XCTAssertEqual(likesFromList, likesFromDetail)

// 4. 좋아요 추가 후 확인
detailVC.likeButton.tap()
wait(for: [likeExpectation], timeout: 1.0)

let newLikes = Int(detailMatch.likes_count)
XCTAssertEqual(newLikes, likesFromList + 1)

// 5. 목록으로 돌아가서 확인
navigationController?.popViewController(animated: true)
let updatedMatch = viewController.matches.first(where: { $0.id == match.id })
XCTAssertEqual(Int(updatedMatch?.likes_count ?? 0), newLikes)
```

**예상 결과:**
- ✅ 모든 화면에서 좋아요 수 일치
- ✅ 실시간 업데이트

---

### 백엔드 API 테스트

#### BT-INT-001: POST /api/matches/:id/like

**테스트:**
```bash
curl -X POST "http://localhost:3000/api/matches/{id}/like" \
  -H "Authorization: Bearer {token}"
```

**검증:**
- ✅ 좋아요 추가됨
- ✅ 좋아요 수 증가
- ✅ 사용자별 추적

**에러 케이스:**
```javascript
// 이미 좋아요함
POST /api/matches/{id}/like (두 번째)
응답: 409 Conflict
```

---

#### BT-INT-002: DELETE /api/matches/:id/like

**테스트:**
```bash
curl -X DELETE "http://localhost:3000/api/matches/{id}/like" \
  -H "Authorization: Bearer {token}"
```

**검증:**
- ✅ 좋아요 제거됨
- ✅ 좋아요 수 감소

---

#### BT-INT-003: GET /api/matches/my/liked

**테스트:**
```bash
curl -X GET "http://localhost:3000/api/matches/my/liked" \
  -H "Authorization: Bearer {token}"
```

**검증:**
- ✅ 현재 사용자가 좋아요한 매칭만 반환
- ✅ is_liked=true인 것만 반환

---

#### BT-INT-004: GET /api/mercenary-requests/my/liked

**동일한 로직**

---

## 5. 통합 테스트 (E2E)

### IT-NEW-001: 용병 검색부터 신청까지

**시나리오:**
```
1. 용병 목록 화면
2. 특정 용병 선택
3. 상세 정보 확인
4. 신청 버튼 클릭
5. 신청 완료
6. 관심 추가
7. 관심 목록 확인
```

---

### IT-NEW-002: 프로필 업로드부터 저장까지

**시나리오:**
```
1. 프로필 화면
2. 이미지 업로드
3. 정보 수정
4. 저장
5. 확인
```

---

### IT-NEW-003: 내 글 작성부터 조회까지

**시나리오:**
```
1. 새 매칭 작성
2. 저장
3. 내 글 탭 → 확인
4. 관심 추가
5. 관심 탭 → 확인
```

---

## 6. 성능 테스트

### 성능 기준

| 항목 | 기준 | 측정 |
|------|------|------|
| 용병 상세 로드 | < 1초 | API 응답 |
| 프로필 이미지 업로드 | < 3초 | 1MB 파일 기준 |
| 내 글 목록 로드 | < 1초 | 20개 항목 |
| 관심 목록 로드 | < 1초 | 20개 항목 |
| 좋아요 토글 | < 500ms | API 응답 |

---

## 7. 버그 체크리스트

### 표시 오류
- [ ] 텍스트 길이 오버플로우
- [ ] 이미지 미로드
- [ ] 숫자 포맷팅 오류
- [ ] 날짜 포맷 불일치

### 기능 오류
- [ ] 이중 신청
- [ ] 이중 좋아요
- [ ] 캐시 미동기화
- [ ] 오프라인 상태 처리 미흡

### 성능 문제
- [ ] 메모리 누수
- [ ] 느린 로딩
- [ ] 불필요한 API 호출
- [ ] 배터리 소모

### 보안 문제
- [ ] 인증 토큰 노출
- [ ] 민감한 정보 로그 출력
- [ ] HTTPS 미사용

---

## 8. 테스트 일정

| 단계 | 작업 | 담당 | 예상 기간 |
|------|------|------|----------|
| 개발 | 4개 기능 구현 | ios-developer + server-developer | 5-7시간 |
| 테스트 | 28개 테스트 케이스 | qa-lead | 2-3시간 |
| 피드백 | 버그 수정 | 개발팀 | 1-2시간 |
| 재검증 | 최종 확인 | qa-lead | 1시간 |

**전체 예상**: 9-13시간

---

## 9. 성공 기준

### iOS
- ✅ 모든 기능 정상 작동
- ✅ UI 오류 없음
- ✅ 성능 기준 충족
- ✅ 메모리 누수 없음

### 백엔드
- ✅ 모든 API 정상 작동
- ✅ 응답 형식 일관
- ✅ 에러 처리 정확
- ✅ 데이터 무결성

### 통합
- ✅ iOS ↔ 백엔드 데이터 일치
- ✅ E2E 시나리오 통과
- ✅ 사용자 경험 우수

---

**문서 작성**: qa-lead
**최종 검토**: 필요
**테스트 시작**: 개발 완료 후
