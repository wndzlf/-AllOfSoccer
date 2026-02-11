# Deployment Checklist & Release Notes
**Version**: 1.1.0
**Date**: 2026-02-11
**Branch**: claude

---

## Release Notes

### New Features

**iOS (4 screens)**:
1. **MercenaryDetailViewController** - 용병 모집 상세 화면 (위치, 날짜, 경기정보, 팀정보, 신청 버튼)
2. **UserProfileViewController** - 프로필 관리 (닉네임, 소개글, 포지션, 실력, 위치, 이미지)
3. **MyWritingViewController** - 내가 쓴 글 (팀 매칭 / 용병 모집 탭 전환, 페이지네이션)
4. **MyFavoritesViewController** - 관심 글 (찜한 팀 매칭 / 용병 모집, 하트 버튼)

**Backend (2 models + 4 API groups)**:
1. **UserProfile** model - 사용자 프로필 (1:1 with User)
2. **UserInterest** model - 관심 표시 (N:M User-Match/MercenaryRequest)
3. **Profile API** - GET/PUT /api/users/profile/me, POST /api/users/profile-image/me
4. **Interest API** - POST/DELETE likes for matches and mercenary requests
5. **Interest List API** - GET /api/users/my/interests/matches, /mercenary
6. **Enhanced Detail** - GET /api/mercenary-requests/:id (includes is_interested_by_user)

### Bug Fixes (from Phase 1)
- Age filter range overlap logic corrected in matches.js
- Mercenary filter parity: added match_type, gender_type, shoes_requirement, age_range filters
- TeamMatchViewController connected to live API (was showing sample data)

### Known Issues (See QA_INTEGRATION_TEST_REPORT.md)
- 4 P0 issues must be resolved before deployment
- 6 P1 issues recommended for this release
- 5 P2 issues deferred to next sprint

---

## Pre-Deployment Checklist

### 1. P0 Issue Resolution
- [ ] Fix iOS profile API URL: `/api/auth/profile` -> `/api/users/profile/me`
- [ ] Connect profile save to PUT `/api/users/profile/me`
- [ ] Fix iOS mercenary favorites URL: `mercenary-requests` -> `mercenary`
- [ ] Use actual API data in MercenaryDetail (match_type, gender_type, shoes_requirement)

### 2. Database
- [ ] Verify PostgreSQL is running and accessible
- [ ] Confirm Sequelize `{ alter: true }` mode is enabled for auto-migration
- [ ] Verify UserProfile table created with columns: nickname, bio, preferred_positions, preferred_skill_level, profile_image_url, location, phone, email
- [ ] Verify UserInterest table created with columns: user_id, match_id, mercenary_request_id, interest_type
- [ ] Verify unique constraints on UserInterest: (user_id, match_id), (user_id, mercenary_request_id)
- [ ] Check existing data integrity after alter

### 3. Backend Environment
- [ ] `JWT_SECRET` environment variable set
- [ ] `DATABASE_URL` or individual DB connection params configured
- [ ] Upload directory exists: `Server/uploads/profiles/`
- [ ] Upload directory has write permissions
- [ ] Node.js dependencies installed (`npm install`)
- [ ] Multer package available for file uploads
- [ ] CORS configured to allow iOS app connections

### 4. Backend Routes
- [ ] All routes registered in app.js/server.js:
  - `/api/matches` -> matches.js
  - `/api/mercenary-requests` -> mercenaryRequests.js
  - `/api/users` -> users.js
  - `/api/auth` -> auth.js
- [ ] Model associations defined in models/index.js:
  - User hasOne UserProfile
  - User hasMany UserInterest
  - UserInterest belongsTo Match
  - UserInterest belongsTo MercenaryRequest
- [ ] Rate limiter active (15min / 100 requests)
- [ ] Static file serving for `/uploads/` directory

### 5. iOS Build
- [ ] `baseURL` in APIService.swift points to production server IP
- [ ] Auth token storage/retrieval working (Auth.accessToken())
- [ ] All new files added to Xcode project:
  - MercenaryDetailViewController.swift
  - UserProfileViewController.swift
  - MyWritingViewController.swift
  - MyFavoritesViewController.swift
- [ ] JSON response models match backend response format
- [ ] No hardcoded localhost/development URLs

### 6. API Verification (manual smoke test)
- [ ] `POST /api/auth/signin` returns JWT token
- [ ] `GET /api/matches` returns match list
- [ ] `GET /api/mercenary-requests` returns mercenary list
- [ ] `GET /api/mercenary-requests/:id` returns detail with team info
- [ ] `GET /api/users/profile/me` returns or creates profile
- [ ] `PUT /api/users/profile/me` updates profile
- [ ] `POST /api/users/profile-image/me` accepts file upload
- [ ] `POST /api/matches/:id/like` creates interest record
- [ ] `GET /api/users/my/interests/matches` returns favorited matches
- [ ] `GET /api/users/my/interests/mercenary` returns favorited requests

### 7. Backward Compatibility
- [ ] Existing Match model unchanged
- [ ] Existing MercenaryRequest model has new columns (match_type, gender_type, shoes_requirement, age_range_min, age_range_max) with defaults
- [ ] Existing User model unchanged
- [ ] Existing API endpoints unchanged (no breaking changes)
- [ ] New tables (UserProfile, UserInterest) don't affect existing queries

---

## Post-Deployment Verification

### Smoke Tests
- [ ] Login -> View match list -> View match detail
- [ ] Login -> View mercenary list -> View mercenary detail -> Apply
- [ ] Login -> View profile -> Edit profile -> Save
- [ ] Login -> Like a match -> View favorites -> Unlike
- [ ] Login -> Create mercenary request -> View in "내가 쓴 글"

### Monitoring
- [ ] Check server logs for 500 errors
- [ ] Monitor database connection pool
- [ ] Verify rate limiter not blocking legitimate traffic
- [ ] Check file upload disk space
- [ ] Monitor API response times (target: <1s for all endpoints)

---

## Rollback Plan

If critical issues found post-deployment:

1. **Backend**: Revert to previous commit (`git checkout <previous-commit>`)
2. **Database**: UserProfile and UserInterest tables can be dropped safely (new tables, no existing data dependency)
3. **iOS**: Previous build available in Xcode archives
4. **MercenaryRequest columns**: New columns have defaults, won't break old queries

---

**Prepared by**: qa-documentation
**Approved by**: (pending team lead review)
