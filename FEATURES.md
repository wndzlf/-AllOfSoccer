# AllOfSoccer - 주요 기능 상세

## 1. 인증 및 사용자 관리

### 1.1 Apple Sign-In
- iOS의 Apple Sign-In으로 간편 로그인
- JWT 기반 토큰 인증
- 리프레시 토큰으로 자동 로그인 유지

**API**:
- `POST /api/auth/apple-signin`: Apple 인증 토큰으로 로그인
- `POST /api/auth/refresh`: 토큰 갱신
- `POST /api/auth/logout`: 로그아웃

**iOS 파일**:
- `Login/SignInViewController.swift`: 로그인 화면
- `Login/SignUpViewController.swift`: 회원가입 화면
- `Network/Auth.swift`: 인증 토큰 관리

### 1.2 프로필 관리
- 프로필 이미지 업로드
- 사용자 정보 수정
- 회원탈퇴

**API**:
- `GET /api/auth/profile`: 프로필 조회
- `PUT /api/auth/profile`: 프로필 수정
- `DELETE /api/auth/profile`: 회원탈퇴

---

## 2. 매칭 등록 (핵심 기능)

### 2.1 1단계: 기본 정보 입력
**FirstTeamRecruitmentViewController**

#### 입력 항목
1. **날짜/시간**
   - 캘린더 선택
   - 시간 선택

2. **장소**
   - 장소 검색 (`SearchPlaceView`)
   - 주소 자동 완성

3. **경기 종류**
   - 6 vs 6 (풋살)
   - 11 vs 11 (축구)

4. **성별 구분**
   - 남성 매치
   - 여성 매치
   - 혼성 매치

5. **신발 요구사항**
   - 풋살화 필수
   - 축구화 필수
   - 선출 포함 (선택사항)

6. **비용**
   - 구장비/참가비 입력

#### 특별 기능: 이전 매치 불러오기
- **목적**: 매주 같은 정보를 반복 입력하는 불편함 해소
- **동작**:
  1. "이전 매치 불러오기" 버튼 클릭
  2. 내가 등록한 매칭 목록 표시
  3. 선택하면 해당 정보로 폼 자동 채우기
  4. 날짜만 변경하고 바로 등록 가능

**API**: `GET /api/matches/my/created`

**iOS 파일**:
- `Recruitment/TeamRecruitment/FirstTeamRecruitmentViewController.swift`
- `Recruitment/Component/CallPreviusMatchingInformationView.swift`
- `Recruitment/Component/SearchPlaceView.swift`

### 2.2 2단계: 상세 정보 입력
**SecondTeamRecruitmentViewController**

#### 입력 항목
1. **연령대 범위**
   - 최소 연령 ~ 최대 연령
   - 슬라이더로 범위 선택

2. **실력 레벨**
   - 최소 실력 ~ 최대 실력
   - 레벨: beginner, intermediate, advanced, expert

3. **팀 소개**
   - 여러 줄의 소개 텍스트
   - 순서 변경 가능 (드래그)
   - 개별 삭제 가능

**iOS 파일**:
- `Recruitment/TeamRecruitment/SecondTeamRecruitmentViewController.swift`
- `Recruitment/TeamRecruitment/TeamIntroductionTableViewCell.swift`

### 2.3 매칭 생성 API

**엔드포인트**: `POST /api/matches`

**요청 예시**:
```json
{
  "title": "양원역 구장에서 11vs11 경기",
  "description": "11대 11 실력 하하 구장비 7천원",
  "date": "2024-09-14T22:00:00.000Z",
  "location": "양원역 구장",
  "address": "서울시 노원구 양원역 근처 구장",
  "fee": 7000,
  "max_participants": 22,
  "match_type": "11v11",
  "gender_type": "mixed",
  "shoes_requirement": "any",
  "age_range_min": 20,
  "age_range_max": 35,
  "skill_level_min": "beginner",
  "skill_level_max": "intermediate",
  "team_introduction": "FC 캘란입니다. 실력 하하 매너 최상상!",
  "team_id": "660e8400-e29b-41d4-a716-446655440001"
}
```

---

## 3. 매칭 검색 및 필터링

### 3.1 메인 화면
**GameMatchingViewController**

#### UI 구성
1. **캘린더 (Horizontal)**
   - 가로 스크롤 캘린더
   - 날짜 선택 시 필터링
   - 다중 선택 가능

2. **필터 태그**
   - 현재 적용된 필터 표시
   - 탭하면 필터 상세 화면 열림
   - 초기화 버튼

3. **매칭 리스트**
   - 카드 형태로 표시
   - 무한 스크롤 (페이징)
   - 정렬 옵션 (날짜순, 거리순)

**iOS 파일**:
- `Main/GameMatchingViewController.swift`
- `Main/GameMatchingViewModel.swift`
- `Main/GameMatchingTableViewCell.swift`
- `Main/GameMatchingSub/HorizontalCalendar/`

### 3.2 필터 상세
**FilterDetailView**

#### 필터 옵션
1. **날짜**: 특정 날짜 또는 날짜 범위
2. **장소**: 지역/구장 이름으로 검색
3. **경기 종류**: 6v6, 11v11
4. **성별**: 남성, 여성, 혼성
5. **신발**: 풋살화, 축구화, 무관
6. **연령대**: 최소/최대 연령
7. **실력 레벨**: 최소/최대 실력
8. **비용**: 최소/최대 금액
9. **상태**: 모집중, 마감, 완료

**iOS 파일**:
- `Main/GameMatchingSub/FilterDetail/FilterDetailView.swift`
- `Main/GameMatchingSub/FilterDetail/FilterDetailTagCollectionViewCell.swift`

### 3.3 매칭 목록 조회 API

**엔드포인트**: `GET /api/matches`

**쿼리 파라미터**:
```
?page=1
&limit=20
&location=양원역
&date=2024-09-14
&match_type=11v11
&gender_type=mixed
&shoes_requirement=any
&age_min=20
&age_max=35
&skill_level=intermediate
&fee_min=0
&fee_max=10000
&status=recruiting
&sort_by=date
&sort_order=DESC
```

**응답**:
```json
{
  "success": true,
  "data": [
    {
      "id": "...",
      "title": "양원역 구장에서 11vs11 경기",
      "location": "양원역 구장",
      "date": "2024-09-14T22:00:00.000Z",
      "fee": 7000,
      "current_participants": 15,
      "max_participants": 22,
      "match_type": "11v11",
      "team": {
        "name": "FC 캘란",
        "captain": {
          "name": "김팀장"
        }
      }
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

---

## 4. 매칭 상세 및 참가

### 4.1 매칭 상세 화면
**GameMatchingDetailViewController**

#### 표시 정보
- 경기 날짜/시간
- 장소 (지도 표시)
- 경기 종류, 성별, 신발 요구사항
- 비용
- 연령대, 실력 레벨
- 팀 소개
- 현재 참가 인원 / 최대 인원
- 팀 정보 (팀장, 팀 로고)

#### 액션
- 참가 신청
- 참가 취소
- 공유하기
- 즐겨찾기

**API**:
- `GET /api/matches/:id`: 매칭 상세 조회
- `POST /api/matches/:id/apply`: 참가 신청
- `DELETE /api/matches/:id/apply`: 참가 취소
- `GET /api/matches/:id/participants`: 참가자 목록

**iOS 파일**:
- `GamematchingDetail/GameMatchingDetailViewController.swift`
- `GamematchingDetail/GameMatchingDetailViewModel.swift`

---

## 5. 마이페이지

### 5.1 내 정보
- 프로필 이미지
- 이름, 이메일, 전화번호
- 프로필 수정

**iOS 파일**:
- `MyPage/MyinformationView/MyPageMyInformationViewController.swift`

### 5.2 팀 관리
- 내가 속한 팀 목록
- 팀 생성
- 팀 정보 수정
- 팀원 관리

**API**:
- `GET /api/teams/my/teams`: 내가 속한 팀
- `POST /api/teams`: 팀 생성
- `PUT /api/teams/:id`: 팀 수정
- `POST /api/teams/:id/members`: 팀원 추가

**iOS 파일**:
- `MyPage/TeamInformationView/MyPageTeamInfomationViewController.swift`
- `MyPage/TeamInformationView/MyPageAddTeamInfoViewController.swift`

### 5.3 내가 등록한 매칭
- 내가 등록한 매칭 목록
- 수정/삭제
- 참가자 관리

**API**: `GET /api/matches/my/created`

**iOS 파일**:
- `MyPage/MyWritingViewController/MyWritingViewController.swift`

### 5.4 즐겨찾기
- 즐겨찾기한 매칭 목록

**iOS 파일**:
- `MyPage/MyFavoriteViewController/MyFavoriteViewController.swift`

---

## 6. 실시간 기능 (Socket.io)

### 6.1 채팅
- 매칭별 채팅방
- 실시간 메시지 전송/수신
- 읽음 처리

**Socket.io 이벤트**:
- `join_match`: 매칭 룸 참가
- `leave_match`: 매칭 룸 나가기
- `send_message`: 메시지 전송
- `new_message`: 새 메시지 수신

### 6.2 실시간 알림
- 매칭 상태 변경
- 참가 신청/승인
- 새 매칭 등록
- 매칭 정원 마감

**Socket.io 이벤트**:
- `match_updated`: 매칭 정보 업데이트
- `new_application`: 새 참가 신청
- `new_match_available`: 새 매칭 등록
- `match_is_full`: 정원 마감

**백엔드 파일**:
- `Server/src/socket/socketHandler.js`

---

## 7. 파일 업로드

### 7.1 이미지 업로드
- 프로필 이미지
- 팀 로고

**API**:
- `POST /api/uploads/profile-image`
- `POST /api/uploads/team-logo`

**백엔드**:
- Multer 사용
- 파일 크기 제한: 10MB
- 저장 경로: `Server/uploads/`

---

## 8. 기타 기능

### 8.1 공지사항
- 앱 공지사항 조회

**iOS 파일**:
- `MyPage/NoticeView/MyPageNoticeViewController.swift`

### 8.2 버전 정보
- 현재 앱 버전 확인
- 업데이트 확인

**iOS 파일**:
- `MyPage/VersionView/MyPageVersionViewController.swift`

### 8.3 문의하기
- 문의 메일 발송

**iOS 파일**:
- `MyPage/QuestionsView/MyPageQuestionsViewController.swift`

---

## 향후 추가 예정 기능

### 1. 푸시 알림
- FCM 통합
- 매칭 알림, 채팅 알림

### 2. 결제 시스템
- 구장비 온라인 결제
- 결제 내역 관리

### 3. 평가 시스템
- 경기 후 상대팀 평가
- 매너 점수

### 4. 경기 기록
- 경기 결과 기록
- 팀 통계

### 5. 소셜 기능
- 팀 팔로우
- 친구 추가
- 팀원 추천
