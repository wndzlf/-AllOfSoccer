# 백엔드 연구 보고서: 기능 개선 사항
## 날짜: 2026-02-06

---

## 1. 팀 매칭 쉽게 하기 (팀 매칭 간소화)

### 현재 상태
- **경로**: `/api/matches`
- **사용 가능한 필터**: location, date, match_type, gender_type, shoes_requirement, age_range (min/max), skill_level (min/max), fee_range (min/max), status, pagination
- **참가자 플로우**:
  - 사용자가 신청 → MatchParticipant 생성 (status='pending')
  - 팀 캡틴이 참가자를 볼 수 있지만 명시적인 승인/거절 메커니즘 없음
- **팀 생성**: `team_id`를 제공하지 않으면 자동으로 팀 생성

### 필요한 문제점 및 개선사항

**문제 1: 참가자 상태 관리**
- 현재: 신청은 저장되지만 팀 캡틴을 위한 승인/거절 플로우 없음
- 필요: 참가자 승인 워크플로우 구현
- **제안 솔루션**:
  ```
  POST /api/matches/:id/participants/:userId/accept
  POST /api/matches/:id/participants/:userId/reject
  ```

**문제 2: 쿼리 성능**
- 현재: 매치 목록 GET에 페이지네이션 없음 (offset/limit 사용하지만 최적화 가능)
- 필요: 자주 사용되는 필터에 대한 인덱싱된 열 추가
- **현재 인덱스**: date, location, status, team_id, match_type, gender_type
- **누락된 것**: 공통 필터 조합을 위한 복합 인덱스 (location + date, skill_level 범위 쿼리)

**문제 3: 데이터 중복**
- Match는 `team_introduction` 필드를 가지고 있고 Comment 테이블도 team_introduction을 저장
- 단일 정보 소스로 통합 가능

**제안 변경사항**:
1. 필터 매개변수에 대한 미들웨어 유효성 검사 추가
2. 자주 필터링된 데이터를 위한 데이터베이스 뷰 생성
3. 매치 검색 최적화 추가 (위치/제목에 대한 fulltext 검색)
4. N+1 쿼리 수정 (이미 includes 사용 중, 좋음)

---

## 2. 용병 구하기 쉽게 하기 (용병 모집 개선)

### 현재 상태
- **경로**: `/api/mercenary-requests`
- **필터**: location, date, skill_level, fee_range, status, pagination
- **제한된 필터**: 팀 매칭과 비교 - match_type, gender_type, shoes_requirement 누락
- **신청 플로우**: 사용자 신청 → MercenaryMatch (status='pending') → 캡틴 승인/거절

### 필요한 문제점 및 개선사항

**문제 1: 필터 패리티**
- 팀 매칭 기능에서 누락된 필터:
  - `match_type` (6v6, 11v11)
  - `gender_type` (남성, 여성, 혼성)
  - `shoes_requirement` (futsal, soccer, any)
  - `age_range_min/max`
- **중요한 이유**: 용병 모집도 팀 모집과 동일한 명확도 필요

**문제 2: 필요한 포지션이 활용되지 않음**
- `positions_needed` 필드가 JSON으로 존재하지만 포지션으로 필터링/정렬 없음
- 선수들이 필요한 특정 포지션을 필터링하고 싶을 수 있음

**문제 3: 누락된 "My" 엔드포인트**
- GET `/my/created`와 `/my/applied` 있음
- 누락: GET `/my/pending` (응답 대기 중인 신청)

**제안 변경사항**:
1. 누락된 필터를 MercenaryRequest 모델 & GET 엔드포인트에 추가
2. 포지션/실력별로 신청자를 필터링하는 엔드포인트 생성
3. `/my/pending` 엔드포인트 추가 - 보류 중인 신청 표시
4. 거절 엔드포인트 추가: POST `/api/mercenary-requests/:id/reject/:userId`

---

## 3. 이전 매칭 불러오기 & 재활용 (매치 템플릿 & 중복)

### 현재 상태
- 템플릿 시스템 없음
- 사용자가 매번 처음부터 매칭을 다시 만들어야 함

### 제안 솔루션

#### 옵션 A: 매치 스냅샷 (권장)
사용자의 이전 매칭을 재사용 가능한 템플릿으로 저장할 새로운 모델 생성:

```javascript
// 새로운 모델: MatchTemplate
{
  id: UUID,
  user_id: UUID,                    // 생성한 캡틴
  title: STRING,
  description: TEXT,
  match_type: ENUM(6v6, 11v11),
  gender_type: ENUM,
  shoes_requirement: ENUM,
  age_range_min: INTEGER,
  age_range_max: INTEGER,
  skill_level_min: ENUM,
  skill_level_max: ENUM,
  fee: INTEGER,
  max_participants: INTEGER,
  location: STRING (선택),           // 템플릿은 고정된 위치가 없을 수 있음
  address: STRING,
  latitude: DECIMAL,
  longitude: DECIMAL,
  team_introduction: TEXT,
  is_public: BOOLEAN,               // 다른 사용자와 공유
  usage_count: INTEGER,
  created_at: DATE,
  updated_at: DATE
}
```

#### 필요한 새로운 엔드포인트
```
1. GET /api/matches/templates                    # 사용자의 모든 템플릿 나열
2. GET /api/matches/templates/:templateId        # 템플릿 상세 정보 가져오기
3. POST /api/matches/templates                   # 현재 매칭을 템플릿으로 저장
4. POST /api/matches/templates/:templateId/use   # 템플릿에서 매칭 생성
5. PUT /api/matches/templates/:templateId        # 템플릿 업데이트
6. DELETE /api/matches/templates/:templateId     # 템플릿 삭제
7. GET /api/matches/templates/public             # 공개 템플릿 발견
```

#### 마이그레이션 전략
1. `MatchTemplate` 테이블 생성
2. 사용자의 기존 매칭을 템플릿으로 복사하는 마이그레이션 추가 (선택)
3. 추적을 위해 Match 모델에 `created_from_template_id` 추가

---

## 4. 필터링 개선 (향상된 필터링)

### 현재 필터 분석

**팀 매칭 필터**:
- ✅ location (iLike, 대소문자 구분 없음)
- ✅ date (gte, 미래 날짜만)
- ✅ match_type (enum)
- ✅ gender_type (enum)
- ✅ shoes_requirement (enum)
- ✅ age_range (min/max)
- ✅ skill_level (min/max 사이의 범위)
- ✅ fee (min/max 범위)
- ✅ status (enum)

**누락된/필요한 개선사항**:

1. **거리 기반 필터링**
   - 현재: 위치 텍스트 검색만
   - 필요: 지리적 근접성을 위한 Haversine 공식
   - 구현: 위도/경도를 사용한 거리 계산
   ```sql
   -- 거리 필터링을 위한 의사코드
   SELECT * FROM matches
   WHERE (
     3959 * acos(cos(radians(input_lat)) * cos(radians(latitude)) *
     cos(radians(longitude) - radians(input_lon)) +
     sin(radians(input_lat)) * sin(radians(latitude)))
   ) < distance_in_miles
   ```

2. **날짜 범위 필터링**
   - 현재: gte (보다 크거나 같음)만 사용
   - 필요: 날짜 범위 지원 (date_from, date_to)
   - 사용 사례: "다음 7일간의 매칭 표시" 또는 "이번 주말"

3. **가용성 윈도우**
   - 매칭에 time_start 및 time_end 추가
   - 시간 슬롯으로 필터링 (아침, 오후, 저녁)

4. **장비/특수성 필터**
   - "골키퍼 필요"
   - "팀 유니폼을 가진 선수"
   - Mercenary 모델에 추가 가능

5. **정렬 옵션**
   - 현재: sort_by, sort_order
   - 프리셋 추가: 'nearest', 'soonest', 'most_full', 'cheapest'

6. **검색 최적화**
   - 제목, 설명, 위치에 fulltext 인덱스 추가
   - 오타에 대한 흐릿한 매칭 활성화

### 데이터베이스 최적화 권장사항

```javascript
// Match 모델에 다음 인덱스 추가:
{
  fields: ['created_at', 'status']     // /my/created 쿼리용
},
{
  fields: ['date', 'location']         // 공통 필터 조합
},
{
  fields: ['skill_level_min', 'skill_level_max']
},
{
  fields: ['latitude', 'longitude']    // 지리쿼리용
}

// MercenaryRequest용:
{
  fields: ['date', 'skill_level_min']
},
{
  fields: ['latitude', 'longitude']    // 지리쿼리용
}
```

---

## 5. 백엔드 아키텍처 개선

### API 응답 표준화
현재: 일관성 없는 페이지네이션 응답 구조
- 일부 엔드포인트는 `pagination` 객체 가짐
- 일부는 직접 배열 사용

**표준화 대상**:
```javascript
{
  success: boolean,
  data: Array | Object,
  pagination: {
    page: number,
    limit: number,
    total: number,
    total_pages: number,
    has_next: boolean,
    has_prev: boolean
  },
  meta: {
    timestamp: ISO string,
    filters_applied: object
  }
}
```

### 캐싱 전략
- 사용자 자신의 매칭은 거의 변경되지 않음 → 1분 TTL로 캐싱
- 매칭 목록 → 30초 TTL로 캐싱
- 팀 정보 → 5분 TTL로 캐싱
- 캐싱을 위해 Redis 사용 (이미 구성됨)

### 속도 제한
- 현재: 전역 15분/100 요청
- **제안**:
  - 매칭 생성: 사용자당 시간당 10개
  - 용병 요청: 사용자당 시간당 5개
  - 매칭 신청: 사용자당 시간당 20개

---

## 6. 데이터 일관성 문제

### 현재 문제점
1. `is_active` 소프트 삭제가 모든 곳에서 강제되지 않음
   - 위험: 삭제된 매칭이 여전히 쿼리에 나타날 수 있음
   - 해결: 항상 `where: { is_active: true }` 필터링

2. 참가자 수 (`current_participants`)가 drift할 수 있음
   - 위험: 매칭이 가득 찼지만 신청이 여전히 대기 중
   - 해결: 참가자 상태 변경 시 개수 다시 계산하는 트리거

3. 팀 삭제에 대한 cascade 동작 없음
   - 위험: 고아 매칭 및 용병 요청
   - 해결: 외래 키에 onDelete: 'CASCADE' 추가 또는 하드 삭제 로직 구현

---

## 7. 우선순위 구현 순서

### 1단계 (즉시)
1. 용병 요청에 누락된 필터 추가 (match_type, gender_type, shoes_requirement, age_range)
2. 매칭 참가자 승인/거절 엔드포인트 수정
3. 복합 데이터베이스 인덱스 추가

### 2단계 (이번 스프린트)
1. MatchTemplate 모델 및 엔드포인트 구현
2. 지리쿼리를 통한 거리 기반 필터링 추가
3. 매칭 및 용병 모두에 대한 `/my/pending` 엔드포인트 추가

### 3단계 (다음 스프린트)
1. Fulltext 검색 구현
2. Redis를 사용한 캐싱 레이어
3. API 응답 표준화
4. 향상된 정렬/필터 프리셋

---

## 8. iOS 팀과의 조정

**iOS에서 필요한 것**:
- 템플릿 기능 필요 확인 (이전 매칭 저장/로드)
- 필터 우선순위 명확히 (사용자가 가장 많이 사용하는 필터)
- 참가자를 위한 새로운 `/accept/:userId` 엔드포인트 테스트

**iOS가 구현해야 할 것**:
- 팀 매칭의 새로운 필드: 용병을 위한 positions_needed?
- 지리 필터링 UI (거리 슬라이더)
- 템플릿 저장/로드 UI
- 템플릿 발견/공유 기능

---

## 수정할 파일

| 파일 | 변경 사항 |
|------|---------|
| `/src/models/Match.js` | 인덱스 추가, 필드 유효성 검사 |
| `/src/models/MercenaryRequest.js` | 누락된 enum 필드 추가 |
| `/src/routes/matches.js` | 승인/거절 엔드포인트, 템플릿 엔드포인트 추가 |
| `/src/routes/mercenaryRequests.js` | 누락된 필터 추가, 새로운 엔드포인트 |
| **새로운** `/src/models/MatchTemplate.js` | 새로운 모델 생성 |
| **새로운** `/src/routes/templates.js` | 새로운 경로 파일 생성 |
| `/src/config/database.js` | 데이터베이스 동기화 |

---

## 마이그레이션 계획

1. **데이터베이스 마이그레이션** (먼저 실행):
   - 기존 테이블에 새로운 열 추가
   - MatchTemplate 테이블 생성
   - 누락된 인덱스 추가

2. **API 변경** (하위 호환):
   - 기존 엔드포인트 옆에 새 엔드포인트 추가
   - 매칭 및 용병 경로 업데이트
   - 기존 GET 엔드포인트에 필터 매개변수 추가

3. **테스트**:
   - 모든 필터 조합 테스트
   - 새로운 인덱스 벤치마크
   - 페이지네이션 부하 테스트

---

## 예상 작업량

| 작업 | 노력 | 영향 |
|------|--------|--------|
| 용병 필터 패리티 | 2-3시간 | 높음 - 일관성 |
| 참가자 승인/거절 | 1시간 | 높음 - 기능성 |
| MatchTemplate 기능 | 4-5시간 | 높음 - UX 개선 |
| 지리 필터링 | 3-4시간 | 중간 - 좋은 점 |
| 캐싱 레이어 | 3-4시간 | 중간 - 성능 |
| API 표준화 | 2-3시간 | 낮음 - 리팩토링 |
| 데이터베이스 최적화 | 1-2시간 | 높음 - 성능 |

**총합**: ~16-22시간의 백엔드 작업

