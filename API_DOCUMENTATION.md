# AllOfSoccer API Documentation
**Version**: 1.1.0
**Base URL**: `http://{SERVER_IP}:3000`
**Last Updated**: 2026-02-11

---

## Authentication

All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <JWT_TOKEN>
```

Token is obtained via `/api/auth/signin`, `/api/auth/signup`, or `/api/auth/apple-signin`.

---

## 1. User Profile API

### GET /api/users/profile/me
Get current user's profile.

**Auth**: Required

**Response** (200):
```json
{
  "success": true,
  "data": {
    "id": 1,
    "user_id": "uuid",
    "nickname": "축구왕",
    "bio": "주말마다 축구합니다",
    "preferred_positions": ["FW", "MF"],
    "preferred_skill_level": "intermediate",
    "profile_image_url": "/uploads/profiles/profile-uuid-123.jpg",
    "location": "강남구",
    "phone": "010-1234-5678",
    "email": "user@example.com",
    "created_at": "2026-02-08T10:00:00.000Z",
    "updated_at": "2026-02-10T15:30:00.000Z"
  }
}
```

**Notes**: If no profile exists, an empty profile is auto-created.

---

### PUT /api/users/profile/me
Update current user's profile (partial update supported).

**Auth**: Required

**Request Body**:
```json
{
  "nickname": "새닉네임",
  "bio": "새로운 소개글",
  "preferred_positions": ["GK", "DF"],
  "preferred_skill_level": "advanced",
  "location": "서초구",
  "phone": "010-9876-5432",
  "email": "new@example.com"
}
```

**Validation**:
| Field | Rule |
|-------|------|
| nickname | 2-50 characters |
| bio | Max 500 characters |
| email | Valid email format (regex) |

**Response** (200):
```json
{
  "success": true,
  "data": { "...updated profile..." },
  "message": "Profile updated successfully"
}
```

**Error** (400):
```json
{
  "success": false,
  "message": "Nickname must be between 2 and 50 characters"
}
```

---

### POST /api/users/profile-image/me
Upload profile image.

**Auth**: Required
**Content-Type**: `multipart/form-data`

**Request**: Form field `image` with file

**Constraints**:
- Max file size: 5MB
- Allowed formats: JPEG, PNG

**Response** (201):
```json
{
  "success": true,
  "data": {
    "profile_image_url": "/uploads/profiles/profile-uuid-1707391200000-123456789.jpg"
  },
  "message": "Profile image uploaded successfully"
}
```

**Errors**:
| Code | Message |
|------|---------|
| 400 | "No image file provided" |
| 400 | "Only jpg and png images are allowed" |
| 413 | File exceeds 5MB limit |

---

## 2. Interest (Favorites) API

### POST /api/matches/:id/like
Add a team match to favorites.

**Auth**: Required

**Response** (201):
```json
{
  "success": true,
  "data": {
    "id": 1,
    "user_id": "uuid",
    "match_id": "uuid",
    "interest_type": "match",
    "created_at": "2026-02-11T10:00:00.000Z"
  },
  "message": "Match marked as interested"
}
```

**Error** (400): Already liked
```json
{
  "success": false,
  "message": "You have already marked this match as interested"
}
```

---

### DELETE /api/matches/:id/like
Remove a team match from favorites.

**Auth**: Required

**Response** (200):
```json
{
  "success": true,
  "message": "Interest removed successfully"
}
```

**Error** (404): Interest not found.

---

### POST /api/mercenary-requests/:id/like
Add a mercenary request to favorites.

**Auth**: Required

**Response** (201):
```json
{
  "success": true,
  "data": {
    "id": 2,
    "user_id": "uuid",
    "mercenary_request_id": "uuid",
    "interest_type": "mercenary",
    "created_at": "2026-02-11T10:00:00.000Z"
  },
  "message": "Mercenary request marked as interested"
}
```

---

### DELETE /api/mercenary-requests/:id/like
Remove a mercenary request from favorites.

**Auth**: Required

**Response** (200):
```json
{
  "success": true,
  "message": "Interest removed successfully"
}
```

---

## 3. Interest List API

### GET /api/users/my/interests/matches
Get user's favorite team matches.

**Auth**: Required

**Query Parameters**:
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| page | int | 1 | Page number |
| limit | int | 10 | Items per page |

**Response** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "강남 6v6 경기",
      "date": "2026-03-01T19:00:00.000Z",
      "location": "강남구",
      "match_type": "6v6",
      "fee": 5000,
      "current_participants": 8,
      "max_participants": 12,
      "team": {
        "name": "FC Seoul",
        "captain": {
          "id": "uuid",
          "name": "김팀장",
          "profile_image": null
        }
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 25,
    "total_pages": 3
  }
}
```

---

### GET /api/users/my/interests/mercenary
Get user's favorite mercenary requests.

**Auth**: Required

**Query Parameters**: Same as above (page, limit)

**Response** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "용병 모집합니다",
      "date": "2026-03-05T18:00:00.000Z",
      "location": "서초구",
      "fee": 10000,
      "mercenary_count": 3,
      "current_applicants": 1,
      "match_type": "11v11",
      "gender_type": "mixed",
      "shoes_requirement": "soccer",
      "team": {
        "name": "FC Test",
        "captain": {
          "id": "uuid",
          "name": "박캡틴",
          "profile_image": "/uploads/profiles/profile-123.jpg"
        }
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 8,
    "total_pages": 1
  }
}
```

**IMPORTANT**: iOS clients must use `/mercenary` (NOT `/mercenary-requests`).

---

## 4. Mercenary Request Detail API

### GET /api/mercenary-requests/:id
Get mercenary request details with team info and applicants.

**Auth**: Optional (enables `is_interested_by_user` field)

**Response** (200):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "team_id": "uuid",
    "title": "강남 11v11 용병 모집",
    "description": "포지션: FW, MF 구합니다",
    "date": "2026-03-01T19:00:00.000Z",
    "location": "강남구",
    "address": "강남대로 123",
    "latitude": 37.4979,
    "longitude": 127.0276,
    "fee": 50000,
    "mercenary_count": 2,
    "current_applicants": 1,
    "positions_needed": {"FW": 1, "MF": 1},
    "skill_level_min": "intermediate",
    "skill_level_max": "expert",
    "match_type": "11v11",
    "gender_type": "mixed",
    "shoes_requirement": "soccer",
    "status": "recruiting",
    "is_active": true,
    "created_at": "2026-02-08T10:00:00.000Z",
    "team": {
      "id": "uuid",
      "name": "FC Seoul",
      "captain": {
        "id": "uuid",
        "name": "김팀장",
        "profile_image": null
      }
    },
    "MercenaryMatches": [
      {
        "id": "uuid",
        "user_id": "uuid",
        "status": "pending",
        "User": {
          "id": "uuid",
          "name": "이선수",
          "profile_image": null
        }
      }
    ],
    "team_introduction": null,
    "team_captain_name": "김팀장",
    "team_captain_image": null,
    "is_interested_by_user": false
  }
}
```

**Error** (404):
```json
{
  "success": false,
  "message": "Mercenary request not found"
}
```

---

## 5. My Content API

### GET /api/matches/my/created
Get matches created by current user.

**Auth**: Required

**Query Parameters**:
| Param | Type | Default |
|-------|------|---------|
| page | int | 1 |
| limit | int | 20 |

**Response**: Same structure as match list with pagination.

---

### GET /api/mercenary-requests/my/created
Get mercenary requests created by current user's teams.

**Auth**: Required

**Query Parameters**: Same (page, limit)

**Response**: Same structure as mercenary request list with pagination.

---

## 6. Common Response Formats

### Success Response
```json
{
  "success": true,
  "data": { ... },
  "message": "Optional success message",
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Human-readable error description",
  "error": "Technical error detail (dev only)"
}
```

### HTTP Status Codes
| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized (missing/invalid token) |
| 403 | Forbidden (not owner/captain) |
| 404 | Not Found |
| 429 | Too Many Requests (rate limited) |
| 500 | Internal Server Error |

---

## 7. Rate Limiting
- **Window**: 15 minutes
- **Max Requests**: 100 per window
- **Response when exceeded**: 429 with plain text "Too many requests from this IP"

---

## 8. Filter Parameters (List Endpoints)

### GET /api/matches
| Param | Type | Example | Description |
|-------|------|---------|-------------|
| location | string | "강남" | Location filter (partial match, case-insensitive) |
| date | ISO 8601 | "2026-03-01" | Matches on or after date |
| match_type | enum | "6v6", "11v11" | Match format |
| gender_type | enum | "male", "female", "mixed" | Gender restriction |
| shoes_requirement | enum | "futsal", "soccer", "any" | Shoe type |
| age_min | int | 20 | Minimum age (range overlap logic) |
| age_max | int | 35 | Maximum age (range overlap logic) |
| skill_level | string | "intermediate" | Skill level filter |
| fee_min | int | 0 | Minimum fee |
| fee_max | int | 50000 | Maximum fee |
| status | string | "recruiting" | Match status |
| sort_by | string | "created_at" | Sort field |
| sort_order | string | "DESC" | Sort direction |

### GET /api/mercenary-requests
Same parameters as above, with identical filter logic.

**Age Range Logic**: Uses overlap checking:
```
request.age_range_max >= filter.age_min AND request.age_range_min <= filter.age_max
```
