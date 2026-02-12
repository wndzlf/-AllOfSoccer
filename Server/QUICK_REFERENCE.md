# 백엔드 API 빠른 참조 가이드

## 1. 모델 구조

### UserProfile
```javascript
{
  id: UUID,
  user_id: UUID (1:1),
  nickname: String(2-50),
  bio: String(0-500),
  profile_image_url: String,
  preferred_positions: Array,
  preferred_skill_level: Enum,
  location: String,
  phone: String,
  email: String
}
```

### UserInterest
```javascript
{
  id: UUID,
  user_id: UUID,
  match_id: UUID | null,
  mercenary_request_id: UUID | null,
  interest_type: 'match' | 'mercenary'
}
```

---

## 2. 엔드포인트 빠른 참조

### 프로필 관리
```
GET    /api/users/profile/me                    # 조회
PUT    /api/users/profile/me                    # 수정 (부분 수정 O)
POST   /api/users/profile-image/me              # 이미지 업로드
```

### 관심 관리 (Like/Unlike)
```
POST   /api/matches/:id/like                    # 팀 매칭 관심 추가
DELETE /api/matches/:id/like                    # 팀 매칭 관심 제거
POST   /api/mercenary-requests/:id/like         # 용병 관심 추가
DELETE /api/mercenary-requests/:id/like         # 용병 관심 제거
```

### 관심 목록
```
GET    /api/users/my/interests/matches          # 관심 팀 매칭 목록
GET    /api/users/my/interests/mercenary        # 관심 용병 목록
```

### 상세 조회 (개선됨)
```
GET    /api/mercenary-requests/:id              # 용병 상세 (is_interested_by_user 추가)
GET    /api/matches/:id                         # 팀 매칭 상세 (is_interested_by_user 추가)
```

### 내 글 조회
```
GET    /api/matches/my/created                  # 내가 작성한 팀 매칭
GET    /api/mercenary-requests/my/created       # 내가 작성한 용병
```

---

## 3. 요청 예제

### 프로필 조회
```bash
GET /api/users/profile/me
Authorization: Bearer {token}
```

### 프로필 수정
```bash
PUT /api/users/profile/me
Authorization: Bearer {token}
Content-Type: application/json

{
  "nickname": "축구짱",
  "bio": "11년 경력의 골키퍼입니다",
  "preferred_skill_level": "advanced",
  "location": "서울시 강남구"
}
```

### 프로필 이미지 업로드
```bash
POST /api/users/profile-image/me
Authorization: Bearer {token}
Content-Type: multipart/form-data

# 폼 필드: image (파일)
```

### 용병 관심 추가
```bash
POST /api/mercenary-requests/{mercenary_id}/like
Authorization: Bearer {token}
```

### 용병 관심 제거
```bash
DELETE /api/mercenary-requests/{mercenary_id}/like
Authorization: Bearer {token}
```

### 관심 목록 조회
```bash
GET /api/users/my/interests/matches?page=1&limit=20
Authorization: Bearer {token}
```

---

## 4. 응답 형식

### 성공 응답
```javascript
{
  success: true,
  data: { /* 데이터 */ },
  pagination: { page, limit, total, total_pages }  // 페이지네이션 있을 때만
}
```

### 에러 응답
```javascript
{
  success: false,
  message: "에러 메시지",
  error: "상세 에러 정보"
}
```

---

## 5. 상태 코드

| 코드 | 의미 | 예시 |
|------|------|------|
| 200 | 성공 | 조회, 수정 |
| 201 | 생성됨 | 생성, 이미지 업로드 |
| 400 | 잘못된 요청 | 데이터 검증 실패 |
| 401 | 미인증 | 토큰 없음/만료 |
| 403 | 권한 없음 | 다른 사용자 글 수정 |
| 404 | 찾을 수 없음 | 리소스 없음 |
| 500 | 서버 오류 | 데이터베이스 오류 |

---

## 6. 데이터 검증 규칙

| 필드 | 규칙 | 에러 |
|------|------|------|
| nickname | 2-50자 | 400 Bad Request |
| bio | 0-500자 | 400 Bad Request |
| email | 유효한 이메일 | 400 Bad Request |
| image | 5MB 이하 | 400 Bad Request |
| image | jpg/png만 | 400 Bad Request |

---

## 7. 페이지네이션

### 요청 파라미터
```javascript
{
  page: 1,      // 기본값: 1
  limit: 10     // 기본값: 10 (최대 제한 없음)
}
```

### 응답
```javascript
{
  success: true,
  data: [ /* 데이터 배열 */ ],
  pagination: {
    page: 1,
    limit: 10,
    total: 42,
    total_pages: 5
  }
}
```

---

## 8. 파일 업로드

### 지원 형식
- MIME Type: image/jpeg, image/png
- 확장자: .jpg, .jpeg, .png
- 최대 크기: 5MB

### 저장 위치
```
/Server/uploads/profiles/profile-{user_id}-{timestamp}.{ext}
```

### 예제
```bash
curl -X POST http://localhost:3000/api/users/profile-image/me \
  -H "Authorization: Bearer {token}" \
  -F "image=@profile.jpg"

# 응답
{
  "success": true,
  "data": {
    "profile_image_url": "/uploads/profiles/profile-uuid-1644325600000.jpg"
  }
}
```

---

## 9. 자주 사용하는 쿼리

### 프로필이 없으면 자동 생성
```javascript
// GET /api/users/profile/me 호출 시
// 프로필이 없으면 자동으로 생성되어 반환됨
```

### 관심 중복 확인
```javascript
// POST /api/matches/:id/like
// 이미 관심 표시했으면 400 에러 반환
```

### 관심 제거
```javascript
// DELETE /api/matches/:id/like
// 관심 레코드가 없으면 404 에러 반환
```

---

## 10. 인증

### 토큰 포함
```bash
Authorization: Bearer {jwt_token}
```

### 토큰 없이 접근 가능한 API
```
GET /api/matches/              # 목록 조회
GET /api/matches/:id           # 상세 조회 (is_interested_by_user는 false)
GET /api/mercenary-requests/   # 목록 조회
GET /api/mercenary-requests/:id # 상세 조회 (is_interested_by_user는 false)
```

### 토큰 필수 API
```
GET    /api/users/profile/me
PUT    /api/users/profile/me
POST   /api/users/profile-image/me
POST   /api/matches/:id/like
DELETE /api/matches/:id/like
POST   /api/mercenary-requests/:id/like
DELETE /api/mercenary-requests/:id/like
GET    /api/users/my/interests/matches
GET    /api/users/my/interests/mercenary
GET    /api/matches/my/created
GET    /api/mercenary-requests/my/created
```

---

## 11. 일반적인 에러 메시지

```javascript
// 닉네임 검증 실패
{ success: false, message: "Nickname must be between 2 and 50 characters" }

// 이메일 형식 오류
{ success: false, message: "Invalid email format" }

// 파일 크기 초과
{ success: false, message: "File size exceeds 5MB limit" }

// 지원되지 않는 파일 형식
{ success: false, message: "Only jpg and png images are allowed" }

// 미인증
{ success: false, message: "Unauthorized" } // 401

// 리소스 없음
{ success: false, message: "Match not found" } // 404
```

---

## 12. iOS 통합 예제

### Swift URLSession
```swift
// 프로필 조회
let url = URL(string: "http://localhost:3000/api/users/profile/me")!
var request = URLRequest(url: url)
request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

URLSession.shared.dataTask(with: request) { data, response, error in
    guard let data = data else { return }
    let profile = try? JSONDecoder().decode(UserProfile.self, from: data)
}.resume()

// 관심 추가
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
URLSession.shared.dataTask(with: request).resume()
```

---

## 13. 주의사항

1. **인증 토큰**: 모든 사용자 관련 API는 유효한 JWT 토큰 필요
2. **부분 수정**: PUT /api/users/profile/me는 필드 일부만 보내도 됨
3. **관심 중복**: 같은 글에 대한 관심은 한 번만 추가 가능
4. **파일 저장**: 이미지 업로드 후 경로는 profile_image_url 필드에 저장됨
5. **페이지네이션**: 내 글 조회는 페이지네이션 필수, 관심 목록도 권장

---

## 14. 디버깅 팁

### 응답 없음
- 토큰 확인
- 서버 로그 확인 (console.error)
- 네트워크 연결 확인

### 400 에러
- 요청 바디 형식 확인 (Content-Type)
- 데이터 검증 규칙 확인
- 필수 필드 확인

### 401 에러
- 토큰 유효성 확인
- 토큰 만료 여부 확인
- Authorization 헤더 형식 확인

### 404 에러
- 리소스 ID 확인
- 엔드포인트 URL 확인
- 리소스 삭제 여부 확인
