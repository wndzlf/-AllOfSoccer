# allOfSoccer QA 발견 이슈 요약

**검토 일자**: 2026-02-06
**담당**: qa-lead
**상태**: 진행 중

---

## 1. Critical 이슈 (즉시 해결 필요)

### ISSUE-001: TeamMatchViewController 미완성

**심각도**: 🔴 Critical
**분류**: 기능 결함
**발견 위치**: `/iOS/AllOfSoccer/Recruitment/TeamMatch/TeamMatchViewController.swift`

**현황:**
```swift
private func loadSampleData() {
    sampleData = ["양원역 구장 - 20:00", "태릉종합운동장 - 19:00", ...]
    tableView.reloadData()
}
```

**문제점:**
- ❌ 샘플 데이터만 표시 (실제 API 미연동)
- ❌ 필터링 기능 없음
- ❌ 검색 기능 미구현
- ❌ 상세 화면 미연결

**영향도**: **높음** - 핵심 기능 미작동
**재현율**: 100% (앱 실행 직후)
**우선순위**: P0 (즉시)

**필요한 개선:**
```swift
// 변경 전
private func loadSampleData()

// 변경 후
private func fetchMatches(with filters: MatchFilter = .default) {
    viewModel.fetchMatches(filters: filters)
    // API 호출 및 네트워크 처리
}
```

**담당**: ios-developer
**예상 작업**: 2-3시간

**체크리스트:**
- [ ] ViewModel 추가
- [ ] API 호출 구현
- [ ] 로딩 상태 UI
- [ ] 필터링 연동
- [ ] 에러 처리

---

### ISSUE-002: Age 범위 필터 로직 오류

**심각도**: 🔴 Critical
**분류**: 로직 버그
**발견 위치**: `/Server/src/routes/matches.js` 라인 53-58

**현황:**
```javascript
if (age_min || age_max) {
  where.age_range_min = {};
  where.age_range_max = {};
  if (age_min) where.age_range_min[Op.gte] = parseInt(age_min);
  if (age_max) where.age_range_max[Op.lte] = parseInt(age_max);
}
```

**문제점:**
- ❌ 범위 오버래프 검증 오류
- ❌ 예시: age_min=30 입력 시 "age_range_min >= 30"만 확인
- ❌ 매칭의 age_range_max가 30보다 작으면 제외 (부정확)
- ✅ 정확한 로직: "사용자 범위가 매칭 범위와 겹치는가?"

**영향도**: **높음** - 검색 결과 부정확
**재현율**: 100% (특정 나이 범위 필터 사용 시)
**우선순위**: P0 (높음)

**필요한 개선:**
```javascript
// 정정된 로직
if (age_min || age_max) {
  const ageConditions = [];

  if (age_min) {
    // 매칭의 최대 나이 >= 사용자 최소 나이
    ageConditions.push(
      sequelize.where(
        sequelize.col('age_range_max'),
        Op.gte,
        age_min
      )
    );
  }

  if (age_max) {
    // 매칭의 최소 나이 <= 사용자 최대 나이
    ageConditions.push(
      sequelize.where(
        sequelize.col('age_range_min'),
        Op.lte,
        age_max
      )
    );
  }

  where[Op.and] = ageConditions;
}
```

**담당**: server-developer
**예상 작업**: 1-2시간

**테스트:**
```javascript
// 테스트 케이스
const match = { age_range_min: 25, age_range_max: 50 };
const userAge = { min: 30, max: 40 };
// 결과: 매칭 범위와 겹치므로 포함되어야 함 ✓
```

---

### ISSUE-003: 용병 필터 불완전

**심각도**: 🔴 Critical
**분류**: 기능 부족
**발견 위치**: `/Server/src/routes/mercenaryRequests.js`

**현황:**
```javascript
// 가능한 필터: location, date, skill_level, fee
// 부족한 필터: match_type, gender_type, shoes_requirement, age_range
```

**문제점:**
- ❌ 팀 매칭과 필터 일관성 부족
- ❌ 용병 모집도 경기 유형을 고려해야 함
- ❌ 사용자가 성별 제한이 있는 경우 필터링 불가
- ❌ 신발 종류 필터 없음

**영향도**: **높음** - 필터링 기능 불완전
**재현율**: 100% (필터 적용 시도)
**우선순위**: P0 (높음)

**필요한 추가 필터:**
```javascript
// MercenaryRequest 모델에 필드 확인 필요:
- match_type (ENUM: '6v6', '11v11')
- gender_type (ENUM: 'male', 'female', 'mixed')
- shoes_requirement (ENUM: 'futsal', 'soccer', 'any')
- age_range_min (INTEGER)
- age_range_max (INTEGER)

// 이 필드들이 DB에 없으면 마이그레이션 필요
```

**담당**: server-developer
**예상 작업**: 2-3시간
- 데이터베이스 마이그레이션: 1시간
- API 필터링 구현: 1-2시간

**체크리스트:**
- [ ] MercenaryRequest 모델 필드 확인
- [ ] DB 마이그레이션 작성
- [ ] GET / 엔드포인트 필터 추가
- [ ] 테스트 케이스 작성

---

## 2. Major 이슈 (이번 스프린트 해결)

### ISSUE-004: 팀 모집 2단계 UX 문제

**심각도**: 🟡 Major
**분류**: UX 개선 필요
**발견 위치**: `/iOS/AllOfSoccer/Recruitment/TeamRecruitment/`

**현황:**
- FirstTeamRecruitmentViewController: 4개 섹션
- SecondTeamRecruitmentViewController: 5개 섹션
- 총 약 15-20개의 입력 필드

**문제점:**
- ⚠️ 두 화면으로 나뉨 (화면 전환 번거로움)
- ⚠️ 진행 상황 표시 없음 (1/2, 2/2)
- ⚠️ "이전" 버튼 없음 (데이터 수정 어려움)
- ⚠️ 필수/선택 필드 명확하지 않음
- ⚠️ 에러 메시지 없음

**영향도**: **중간** - 사용성 저하
**재현율**: 100% (폼 작성 시)
**우선순위**: P1 (높음)

**필요한 개선:**

**방안 A: 2단계 유지 + 개선 (권장)**
```swift
// 1. 진행 표시기 추가
HStack {
  Circle()
    .fill(step >= 1 ? .primary : .gray)
    .overlay(Text("1").foregroundColor(.white))

  Divider()

  Circle()
    .fill(step >= 2 ? .primary : .gray)
    .overlay(Text("2").foregroundColor(.white))
}

// 2. "이전" 버튼 추가
HStack {
  Button(action: { step = 1 }) {
    Text("이전")
  }

  Button(action: { submitForm() }) {
    Text("다음")
  }
}

// 3. 필수 필드 표시
Label("팀 이름", systemImage: "star.fill")
  .foregroundColor(.red)
```

**담당**: ios-developer
**예상 작업**: 4-6시간
- UI 개선: 2-3시간
- 상태 관리: 1-2시간
- 테스트: 1시간

---

### ISSUE-005: 이전 매칭 불러오기 미구현

**심각도**: 🟡 Major
**분류**: 기능 부족
**발견 위치**:
- iOS: `/iOS/AllOfSoccer/Recruitment/Component/CallPreviusMatchingInformationView.swift`
- 백엔드: 없음 (MatchTemplate 모델 부재)

**현황:**
```swift
// iOS: 플레이스홀더만 있음
class CallPreviusMatchingInformationView: UIView {
  // 4개 항목을 표시하는 UI만 있음
  // 실제 데이터 없음
}
```

**문제점:**
- ❌ 백엔드 API 없음 (MatchTemplate 엔드포인트)
- ❌ 데이터 모델 없음
- ❌ 저장/로드 로직 미구현
- ❌ 파일명 오타: `Previus` → `Previous`

**영향도**: **중간** - 편의 기능 부족
**재현율**: 100% (버튼 클릭 시)
**우선순위**: P2 (중간)

**필요한 구현:**

**백엔드 (4-5시간):**
```javascript
// 새로운 모델: MatchTemplate
const MatchTemplate = sequelize.define('MatchTemplate', {
  id: UUID,
  user_id: UUID,
  title: STRING,
  match_type: ENUM,
  gender_type: ENUM,
  // ... 다른 필드들
  usage_count: INTEGER,
  last_used: DATE
});

// 새로운 엔드포인트:
// GET    /api/matches/templates
// GET    /api/matches/templates/:id
// POST   /api/matches/templates
// PUT    /api/matches/templates/:id
// DELETE /api/matches/templates/:id
```

**iOS (3-4시간):**
```swift
// ViewController 개선
class FirstTeamRecruitmentViewController {
  func loadPreviousMatching() {
    let templateVC = MatchTemplateViewController()
    templateVC.delegate = self
    present(templateVC, animated: true)
  }

  func applyTemplate(_ template: MatchTemplate) {
    // 폼 필드를 템플릿 데이터로 채우기
    dateTextField.text = template.date
    locationTextField.text = template.location
    // ...
  }
}
```

**담당**:
- 백엔드: server-developer (4-5시간)
- iOS: ios-developer (3-4시간)

**우선순위**: Phase 2

---

### ISSUE-006: 에러 처리 미흡

**심각도**: 🟡 Major
**분류**: 안정성
**발견 위치**: iOS 앱 전반, 백엔드 API

**현황 (iOS):**
```swift
// try-catch 없이 가정적 성공만 처리
viewModel.fetchMatches()  // 에러 처리 없음

// 네트워크 오류 시 사용자는 아무 것도 모름
```

**현황 (백엔드):**
```javascript
res.status(500).json({
  success: false,
  message: 'Failed to fetch matches',
  error: error.message  // ⚠️ 원본 에러 노출
});
```

**문제점:**
- ❌ iOS: 네트워크 오류 UI 없음
- ❌ iOS: 타임아웃 처리 없음
- ❌ 백엔드: 민감한 정보 노출 가능
- ❌ 일관성 없는 에러 응답 형식

**영향도**: **중간** - 사용자 혼란, 보안
**재현율**: 100% (네트워크 끊김, 서버 오류)
**우선순위**: P1 (높음)

**필요한 개선:**

**iOS:**
```swift
// 에러 처리 추가
func fetchMatches() {
  Task {
    do {
      let matches = try await viewModel.fetchMatches()
      self.tableView.reloadData()
    } catch NetworkError.noConnection {
      showAlert("네트워크 연결을 확인해주세요")
    } catch NetworkError.timeout {
      showAlert("요청 시간 초과. 다시 시도해주세요")
    } catch {
      showAlert("오류가 발생했습니다. 잠시 후 다시 시도해주세요")
    }
  }
}
```

**백엔드:**
```javascript
// 에러 응답 표준화
res.status(500).json({
  success: false,
  message: 'Internal server error',
  code: 'INTERNAL_ERROR',
  // error.message 제거 (프로덕션)
  // timestamp 추가 가능
});
```

**담당**:
- iOS: ios-developer (2시간)
- 백엔드: server-developer (1-2시간)

---

### ISSUE-007: 데이터 일관성 위험

**심각도**: 🟡 Major
**분류**: 데이터 무결성
**발견 위치**: `/Server/src/models/`

**현황:**
```javascript
// Match 모델
current_participants: INTEGER  // 수동으로 업데이트해야 함
// MatchParticipant 추가/삭제 시 자동 동기화 안 됨

// Team 삭제 시
// -> Match 고아화 될 수 있음 (Cascade 없음)
// -> MercenaryRequest 고아화 될 수 있음
```

**문제점:**
- ⚠️ current_participants 동기화 불확실
- ⚠️ 소프트 삭제 일관성 부족
- ⚠️ Cascade 처리 없음
- ⚠️ 참가자 수가 max를 초과할 수 있음

**영향도**: **중간** - 데이터 정합성
**재현율**: 낮음 (동시성 문제)
**우선순위**: P2 (중간)

**필요한 개선:**

```javascript
// 1. 트리거 또는 후킹
MatchParticipant.afterCreate(async (participant) => {
  await Match.increment('current_participants', {
    where: { id: participant.match_id }
  });
});

MatchParticipant.beforeDestroy(async (participant) => {
  await Match.decrement('current_participants', {
    where: { id: participant.match_id }
  });
});

// 2. Cascade 설정
Team.hasMany(Match, {
  foreignKey: 'team_id',
  onDelete: 'CASCADE'  // 팀 삭제 시 자동 삭제
});
```

**담당**: server-developer
**예상 작업**: 2-3시간

---

## 3. Minor 이슈 (다음 분기)

### ISSUE-008: 테스트 커버리지 부족

**심각도**: 🟢 Minor
**분류**: 품질 보증
**발견 위치**: 전체 프로젝트

**현황:**
- iOS: 1개 테스트 파일, 5개 테스트 케이스
- 백엔드: 0개 테스트 파일

**문제점:**
- ⚠️ 회귀 테스트 불가능
- ⚠️ 코드 변경 시 안정성 검증 어려움

**우선순위**: P4 (낮음)
**예상 작업**: 10-15시간

---

### ISSUE-009: 파일명 오타

**심각도**: 🟢 Minor
**분류**: 코드 품질
**발견 위치**: `/iOS/AllOfSoccer/Recruitment/Component/CallPreviusMatchingInformationView.swift`

**문제점:**
```swift
// 현재: Previus (오타)
// 정정: Previous (영문)

class CallPreviusMatchingInformationView  // ❌
class CallPreviousMatchingInformationView // ✅
```

**영향도**: **낮음** - 유지보수성
**우선순위**: P3

---

### ISSUE-010: 하드코딩된 디자인 토큰

**심각도**: 🟢 Minor
**분류**: 코드 품질
**발견 위치**: iOS 앱 곳곳

**현황:**
```swift
// MercenaryMatchViewController
button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)

// SecondTeamRecruitmentViewController
textView.layer.borderColor = UIColor(red: 0.866, green: 0.870, blue: 0.882, alpha: 1.0).cgColor
```

**문제점:**
- ⚠️ 디자인 시스템 미준수
- ⚠️ 색상 변경 시 여러 파일 수정 필요

**필요한 개선:**
```swift
// Color 확장
extension UIColor {
  static let primary = UIColor(red: 0.236, green: 0.373, blue: 0.992, alpha: 1.0)
  static let secondary = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
  static let border = UIColor(red: 0.866, green: 0.870, blue: 0.882, alpha: 1.0)
}

// 사용
button.backgroundColor = .primary
```

**우선순위**: P3

---

## 4. 이슈 대시보드

### 심각도별 분포

| 심각도 | 수량 | 상태 |
|--------|------|------|
| 🔴 Critical | 3개 | 미해결 |
| 🟡 Major | 4개 | 미해결 |
| 🟢 Minor | 3개 | 미해결 |

### 분류별 분포

| 분류 | 수량 |
|------|------|
| 기능 결함 | 3개 |
| 기능 부족 | 2개 |
| UX 문제 | 2개 |
| 데이터 무결성 | 1개 |
| 품질 | 2개 |

### 담당자별 작업

| 담당 | 이슈 수 | 예상 시간 |
|------|--------|---------|
| ios-developer | 4개 | 9-13시간 |
| server-developer | 4개 | 6-10시간 |
| qa-lead | 2개 | 진행 중 |

---

## 5. 해결 로드맵

### Phase 1: Critical 해결 (1주)
- ISSUE-001: TeamMatchViewController API 연동 ← ios-developer
- ISSUE-002: Age 필터 로직 수정 ← server-developer
- ISSUE-003: 용병 필터 추가 ← server-developer

**예상**: 2026-02-13 완료

### Phase 2: Major 해결 (2-3주)
- ISSUE-004: 팀 모집 UX 개선 ← ios-developer
- ISSUE-005: 이전 매칭 불러오기 ← ios-developer + server-developer
- ISSUE-006: 에러 처리 개선 ← ios-developer + server-developer
- ISSUE-007: 데이터 일관성 ← server-developer

**예상**: 2026-02-27 완료

### Phase 3: Minor 해결 (다음 분기)
- ISSUE-008: 테스트 추가
- ISSUE-009: 파일명 정정
- ISSUE-010: 디자인 토큰 정리

---

## 6. 추적 및 업데이트

**다음 검토**: 2026-02-13
**마지막 업데이트**: 2026-02-06
**담당**: qa-lead

### 업데이트 이력

| 날짜 | 변경사항 | 담당 |
|------|---------|------|
| 2026-02-06 | 초기 작성 | qa-lead |
| (예정) | Phase 1 완료 | team-lead |
| (예정) | Phase 2 완료 | team-lead |

---

**문서 생성**: 2026-02-06
**최종 검토**: 필요
**배포**: 팀 공유 필요
