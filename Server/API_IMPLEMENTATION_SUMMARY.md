# 4개 API + 2개 모델 구현 완료

## 구현 일시
2026-02-08

## 1. 새로운 모델 (2개)

### 1.1 UserProfile 모델
**파일**: `/src/models/UserProfile.js`

**필드**:
- `id` (UUID, PK)
- `user_id` (UUID, FK, 1:1 관계)
- `nickname` (STRING 2-50자)
- `bio` (STRING 0-500자)
- `profile_image_url` (STRING)
- `preferred_positions` (JSON 배열)
- `preferred_skill_level` (ENUM: beginner~legend)
- `location` (STRING)
- `phone` (STRING)
- `email` (STRING, 이메일 검증)

**관계**:
- User와 1:1 관계 (hasOne/belongsTo)

---

### 1.2 UserInterest 모델
**파일**: `/src/models/UserInterest.js`

**필드**:
- `id` (UUID, PK)
- `user_id` (UUID, FK)
- `match_id` (UUID, FK - nullable)
- `mercenary_request_id` (UUID, FK - nullable)
- `interest_type` (ENUM: 'match' or 'mercenary')

**관계**:
- User (N:1)
- Match (N:1 - match_id로 연결)
- MercenaryRequest (N:1 - mercenary_request_id로 연결)

**제약**:
- (user_id, match_id) 고유 인덱스 (when interest_type='match')
- (user_id, mercenary_request_id) 고유 인덱스 (when interest_type='mercenary')

---

## 2. API 엔드포인트

### 2.1 용병 상세 API
**엔드포인트**: `GET /api/mercenary-requests/:id`
**인증**: 선택사항 (토큰 있으면 관심 여부 확인)

**응답 필드**:
```javascript
{
  id, team_id, title, description,
  location, address, latitude, longitude,
  date, time, match_type, gender_type,
  shoes_requirement, positions_needed,
  skill_level_min, skill_level_max,
  fee, age_range_min, age_range_max,
  max_participants, current_participants,
  mercenary_count, current_applicants,
  team_introduction, team_captain_name,
  team_captain_image, status, is_active,
  is_interested_by_user,
  created_at, updated_at
}
```

**구현 세부**:
- Team과 User(captain) 정보 포함
- MercenaryMatch 참가자 목록 포함
- 로그인 사용자의 관심 여부 확인 (is_interested_by_user)

---

### 2.2 사용자 프로필 API

#### 2.2.1 프로필 조회
**엔드포인트**: `GET /api/users/profile/me`
**인증**: 필수 (인증된 사용자만)

**응답**:
```javascript
{
  success: true,
  data: {
    id, user_id, nickname, bio,
    profile_image_url, preferred_positions,
    preferred_skill_level, location, phone, email,
    created_at, updated_at
  }
}
```

**구현 세부**:
- 프로필이 없으면 자동 생성

---

#### 2.2.2 프로필 수정 (부분 수정 지원)
**엔드포인트**: `PUT /api/users/profile/me`
**인증**: 필수

**요청 바디** (부분 수정 가능):
```javascript
{
  nickname: "string (2-50자)",
  bio: "string (0-500자)",
  preferred_positions: ["GK", "DF", "MF", "FW"],
  preferred_skill_level: "beginner|intermediate|advanced|expert|national|worldclass|legend",
  location: "string",
  phone: "string",
  email: "valid email"
}
```

**데이터 검증**:
- 닉네임: 2-50자
- 소개글: 0-500자
- 이메일: 유효한 이메일 형식
- 스킬 레벨: enum 값만 허용

---

#### 2.2.3 프로필 이미지 업로드
**엔드포인트**: `POST /api/users/profile-image/me`
**인증**: 필수
**Content-Type**: multipart/form-data

**요청**:
- 폼 필드명: `image`
- 파일 제한: 5MB
- 허용 포맷: JPG, PNG

**응답**:
```javascript
{
  success: true,
  data: {
    profile_image_url: "/uploads/profiles/profile-{user_id}-{timestamp}.jpg"
  },
  message: "Profile image uploaded successfully"
}
```

**구현 세부**:
- multer 사용 (이미 설치됨)
- 파일 저장: `/Server/uploads/profiles/`
- 파일명 패턴: `profile-{user_id}-{timestamp}.{ext}`
- 자동 디렉토리 생성

---

### 2.3 관심 API

#### 2.3.1 팀 매칭 관심 추가
**엔드포인트**: `POST /api/matches/:id/like`
**인증**: 필수

**응답**:
```javascript
{
  success: true,
  data: { id, user_id, match_id, interest_type: "match", created_at },
  message: "Match marked as interested"
}
```

---

#### 2.3.2 팀 매칭 관심 제거
**엔드포인트**: `DELETE /api/matches/:id/like`
**인증**: 필수

**응답**:
```javascript
{
  success: true,
  message: "Interest removed successfully"
}
```

---

#### 2.3.3 용병 관심 추가
**엔드포인트**: `POST /api/mercenary-requests/:id/like`
**인증**: 필수

**응답**:
```javascript
{
  success: true,
  data: { id, user_id, mercenary_request_id, interest_type: "mercenary", created_at },
  message: "Mercenary request marked as interested"
}
```

---

#### 2.3.4 용병 관심 제거
**엔드포인트**: `DELETE /api/mercenary-requests/:id/like`
**인증**: 필수

**응답**:
```javascript
{
  success: true,
  message: "Interest removed successfully"
}
```

---

#### 2.3.5 관심 팀 매칭 목록 조회
**엔드포인트**: `GET /api/users/my/interests/matches`
**인증**: 필수

**쿼리 파라미터**:
- `page` (기본값: 1)
- `limit` (기본값: 10)

**응답**:
```javascript
{
  success: true,
  data: [
    {
      id, title, description, date, location, ...,
      team: { id, name, captain: { id, name, profile_image } }
    }
  ],
  pagination: {
    page: 1,
    limit: 10,
    total: 42,
    total_pages: 5
  }
}
```

---

#### 2.3.6 관심 용병 목록 조회
**엔드포인트**: `GET /api/users/my/interests/mercenary`
**인증**: 필수

**쿼리 파라미터**:
- `page` (기본값: 1)
- `limit` (기본값: 10)

**응답**:
```javascript
{
  success: true,
  data: [
    {
      id, title, description, date, location, ...,
      team: { id, name, captain: { id, name, profile_image } }
    }
  ],
  pagination: {
    page: 1,
    limit: 10,
    total: 28,
    total_pages: 3
  }
}
```

---

### 2.4 내 글 조회 API

#### 2.4.1 내가 작성한 팀 매칭 목록
**엔드포인트**: `GET /api/matches/my/created`
**인증**: 필수

**쿼리 파라미터**:
- `page` (기본값: 1)
- `limit` (기본값: 10)

**응답**:
```javascript
{
  success: true,
  data: [
    {
      id, title, description, date, location, fee,
      match_type, gender_type, max_participants,
      current_participants, status, is_active,
      team: { id, name, captain: { id, name, profile_image } }
    }
  ],
  pagination: {
    page: 1,
    limit: 10,
    total: 15,
    total_pages: 2
  }
}
```

**정렬**: created_at DESC (최신순)

---

#### 2.4.2 내가 작성한 용병 모집 목록
**엔드포인트**: `GET /api/mercenary-requests/my/created`
**인증**: 필수

**쿼리 파라미터**:
- `page` (기본값: 1)
- `limit` (기본값: 10)

**응답**:
```javascript
{
  success: true,
  data: [
    {
      id, title, description, date, location, fee,
      match_type, gender_type, mercenary_count,
      current_applicants, status, is_active,
      team: { id, name, captain: { id, name, profile_image } }
    }
  ],
  pagination: {
    page: 1,
    limit: 10,
    total: 8,
    total_pages: 1
  }
}
```

**정렬**: created_at DESC (최신순)

---

## 3. 수정된 기존 API

### 3.1 매칭 상세 조회 (업데이트)
**엔드포인트**: `GET /api/matches/:id`
**변경사항**: `is_interested_by_user` 필드 추가

---

### 3.2 용병 모집 목록 & 상세 (업데이트)
**변경사항**: UserInterest 조회 기능 추가

---

## 4. 파일 수정 및 생성 목록

### 생성된 파일
- ✅ `/src/models/UserProfile.js` (신규)
- ✅ `/src/models/UserInterest.js` (신규)

### 수정된 파일
- ✅ `/src/models/index.js` (모델 import + 관계 정의)
- ✅ `/src/routes/users.js` (프로필, 이미지, 관심 API)
- ✅ `/src/routes/mercenaryRequests.js` (용병 상세, 관심 like/unlike)
- ✅ `/src/routes/matches.js` (매칭 상세, 관심 like/unlike)

---

## 5. 기술 구현 세부사항

### 인증 처리
- 모든 프로필 및 관심 API는 JWT 인증 필수
- 토큰 검증 실패 시 401 Unauthorized 반환

### 데이터 검증
- 닉네임: 문자 길이 검증 (2-50자)
- 소개글: 문자 길이 검증 (0-500자)
- 이메일: 정규식 검증 (`/^[^\s@]+@[^\s@]+\.[^\s@]+$/`)
- 파일: 확장자 및 MIME 타입 검증 (jpg, png)

### 에러 처리
- 400 Bad Request: 데이터 검증 실패
- 401 Unauthorized: 인증 필요
- 404 Not Found: 리소스 없음
- 500 Internal Server Error: 서버 오류

### 페이지네이션
- 기본 limit: 10개
- offset 계산: `(page - 1) * limit`
- 응답: `{ page, limit, total, total_pages }`

### 파일 업로드
- 저장 경로: `/Server/uploads/profiles/`
- 파일명 패턴: `profile-{user_id}-{timestamp}.{ext}`
- 파일 크기 제한: 5MB
- 허용 포맷: jpg, png

---

## 6. 데이터베이스 동기화

서버 시작 시 자동으로 모든 모델이 데이터베이스와 동기화됩니다:
```javascript
dbConfig.sync({ alter: true })
```

**새로운 테이블**:
- `user_profiles`
- `user_interests`

**새로운 인덱스**:
- `user_interests` (user_id, match_id, mercenary_request_id, interest_type)

---

## 7. API 요청 예제

### 프로필 수정
```bash
curl -X PUT http://localhost:3000/api/users/profile/me \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "nickname": "축구짱",
    "bio": "11년 경력의 공격수입니다",
    "preferred_skill_level": "advanced"
  }'
```

### 프로필 이미지 업로드
```bash
curl -X POST http://localhost:3000/api/users/profile-image/me \
  -H "Authorization: Bearer {token}" \
  -F "image=@/path/to/profile.jpg"
```

### 용병 관심 추가
```bash
curl -X POST http://localhost:3000/api/mercenary-requests/{id}/like \
  -H "Authorization: Bearer {token}"
```

### 관심 목록 조회
```bash
curl -X GET "http://localhost:3000/api/users/my/interests/matches?page=1&limit=20" \
  -H "Authorization: Bearer {token}"
```

---

## 8. 테스트 체크리스트

- [ ] 프로필 생성 (자동 생성 확인)
- [ ] 프로필 조회 (GET /api/users/profile/me)
- [ ] 프로필 수정 (부분 수정 포함)
- [ ] 프로필 이미지 업로드 (파일 저장 확인)
- [ ] 용병 상세 조회 (is_interested_by_user 필드)
- [ ] 관심 추가 (POST /api/matches/:id/like)
- [ ] 관심 제거 (DELETE /api/matches/:id/like)
- [ ] 관심 목록 조회 (페이지네이션)
- [ ] 내글 조회 (최신순 정렬)
- [ ] 에러 처리 (400, 401, 404, 500)
- [ ] 데이터 검증 (닉네임, 이메일, 파일)

---

## 9. 주요 개선사항

1. **완전한 프로필 관리**: 닉네임, 소개글, 선호 포지션, 이미지 등 종합 관리
2. **관심 글 기능**: 사용자가 관심 있는 매칭/용병 관리
3. **내글 조회**: 사용자가 작성한 모든 글을 한 눈에 조회
4. **통합된 API**: 일관된 응답 형식과 에러 처리
5. **보안**: JWT 인증, 데이터 검증, 파일 검증
6. **확장성**: 향후 추가 필드나 기능 쉽게 확장 가능

---

## 10. 다음 단계

1. iOS 앱에서 새 API 연동
2. 포괄적인 단위 테스트 작성
3. 성능 최적화 (인덱싱, 캐싱)
4. 관심 수 카운터 기능 추가
5. 알림 기능 통합
