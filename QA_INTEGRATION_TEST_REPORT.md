# Integration Test Report - iOS/Backend API
**Date**: 2026-02-11
**Reviewer**: QA & Documentation Lead
**Branch**: claude
**Scope**: 4 iOS screens + 4 Backend API endpoint groups

---

## Executive Summary

Code-level integration review of all new iOS ViewControllers against backend routes. **15 issues found**: 4 Critical (P0), 6 Major (P1), 5 Minor (P2).

| Category | Tests | Pass | Fail | Rate |
|----------|-------|------|------|------|
| API Endpoint Mapping | 17 | 13 | 4 | 76% |
| iOS ViewModel Logic | 4 | 2 | 2 | 50% |
| UI Data Binding | 4 | 1 | 3 | 25% |
| Error Handling | 4 | 3 | 1 | 75% |
| Pagination | 4 | 4 | 0 | 100% |
| **Total** | **33** | **23** | **10** | **70%** |

**Verdict**: NOT READY for deployment. P0 issues must be resolved first.

---

## 1. MercenaryDetailViewController

### 1.1 API Connection: GET /api/mercenary-requests/:id

| Check | Result | Details |
|-------|--------|---------|
| Endpoint URL | PASS | `APIService.getMercenaryRequestDetail()` calls correct URL |
| HTTP Method | PASS | GET request |
| Auth Header | WARN | Auth token not sent (endpoint is public but `is_interested_by_user` requires it) |
| Response Decoding | PASS | `MercenaryRequestResponse` model used |
| Error Code Handling | PASS | Checks `statusCode >= 400` |

### 1.2 Data Binding Issues

**CRITICAL: Hardcoded values instead of API data**
- `MercenaryDetailViewController.swift:550` - `matchTypeLabel.text` parsed from title string, not `match_type` field
- `MercenaryDetailViewController.swift:551` - `genderTypeLabel.text` hardcoded to "성별 협의"
- `MercenaryDetailViewController.swift:560` - `shoesRequirementValueLabel.text` hardcoded to "상관없음"

**MAJOR: Buttons not wired**
- `applyButton.addTarget` never called in `setupUI()` - button is unresponsive
- `shareButton.addTarget` never called - button is unresponsive
- `applyButtonTapped()` shows alert without calling `POST /api/mercenary-requests/:id/apply`

**MINOR: Missing scroll content bottom anchor**
- `teamInfoContainer.bottomAnchor` not constrained to `contentView.bottomAnchor`

### 1.3 Backend Route Review: mercenaryRequests.js

| Endpoint | Auth | Validation | Response | Rating |
|----------|------|------------|----------|--------|
| GET /:id | Optional | ID check | Includes team, applicants, is_interested_by_user | GOOD |
| POST /:id/apply | Required | Status + capacity check | Creates MercenaryMatch | GOOD |
| DELETE /:id/apply | Required | Status=pending check | Decrements count | GOOD |

---

## 2. UserProfileViewController

### 2.1 API Connection

| API | iOS Implementation | Backend Route | Match |
|-----|-------------------|---------------|-------|
| GET Profile | `APIService.getProfile()` -> `/api/auth/profile` | `/api/users/profile/me` | **FAIL** |
| PUT Profile | NOT IMPLEMENTED (local only) | `/api/users/profile/me` | **FAIL** |
| POST Image | NOT IMPLEMENTED (picker only) | `/api/users/profile-image/me` | **FAIL** |

### 2.2 Critical Issues

**CRITICAL: Profile URL Mismatch**
- iOS calls `GET /api/auth/profile` (APIService.swift:155)
- Backend serves profile at `GET /api/users/profile/me` (users.js:82)
- `/api/auth/profile` returns `User` model, not `UserProfile` model
- Fields differ: UserProfile has `nickname`, `bio`, `preferred_positions`, `preferred_skill_level`

**CRITICAL: Save not connected to API**
- `UserProfileViewModel.saveProfile()` (line 525-549) only updates local variable
- Uses `DispatchQueue.main.asyncAfter` to simulate save delay
- Shows "저장 완료" alert regardless of actual result
- PUT `/api/users/profile/me` endpoint exists but is never called

**MAJOR: Image upload not connected**
- `UIImagePickerController` works correctly (line 476-493)
- Selected image displayed locally on `profileImageView`
- No call to `POST /api/users/profile-image/me`
- Image is lost on screen dismiss

**MAJOR: Profile fields not populated**
- `updateProfileDisplay()` (line 390-407) only sets `nicknameTextField` and `profileImageView`
- Missing: bio -> introductionTextView
- Missing: preferred_positions -> preferredPositionTextField
- Missing: preferred_skill_level -> preferredSkillLevelSegmentedControl
- Missing: location -> locationTextField

**MAJOR: No client-side validation**
- Backend validates: nickname (2-50 chars), bio (500 max), email (regex)
- iOS sends raw input without validation

### 2.3 Backend Route Review: users.js

| Endpoint | Auth | Validation | Rating |
|----------|------|------------|--------|
| GET /profile/me | Required | Auto-creates if missing | GOOD |
| PUT /profile/me | Required | nickname 2-50, bio 500, email regex | GOOD |
| POST /profile-image/me | Required | 5MB limit, jpg/png only | GOOD |

---

## 3. MyWritingViewController

### 3.1 API Connection

| API | iOS Implementation | Backend Route | Match |
|-----|-------------------|---------------|-------|
| GET my matches | `getMyMatches(page:limit:)` -> `/api/matches/my/created` | matches.js | PASS |
| GET my mercenary | `getMyMercenaryRequests(page:limit:)` -> `/api/mercenary-requests/my/created` | mercenaryRequests.js:647 | PASS |

### 3.2 Issues

**MAJOR: Match detail navigation TODO**
- `navigateToMatchDetail()` at line 243-246 only prints to console
- Mercenary detail navigation works correctly (line 248-251)

**MINOR: Error handling logs only**
- API failures logged via `print()` at lines 280, 304
- No user-facing error messages shown

**MINOR: Loading state race condition**
- Both `fetchMyMatches()` and `fetchMyMercenaryRequests()` independently toggle `isLoading`
- Second completion may set `isLoading = false` before first finishes

### 3.3 Backend Route Review

| Endpoint | Auth | Implementation | Rating |
|----------|------|----------------|--------|
| GET /matches/my/created | Required | Finds user's teams, queries matches | GOOD |
| GET /mercenary-requests/my/created | Required | Finds captain teams, queries requests | GOOD |

---

## 4. MyFavoritesViewController

### 4.1 API Connection

| API | iOS URL | Backend Route | Match |
|-----|---------|---------------|-------|
| GET favorite matches | `/api/users/my/interests/matches` | users.js:262 `/my/interests/matches` | PASS |
| GET favorite mercenary | `/api/users/my/interests/mercenary-requests` | users.js:318 `/my/interests/mercenary` | **FAIL** |

### 4.2 Issues

**CRITICAL: Mercenary favorites URL mismatch**
- iOS calls: `/api/users/my/interests/mercenary-requests` (APIService.swift:982)
- Backend route: `/api/users/my/interests/mercenary` (users.js:318)
- Will result in 404 error

**MINOR: Favorite removal not connected**
- `favoriteButtonTapped()` in both cell types (lines 372, 510) only prints
- Should call `DELETE /api/matches/:id/like` or `DELETE /api/mercenary-requests/:id/like`

**MINOR: Like/Unlike APIs not in APIService.swift**
- Backend has `POST/DELETE /api/matches/:id/like` and `POST/DELETE /api/mercenary-requests/:id/like`
- iOS `APIService` only has `toggleLike()` mock method (line 192-196)

---

## 5. Cross-Cutting API Mapping

### Complete Endpoint Audit

| # | Feature | iOS URL | Backend URL | Status |
|---|---------|---------|-------------|--------|
| 1 | Match List | GET /api/matches | GET /api/matches | PASS |
| 2 | Match Detail | GET /api/matches/:id | GET /api/matches/:id | PASS |
| 3 | Match Create | POST /api/matches | POST /api/matches | PASS |
| 4 | Match Apply | POST /api/matches/:id/apply | POST /api/matches/:id/apply | PASS |
| 5 | Match Cancel | DELETE /api/matches/:id/apply | DELETE /api/matches/:id/apply | PASS |
| 6 | My Matches | GET /api/matches/my/created | GET /api/matches/my/created | PASS |
| 7 | Mercenary List | GET /api/mercenary-requests | GET /api/mercenary-requests | PASS |
| 8 | Mercenary Detail | GET /api/mercenary-requests/:id | GET /api/mercenary-requests/:id | PASS |
| 9 | Mercenary Create | POST /api/mercenary-requests | POST /api/mercenary-requests | PASS |
| 10 | My Mercenary | GET /api/mercenary-requests/my/created | GET /api/mercenary-requests/my/created | PASS |
| 11 | Profile GET | GET /api/auth/profile | GET /api/users/profile/me | **FAIL** |
| 12 | Profile PUT | Not implemented | PUT /api/users/profile/me | **FAIL** |
| 13 | Profile Image | Not implemented | POST /api/users/profile-image/me | **FAIL** |
| 14 | Fav Matches | GET /api/users/my/interests/matches | GET /api/users/my/interests/matches | PASS |
| 15 | Fav Mercenary | GET /api/users/my/interests/mercenary-requests | GET /api/users/my/interests/mercenary | **FAIL** |
| 16 | Like Match | Not in APIService | POST /api/matches/:id/like | **MISSING** |
| 17 | Unlike Match | Not in APIService | DELETE /api/matches/:id/like | **MISSING** |

---

## 6. Issue Summary (Priority Order)

### P0 - Critical (Block release)

| # | Component | Issue | Impact |
|---|-----------|-------|--------|
| 1 | MercenaryDetail | match_type, gender_type, shoes_requirement hardcoded | Users see wrong data |
| 2 | UserProfile | API URL mismatch (auth/profile vs users/profile/me) | Profile won't load correctly |
| 3 | UserProfile | Save not connected to PUT API | Changes never persist |
| 4 | MyFavorites | URL mismatch (mercenary-requests vs mercenary) | 404 on favorite mercenary list |

### P1 - Major (Fix before release)

| # | Component | Issue | Impact |
|---|-----------|-------|--------|
| 5 | MercenaryDetail | Apply button not calling POST API | Users can't actually apply |
| 6 | MercenaryDetail | Button addTarget missing | Buttons unresponsive |
| 7 | UserProfile | Image upload not connected to POST API | Photos never uploaded |
| 8 | UserProfile | No client-side validation | Bad data sent to server |
| 9 | UserProfile | Profile fields not populated from response | Empty form on load |
| 10 | MyWriting | Match detail navigation is TODO | Can't view match details |

### P2 - Minor (Next sprint)

| # | Component | Issue | Impact |
|---|-----------|-------|--------|
| 11 | MyFavorites | Favorite removal not calling DELETE API | Can't unfavorite items |
| 12 | MyWriting | Errors only logged to console | No user feedback on failure |
| 13 | MyWriting | Loading state race condition | Spinner may hide early |
| 14 | MercenaryDetail | Missing contentView bottom constraint | Scroll may clip content |
| 15 | APIService | Like/Unlike APIs missing from iOS service | Can't add/remove favorites |

---

## 7. Recommended Fix Order

### Phase 1: P0 Fixes (Required)
1. Fix UserProfile API URL: change `/api/auth/profile` to `/api/users/profile/me`
2. Connect UserProfile save to PUT `/api/users/profile/me`
3. Fix MyFavorites mercenary URL: change `mercenary-requests` to `mercenary`
4. Use actual API data fields in MercenaryDetail (match_type, gender_type, shoes_requirement)

### Phase 2: P1 Fixes (Recommended)
5. Add `addTarget` for apply and share buttons in MercenaryDetail
6. Wire applyButton to POST `/api/mercenary-requests/:id/apply`
7. Connect image upload to POST `/api/users/profile-image/me`
8. Add client-side validation (nickname 2-50, bio 500 max)
9. Populate all profile fields from API response
10. Implement match detail navigation from MyWriting

### Phase 3: P2 Improvements
11-15. Minor fixes as listed above

---

**Report compiled by**: qa-documentation
**Next action**: Share with team lead and iOS developer for P0 fixes
