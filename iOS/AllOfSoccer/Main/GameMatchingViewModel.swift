//
//  GameMatchingViewModel.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2022/01/09.
//

import Foundation

enum MatchingMode {
    case teamMatching
    case manMatching
}

enum CollecionviewType: String {
    case HorizontalCalendarView
    case FilterTagCollectionView
}

enum FilterType: CaseIterable {
    case location
    case game
    case status

    var tagTitle: String {
        switch self {
        case .location: return "장소"
        case .game: return "경기 종류"
        case .status: return "매칭 여부"
        }
    }

    var filterList: [String] {
        switch self {
        case .location: return [
            "서울북부",
            "서울남부",
            "경기북부",
            "경기남부",
            "인천/부천",
            "기타지역"
        ]
        case .game: return ["11 vs 11", "풋살"]
        case .status: return ["매칭 완료", "매칭 중"]
        }
    }
}

protocol GameMatchingPresenter: AnyObject {
    func reloadMatchingList()
    func showErrorMessage()
}

class GameMatchingViewModel {

    internal weak var presenter: GameMatchingPresenter?

    // MARK: - Properties
    internal private(set) var selectedDate: [Date] = []
    
    // 원본 데이터 저장
    private var originalMatches: [Match] = []
    private var matchingListViewModel: [GameMatchListViewModel] = []
    
    // 필터링된 데이터 (필터 적용 시 사용)
    private var filteredMatches: [Match] = []
    private var filteredViewModel: [GameMatchListViewModel] = []
    
    // 필터 상태
    private var currentLocationFilters: [String] = []
    private var currentGameTypeFilters: [String] = []
    private var currentStatusFilters: [String] = []
    private var isFilterApplied: Bool = false // 필터가 적용되었는지 여부

    internal var count: Int {
        // 필터가 적용되었으면 필터링된 데이터 개수 반환 (0개일 수도 있음)
        return isFilterApplied ? filteredViewModel.count : matchingListViewModel.count
    }
    
    // Helper function to create status types from Match data
    private func createStatusTypes(from match: Match) -> (primary: MatchStatusType?, secondary: MatchStatusType?) {
        guard match.status == "recruiting" else {
            return (nil, nil)
        }
        
        let hasMercenary = (match.mercenaryRecruitmentCount ?? 0) > 0
        let hasMatched = match.isOpponentMatched ?? false
        
        if hasMercenary && hasMatched {
            return (.mercenaryRecruitment(count: match.mercenaryRecruitmentCount!), .teamMatched)
        } else if hasMercenary {
            return (.mercenaryRecruitment(count: match.mercenaryRecruitmentCount!), nil)
        } else if hasMatched {
            return (.teamMatched, nil)
        } else {
            return (.mercenaryRecruitment(count: 0), nil)
        }
    }

    internal func fetchViewModel(indexPath: IndexPath) -> GameMatchListViewModel {
        // 필터가 적용되었으면 필터링된 데이터 반환
        if isFilterApplied {
            guard indexPath.row < filteredViewModel.count else {
                return GameMatchListViewModel(
                    id: "",
                    date: "",
                    time: "",
                    address: "",
                    description: "",
                    isFavorite: false,
                    isRecruiting: false,
                    teamName: "",
                    primaryStatus: nil,
                    secondaryStatus: nil,
                    hasFormerPlayer: nil
                )
            }
            return filteredViewModel[indexPath.row]
        } else {
            return matchingListViewModel[indexPath.row]
        }
    }
    
    // 원본 Match 데이터 반환
    internal func getOriginalMatch(at indexPath: IndexPath) -> Match? {
        // 필터가 적용되었으면 필터링된 데이터에서 가져오기
        let matches = isFilterApplied ? filteredMatches : originalMatches
        guard indexPath.row < matches.count else { return nil }
        return matches[indexPath.row]
    }
    
    // 원본 Match 데이터 배열 반환
    internal func getAllOriginalMatches() -> [Match] {
        return originalMatches
    }

    internal var formalStrSelectedDate: [String] {
        let strSelectedDate = self.selectedDate.map { self.changeDateToString($0) }
        return strSelectedDate
    }

    //중현: 생성하는 시점에 viewModel을 fetch
    init() {
        Task { [weak self] in
            guard let self = self else {
                return
            }
            do {
                try await self.fetchMatchingList()
                self.presenter?.reloadMatchingList()
            } catch {
                self.presenter?.showErrorMessage()
            }
        }
    }

    // 날짜 문자열을 Date로 파싱 (ISO 8601 및 yyyy-MM-dd 모두 지원)
    private func parseDate(from dateString: String) -> Date {
        // ISO 8601 형식 시도 (서버: "2024-09-14T22:00:00.000Z")
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso8601Formatter.date(from: dateString) { return date }

        // 소수점 없는 ISO 8601
        iso8601Formatter.formatOptions = [.withInternetDateTime]
        if let date = iso8601Formatter.date(from: dateString) { return date }

        // yyyy-MM-dd 형식 (Mock 데이터)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString) { return date }

        return Date()
    }

    // Match -> GameMatchListViewModel 변환
    private func convertToViewModel(match: Match) -> GameMatchListViewModel {
        let date = parseDate(from: match.date)

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MM.dd.E"
        displayFormatter.locale = Locale(identifier: "ko_KR")
        let displayDate = displayFormatter.string(from: date)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = TimeZone.current
        let time = timeFormatter.string(from: date)

        let description = "\(match.matchType) 실력 하하 구장비 \(match.fee)원"
        let statuses = createStatusTypes(from: match)

        return GameMatchListViewModel(
            id: match.id,
            date: displayDate,
            time: time,
            address: match.location,
            description: description,
            isFavorite: false,
            isRecruiting: match.status == "recruiting",
            teamName: match.team?.name ?? "알 수 없음",
            primaryStatus: statuses.primary,
            secondaryStatus: statuses.secondary,
            hasFormerPlayer: match.hasFormerPlayer
        )
    }

    private func fetchMatchingList() async throws {
        APIService.shared.getMatches(
            page: 1,
            limit: 20,
            status: "recruiting"
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let matchResponse):
                    self?.originalMatches = matchResponse.data
                    self?.matchingListViewModel = matchResponse.data.map { match in
                        self?.convertToViewModel(match: match) ?? GameMatchListViewModel(
                            id: "", date: "", time: "", address: "", description: "",
                            isFavorite: false, isRecruiting: false, teamName: "",
                            primaryStatus: nil, secondaryStatus: nil, hasFormerPlayer: nil
                        )
                    }
                    self?.presenter?.reloadMatchingList()

                case .failure(let error):
                    print("매칭 데이터 가져오기 실패: \(error)")
                    self?.setupMockData()
                    self?.presenter?.reloadMatchingList()
                    self?.presenter?.showErrorMessage()
                }
            }
        }
    }
    
    // 목 데이터 설정
    private func setupMockData() {
        // 현재 날짜 기준으로 날짜 생성
        let calendar = Calendar.current
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // 목 Match 데이터 생성 - 더 다양한 데이터
        let mockMatches = [
            // 서울남부 지역 - 11 vs 11 (오늘부터 0일 후)
            Match(
                id: "1",
                title: "FC 강남 모집",
                description: "11 vs 11 실력 중상 구장비 10만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 0, to: today) ?? today),
                location: "서울남부",
                address: "서울시 강남구 역삼동 테헤란로 축구장",
                latitude: "37.4979",
                longitude: "127.0276",
                fee: 100000,
                maxParticipants: 22,
                currentParticipants: 18,
                matchType: "11 vs 11",
                genderType: "male",
                shoesRequirement: "cleats",
                ageRangeMin: 25,
                ageRangeMax: 40,
                skillLevelMin: "intermediate",
                skillLevelMax: "advanced",
                teamIntroduction: "안녕하세요 FC 강남입니다. 강남 지역에서 활동하는 팀으로 실력 있는 선수들을 모집합니다! 안녕하세요 FC 강남입니다. 강남 지역에서 활동하는 팀으로 실력 있는 선수들을 모집합니다! 안녕하세요 FC 강남입니다. 강남 지역에서 활동하는 팀으로 실력 있는 선수들을 모집합니다! 안녕하세요 FC 강남입니다. 강남 지역에서 활동하는 팀으로 실력 있는 선수들을 모집합니다! 안녕하세요 FC 강남입니다. 강남 지역에서 활동하는 팀으로 실력 있는 선수들을 모집합니다! 안녕하세요 FC 강남입니다. 강남 지역에서 활동하는 팀으로 실력 있는 선수들을 모집합니다! 안녕하세요 FC 강남입니다. 강남 지역에서 활동하는 팀으로 실력 있는 선수들을 모집합니다! 안녕하세요 FC 강남입니다. 강남 지역에서 활동하는 팀으로 실력 있는 선수들을 모집합니다!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: false,
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-01T10:00:00Z",
                updatedAt: "2024-11-01T10:00:00Z",
                team: Team(
                    id: "1",
                    name: "FC 강남",
                    logo: nil,
                    captain: UserProfile(id: "1", name: "김강남", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 서울남부 지역 - 다양한 데이터 생성
            Match(
                id: "101",
                title: "강남 11vs11 남성 축구화",
                description: "11 vs 11 실력 중상 구장비 10만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 0, to: today) ?? today),
                location: "서울남부",
                address: "서울시 강남구 대치동 유수지 체육공원",
                latitude: "37.4979",
                longitude: "127.0276",
                fee: 100000,
                maxParticipants: 22,
                currentParticipants: 18,
                matchType: "11 vs 11",
                genderType: "male",
                shoesRequirement: "cleats",
                ageRangeMin: 20,
                ageRangeMax: 30,
                skillLevelMin: "intermediate",
                skillLevelMax: "advanced",
                teamIntroduction: "강남에서 11대11 축구하실 분!",
                mercenaryRecruitmentCount: 3,
                isOpponentMatched: true, // 둘 다 표시: "용병 3명 모집중" + "매칭 완료"
                hasFormerPlayer: true, // 선출 있음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-01T10:00:00Z",
                updatedAt: "2024-11-01T10:00:00Z",
                team: Team(id: "101", name: "강남 FC", logo: nil, captain: UserProfile(id: "101", name: "김강남", profileImage: nil))
            ),
            Match(
                id: "102",
                title: "서초 풋살 혼성 실내화",
                description: "풋살 실력 초급 구장비 5만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 0, to: today) ?? today),
                location: "서울남부",
                address: "서울시 서초구 반포동 풋살장",
                latitude: "37.5000",
                longitude: "127.0000",
                fee: 50000,
                maxParticipants: 12,
                currentParticipants: 8,
                matchType: "풋살",
                genderType: "mixed",
                shoesRequirement: "indoor",
                ageRangeMin: 20,
                ageRangeMax: 40,
                skillLevelMin: "beginner",
                skillLevelMax: "beginner",
                teamIntroduction: "서초에서 즐겁게 풋살해요!",
                mercenaryRecruitmentCount: 2, // 용병 2명 모집만
                isOpponentMatched: false,
                hasFormerPlayer: false, // 선출 없음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-01T10:00:00Z",
                updatedAt: "2024-11-01T10:00:00Z",
                team: Team(id: "102", name: "서초 풋살", logo: nil, captain: UserProfile(id: "102", name: "이서초", profileImage: nil))
            ),
            Match(
                id: "103",
                title: "송파 11vs11 여성 축구화",
                description: "11 vs 11 실력 중급 구장비 8만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 0, to: today) ?? today),
                location: "서울남부",
                address: "서울시 송파구 잠실동 종합운동장",
                latitude: "37.5100",
                longitude: "127.0700",
                fee: 80000,
                maxParticipants: 22,
                currentParticipants: 10,
                matchType: "11 vs 11",
                genderType: "female",
                shoesRequirement: "cleats",
                ageRangeMin: 20,
                ageRangeMax: 35,
                skillLevelMin: "intermediate",
                skillLevelMax: "intermediate",
                teamIntroduction: "송파 여성 축구팀입니다.",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: true, // 매칭 완료만
                hasFormerPlayer: true, // 선출 있음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-01T10:00:00Z",
                updatedAt: "2024-11-01T10:00:00Z",
                team: Team(id: "103", name: "송파 WFC", logo: nil, captain: UserProfile(id: "103", name: "박송파", profileImage: nil))
            ),
            Match(
                id: "104",
                title: "관악 풋살 남성 운동화",
                description: "풋살 실력 중상 구장비 6만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 0, to: today) ?? today),
                location: "서울남부",
                address: "서울시 관악구 신림동 도림천 풋살장",
                latitude: "37.4800",
                longitude: "126.9300",
                fee: 60000,
                maxParticipants: 10,
                currentParticipants: 9,
                matchType: "풋살",
                genderType: "male",
                shoesRequirement: "any",
                ageRangeMin: 25,
                ageRangeMax: 45,
                skillLevelMin: "intermediate",
                skillLevelMax: "advanced",
                teamIntroduction: "운동화 신고 편하게 오세요.",
                mercenaryRecruitmentCount: 1, // 용병 1명 모집만
                isOpponentMatched: false,
                hasFormerPlayer: nil, // 정보 없음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-01T10:00:00Z",
                updatedAt: "2024-11-01T10:00:00Z",
                team: Team(id: "104", name: "관악 FS", logo: nil, captain: UserProfile(id: "104", name: "최관악", profileImage: nil))
            ),
            Match(
                id: "105",
                title: "동작 11vs11 혼성 축구화",
                description: "11 vs 11 실력 초급 구장비 9만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 0, to: today) ?? today),
                location: "서울남부",
                address: "서울시 동작구 사당동 종합체육관",
                latitude: "37.4800",
                longitude: "126.9700",
                fee: 90000,
                maxParticipants: 22,
                currentParticipants: 20,
                matchType: "11 vs 11",
                genderType: "mixed",
                shoesRequirement: "cleats",
                ageRangeMin: 20,
                ageRangeMax: 50,
                skillLevelMin: "beginner",
                skillLevelMax: "beginner",
                teamIntroduction: "혼성으로 즐겁게 찹니다.",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false, // 일반 모집중
                hasFormerPlayer: false, // 선출 없음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-01T10:00:00Z",
                updatedAt: "2024-11-01T10:00:00Z",
                team: Team(id: "105", name: "동작 유나이티드", logo: nil, captain: UserProfile(id: "105", name: "정동작", profileImage: nil))
            ),
            Match(
                id: "106",
                title: "구로 풋살 여성 실내화",
                description: "풋살 실력 상급 구장비 7만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 0, to: today) ?? today),
                location: "서울남부",
                address: "서울시 구로구 구로동 안양천 풋살장",
                latitude: "37.5000",
                longitude: "126.8800",
                fee: 70000,
                maxParticipants: 10,
                currentParticipants: 4,
                matchType: "풋살",
                genderType: "female",
                shoesRequirement: "indoor",
                ageRangeMin: 20,
                ageRangeMax: 30,
                skillLevelMin: "advanced",
                skillLevelMax: "expert",
                teamIntroduction: "여성 풋살 고수분들 모십니다.",
                mercenaryRecruitmentCount: 2,
                isOpponentMatched: true, // 둘 다 표시: "용병 2명 모집중" + "매칭 완료"
                hasFormerPlayer: nil, // 정보 없음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-01T10:00:00Z",
                updatedAt: "2024-11-01T10:00:00Z",
                team: Team(id: "106", name: "구로 퀸즈", logo: nil, captain: UserProfile(id: "106", name: "한구로", profileImage: nil))
            ),
            // 서울북부 지역 - 11 vs 11 (오늘부터 2일 후)
            Match(
                id: "3",
                title: "강북 FC 팀원 모집",
                description: "11 vs 11 실력 하하 구장비 7만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 2, to: today) ?? today),
                location: "서울북부",
                address: "서울시 강북구 수유동 축구장",
                latitude: "37.6396",
                longitude: "127.0254",
                fee: 70000,
                maxParticipants: 22,
                currentParticipants: 15,
                matchType: "11 vs 11",
                genderType: "male",
                shoesRequirement: "cleats",
                ageRangeMin: 18,
                ageRangeMax: 45,
                skillLevelMin: "beginner",
                skillLevelMax: "intermediate",
                teamIntroduction: "강북에서 활동하는 FC입니다. 즐겁게 운동해요!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: true, // 선출 있음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-03T10:00:00Z",
                updatedAt: "2024-11-03T10:00:00Z",
                team: Team(
                    id: "3",
                    name: "강북 FC",
                    logo: nil,
                    captain: UserProfile(id: "3", name: "최강북", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 서울북부 지역 - 풋살 (오늘부터 3일 후)
            Match(
                id: "4",
                title: "마포 풋살 친구들",
                description: "풋살 실력 중하 구장비 6만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 3, to: today) ?? today),
                location: "서울북부",
                address: "서울시 마포구 상암동 월드컵공원 풋살장",
                latitude: "37.5682",
                longitude: "126.8965",
                fee: 60000,
                maxParticipants: 10,
                currentParticipants: 8,
                matchType: "풋살",
                genderType: "mixed",
                shoesRequirement: "indoor",
                ageRangeMin: 20,
                ageRangeMax: 40,
                skillLevelMin: "intermediate",
                skillLevelMax: "intermediate",
                teamIntroduction: "마포에서 활동하는 풋살 팀! 남녀 모두 환영합니다!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: false, // 선출 없음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-04T10:00:00Z",
                updatedAt: "2024-11-04T10:00:00Z",
                team: Team(
                    id: "4",
                    name: "마포 풋살단",
                    logo: nil,
                    captain: UserProfile(id: "4", name: "이마포", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 경기남부 지역 - 11 vs 11 (오늘부터 4일 후)
            Match(
                id: "5",
                title: "수원 삼성 블루윙즈 매치",
                description: "11 vs 11 실력 상상 구장비 15만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 4, to: today) ?? today),
                location: "경기남부",
                address: "경기도 수원시 장안구 천천동 축구장",
                latitude: "37.3014",
                longitude: "127.0100",
                fee: 150000,
                maxParticipants: 22,
                currentParticipants: 20,
                matchType: "11 vs 11",
                genderType: "male",
                shoesRequirement: "cleats",
                ageRangeMin: 25,
                ageRangeMax: 45,
                skillLevelMin: "advanced",
                skillLevelMax: "expert",
                teamIntroduction: "수원에서 활동하는 고급 레벨 팀입니다. 실력자 환영!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: true, // 선출 있음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-05T10:00:00Z",
                updatedAt: "2024-11-05T10:00:00Z",
                team: Team(
                    id: "5",
                    name: "수원 FC",
                    logo: nil,
                    captain: UserProfile(id: "5", name: "정수원", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 경기남부 지역 - 풋살 (오늘부터 5일 후)
            Match(
                id: "6",
                title: "분당 풋살 클럽",
                description: "풋살 실력 중중 구장비 8만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 5, to: today) ?? today),
                location: "경기남부",
                address: "경기도 성남시 분당구 정자동 풋살장",
                latitude: "37.3595",
                longitude: "127.1052",
                fee: 80000,
                maxParticipants: 10,
                currentParticipants: 6,
                matchType: "풋살",
                genderType: "male",
                shoesRequirement: "indoor",
                ageRangeMin: 25,
                ageRangeMax: 40,
                skillLevelMin: "intermediate",
                skillLevelMax: "advanced",
                teamIntroduction: "분당에서 활동하는 풋살 클럽입니다!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: false, // 선출 없음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-06T10:00:00Z",
                updatedAt: "2024-11-06T10:00:00Z",
                team: Team(
                    id: "6",
                    name: "분당 풋살클럽",
                    logo: nil,
                    captain: UserProfile(id: "6", name: "강분당", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 인천/부천 지역 - 11 vs 11 (오늘부터 6일 후)
            Match(
                id: "7",
                title: "인천 유나이티드 매치",
                description: "11 vs 11 실력 중상 구장비 12만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 6, to: today) ?? today),
                location: "인천/부천",
                address: "인천시 연수구 송도동 센트럴파크 축구장",
                latitude: "37.3895",
                longitude: "126.6431",
                fee: 120000,
                maxParticipants: 22,
                currentParticipants: 16,
                matchType: "11 vs 11",
                genderType: "male",
                shoesRequirement: "cleats",
                ageRangeMin: 20,
                ageRangeMax: 40,
                skillLevelMin: "intermediate",
                skillLevelMax: "advanced",
                teamIntroduction: "인천에서 활동하는 팀입니다. 열정있는 분들 환영!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: true, // 선출 있음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-07T10:00:00Z",
                updatedAt: "2024-11-07T10:00:00Z",
                team: Team(
                    id: "7",
                    name: "인천 FC",
                    logo: nil,
                    captain: UserProfile(id: "7", name: "한인천", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 서울남부 지역 - 풋살 (오늘부터 7일 후)
            Match(
                id: "8",
                title: "용산 풋살 리그",
                description: "풋살 실력 하중 구장비 5만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 7, to: today) ?? today),
                location: "서울남부",
                address: "서울시 용산구 한강대로 용산 풋살장",
                latitude: "37.5326",
                longitude: "126.9900",
                fee: 50000,
                maxParticipants: 10,
                currentParticipants: 9,
                matchType: "풋살",
                genderType: "male",
                shoesRequirement: "indoor",
                ageRangeMin: 20,
                ageRangeMax: 35,
                skillLevelMin: "beginner",
                skillLevelMax: "intermediate",
                teamIntroduction: "용산에서 풋살 즐기실 분들 모집합니다!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: false, // 선출 없음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-08T10:00:00Z",
                updatedAt: "2024-11-08T10:00:00Z",
                team: Team(
                    id: "8",
                    name: "용산 풋살단",
                    logo: nil,
                    captain: UserProfile(id: "8", name: "서용산", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 경기남부 지역 - 11 vs 11 (오늘부터 8일 후)
            Match(
                id: "9",
                title: "용인 FC 리그",
                description: "11 vs 11 실력 중하 구장비 9만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 8, to: today) ?? today),
                location: "경기남부",
                address: "경기도 용인시 수지구 풍덕천동 축구장",
                latitude: "37.3222",
                longitude: "127.0975",
                fee: 90000,
                maxParticipants: 22,
                currentParticipants: 14,
                matchType: "11 vs 11",
                genderType: "male",
                shoesRequirement: "cleats",
                ageRangeMin: 22,
                ageRangeMax: 42,
                skillLevelMin: "intermediate",
                skillLevelMax: "intermediate",
                teamIntroduction: "용인에서 활동하는 친목 팀입니다!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: true, // 선출 있음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-09T10:00:00Z",
                updatedAt: "2024-11-09T10:00:00Z",
                team: Team(
                    id: "9",
                    name: "용인 FC",
                    logo: nil,
                    captain: UserProfile(id: "9", name: "오용인", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 서울남부 지역 - 풋살 (오늘부터 9일 후)
            Match(
                id: "10",
                title: "영등포 풋살 매치",
                description: "풋살 실력 하하 구장비 4만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 9, to: today) ?? today),
                location: "서울남부",
                address: "서울시 영등포구 여의도동 한강공원 풋살장",
                latitude: "37.5283",
                longitude: "126.9324",
                fee: 40000,
                maxParticipants: 10,
                currentParticipants: 5,
                matchType: "풋살",
                genderType: "mixed",
                shoesRequirement: "indoor",
                ageRangeMin: 18,
                ageRangeMax: 40,
                skillLevelMin: "beginner",
                skillLevelMax: "beginner",
                teamIntroduction: "영등포에서 가볍게 풋살 즐기실 분들 환영!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: false, // 선출 없음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-10T10:00:00Z",
                updatedAt: "2024-11-10T10:00:00Z",
                team: Team(
                    id: "10",
                    name: "영등포 풋살단",
                    logo: nil,
                    captain: UserProfile(id: "10", name: "윤영등포", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 경기남부 지역 - 11 vs 11 (오늘부터 10일 후)
            Match(
                id: "11",
                title: "안양 FC 대결",
                description: "11 vs 11 실력 중상 구장비 11만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 10, to: today) ?? today),
                location: "경기남부",
                address: "경기도 안양시 만안구 안양천 축구장",
                latitude: "37.3943",
                longitude: "126.9568",
                fee: 110000,
                maxParticipants: 22,
                currentParticipants: 17,
                matchType: "11 vs 11",
                genderType: "male",
                shoesRequirement: "cleats",
                ageRangeMin: 23,
                ageRangeMax: 43,
                skillLevelMin: "intermediate",
                skillLevelMax: "advanced",
                teamIntroduction: "안양에서 활동하는 열정 넘치는 팀!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: true, // 선출 있음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-11T10:00:00Z",
                updatedAt: "2024-11-11T10:00:00Z",
                team: Team(
                    id: "11",
                    name: "안양 FC",
                    logo: nil,
                    captain: UserProfile(id: "11", name: "임안양", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 인천/부천 지역 - 풋살 (오늘부터 11일 후)
            Match(
                id: "12",
                title: "부천 풋살 경기",
                description: "풋살 실력 중하 구장비 7만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 11, to: today) ?? today),
                location: "인천/부천",
                address: "경기도 부천시 원미구 중동 풋살장",
                latitude: "37.5034",
                longitude: "126.7660",
                fee: 70000,
                maxParticipants: 10,
                currentParticipants: 8,
                matchType: "풋살",
                genderType: "male",
                shoesRequirement: "indoor",
                ageRangeMin: 21,
                ageRangeMax: 38,
                skillLevelMin: "intermediate",
                skillLevelMax: "intermediate",
                teamIntroduction: "부천에서 즐기는 풋살 모임입니다!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: false, // 선출 없음
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-12T10:00:00Z",
                updatedAt: "2024-11-12T10:00:00Z",
                team: Team(
                    id: "12",
                    name: "부천 풋살클럽",
                    logo: nil,
                    captain: UserProfile(id: "12", name: "신부천", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 서울북부 지역 - 11 vs 11 (오늘부터 12일 후)
            Match(
                id: "13",
                title: "노원 FC 모집",
                description: "11 vs 11 실력 하상 구장비 8만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 12, to: today) ?? today),
                location: "서울북부",
                address: "서울시 노원구 상계동 축구장",
                latitude: "37.6542",
                longitude: "127.0652",
                fee: 80000,
                maxParticipants: 22,
                currentParticipants: 19,
                matchType: "11 vs 11",
                genderType: "male",
                shoesRequirement: "cleats",
                ageRangeMin: 20,
                ageRangeMax: 40,
                skillLevelMin: "beginner",
                skillLevelMax: "intermediate",
                teamIntroduction: "노원에서 축구를 사랑하는 팀!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: true,
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-13T10:00:00Z",
                updatedAt: "2024-11-13T10:00:00Z",
                team: Team(
                    id: "13",
                    name: "노원 FC",
                    logo: nil,
                    captain: UserProfile(id: "13", name: "김노원", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 경기북부 지역 - 풋살 (오늘부터 13일 후)
            Match(
                id: "14",
                title: "일산 풋살 팀",
                description: "풋살 실력 중중 구장비 6만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 13, to: today) ?? today),
                location: "경기북부",
                address: "경기도 고양시 일산동구 백석동 풋살장",
                latitude: "37.6572",
                longitude: "126.7859",
                fee: 60000,
                maxParticipants: 10,
                currentParticipants: 7,
                matchType: "풋살",
                genderType: "male",
                shoesRequirement: "indoor",
                ageRangeMin: 22,
                ageRangeMax: 38,
                skillLevelMin: "intermediate",
                skillLevelMax: "intermediate",
                teamIntroduction: "일산에서 풋살하실 분들 환영합니다!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: true,
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-14T10:00:00Z",
                updatedAt: "2024-11-14T10:00:00Z",
                team: Team(
                    id: "14",
                    name: "일산 풋살단",
                    logo: nil,
                    captain: UserProfile(id: "14", name: "장일산", profileImage: nil, appleId: nil, isActive: nil)
                )
            ),
            // 서울남부 지역 - 11 vs 11 (오늘부터 14일 후)
            Match(
                id: "15",
                title: "관악 FC 팀매치",
                description: "11 vs 11 실력 하하 구장비 6만원",
                date: dateFormatter.string(from: calendar.date(byAdding: .day, value: 14, to: today) ?? today),
                location: "서울남부",
                address: "서울시 관악구 신림동 관악산 축구장",
                latitude: "37.4784",
                longitude: "126.9516",
                fee: 60000,
                maxParticipants: 22,
                currentParticipants: 12,
                matchType: "11 vs 11",
                genderType: "male",
                shoesRequirement: "cleats",
                ageRangeMin: 19,
                ageRangeMax: 39,
                skillLevelMin: "beginner",
                skillLevelMax: "beginner",
                teamIntroduction: "관악에서 즐겁게 축구해요!",
                mercenaryRecruitmentCount: 0,
                isOpponentMatched: false,
                hasFormerPlayer: true,
                status: "recruiting",
                isActive: true,
                teamId: nil,
                createdAt: "2024-11-15T10:00:00Z",
                updatedAt: "2024-11-15T10:00:00Z",
                team: Team(
                    id: "15",
                    name: "관악 FC",
                    logo: nil,
                    captain: UserProfile(id: "15", name: "안관악", profileImage: nil, appleId: nil, isActive: nil)
                )
            )
        ]
        
        // 원본 데이터 저장
        self.originalMatches = mockMatches

        // ViewModel로 변환
        self.matchingListViewModel = mockMatches.map { convertToViewModel(match: $0) }
    }
    
    // MARK: - Like Functionality
    internal func toggleLike(at indexPath: IndexPath) {
        // 1. 대상 매치 찾기
        let targetViewModel = self.fetchViewModel(indexPath: indexPath)
        let matchId = targetViewModel.id
        
        // 2. API 호출
        APIService.shared.toggleLike(matchId: matchId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let isSuccess):
                if isSuccess {
                    DispatchQueue.main.async {
                        // 3. 로컬 데이터 업데이트 (ViewModel)
                        self.updateLocalLikeStatus(matchId: matchId)
                        
                        // 4. UI 갱신 요청
                        self.presenter?.reloadMatchingList()
                    }
                }
            case .failure(let error):
                print("좋아요 토글 실패: \(error)")
                DispatchQueue.main.async {
                    self.presenter?.showErrorMessage()
                }
            }
        }
    }
    
    private func updateLocalLikeStatus(matchId: String) {
        // 원본 ViewModel 리스트 업데이트
        if let index = self.matchingListViewModel.firstIndex(where: { $0.id == matchId }) {
            let oldModel = self.matchingListViewModel[index]
            let newModel = GameMatchListViewModel(
                id: oldModel.id,
                date: oldModel.date,
                time: oldModel.time,
                address: oldModel.address,
                description: oldModel.description,
                isFavorite: !oldModel.isFavorite, // 토글
                isRecruiting: oldModel.isRecruiting,
                teamName: oldModel.teamName,
                primaryStatus: oldModel.primaryStatus,
                secondaryStatus: oldModel.secondaryStatus,
                hasFormerPlayer: oldModel.hasFormerPlayer
            )
            self.matchingListViewModel[index] = newModel
        }
        
        // 필터링된 ViewModel 리스트 업데이트 (만약 필터 적용 중이라면)
        if isFilterApplied {
            if let index = self.filteredViewModel.firstIndex(where: { $0.id == matchId }) {
                let oldModel = self.filteredViewModel[index]
                let newModel = GameMatchListViewModel(
                    id: oldModel.id,
                    date: oldModel.date,
                    time: oldModel.time,
                    address: oldModel.address,
                    description: oldModel.description,
                    isFavorite: !oldModel.isFavorite, // 토글
                    isRecruiting: oldModel.isRecruiting,
                    teamName: oldModel.teamName,
                    primaryStatus: oldModel.primaryStatus,
                    secondaryStatus: oldModel.secondaryStatus,
                    hasFormerPlayer: oldModel.hasFormerPlayer
                )
                self.filteredViewModel[index] = newModel
            }
        }
    }

    // MARK: - Function
    internal func append(_ dates: [Date], _ date: Date?) {

        if let date = date {
            // 중복 날짜 체크
            let dateString = self.changeDateToString(date)
            let existingDateStrings = self.selectedDate.map { self.changeDateToString($0) }
            if !existingDateStrings.contains(dateString) {
                self.selectedDate.append(date)
            }
        } else {
            self.selectedDate = dates
        }
        
        // 날짜 변경 시 필터링 적용
        self.applyAllFilters()
    }

    internal func delete(_ date: Date) {
        let deselectedDateStr = self.changeDateToString(date)

        let selectedDateArry = self.selectedDate.map { $0.changedSringFromDate }

        guard let indexOfDate = selectedDateArry.firstIndex(of: deselectedDateStr) else { return }
        self.selectedDate.remove(at: indexOfDate)
        
        // 날짜 변경 시 필터링 적용
        self.applyAllFilters()
    }
    
    // MARK: - 필터링 메서드
    
    /// 모든 필터 적용 (날짜, 장소, 경기 종류)
    private func applyAllFilters() {
        // 날짜 필터가 없고 다른 필터도 없으면 필터 초기화
        if selectedDate.isEmpty && currentLocationFilters.isEmpty && currentGameTypeFilters.isEmpty && currentStatusFilters.isEmpty {
            self.isFilterApplied = false
            self.clearFilters()
            return
        }
        
        // 필터가 적용됨을 표시
        self.isFilterApplied = true
        
        // 원본 데이터에서 필터링
        var filtered = originalMatches
        
        // 날짜 필터 적용
        if !selectedDate.isEmpty {
            let calendar = Calendar.current

            let selectedDateComponents = selectedDate.map { date in
                calendar.dateComponents([.year, .month, .day], from: date)
            }

            filtered = filtered.filter { match in
                let matchDate = self.parseDate(from: match.date)
                let matchDateComponents = calendar.dateComponents([.year, .month, .day], from: matchDate)

                return selectedDateComponents.contains { selectedComponents in
                    selectedComponents.year == matchDateComponents.year &&
                    selectedComponents.month == matchDateComponents.month &&
                    selectedComponents.day == matchDateComponents.day
                }
            }
        }
        
        // 장소 필터 적용
        if !currentLocationFilters.isEmpty {
            filtered = filtered.filter { match in
                currentLocationFilters.contains(match.location)
            }
        }
        
        // 경기 종류 필터 적용
        if !currentGameTypeFilters.isEmpty {
            filtered = filtered.filter { match in
                currentGameTypeFilters.contains(match.matchType)
            }
        }
        
        // 매칭 여부 필터 적용
        if !currentStatusFilters.isEmpty {
            filtered = filtered.filter { match in
                // "매칭 완료" -> isOpponentMatched == true
                // "매칭 중" -> isOpponentMatched == false
                
                let isMatched = match.isOpponentMatched ?? false
                
                var matchesFilter = false
                
                if currentStatusFilters.contains("매칭 완료") && isMatched {
                    matchesFilter = true
                }
                
                if currentStatusFilters.contains("매칭 중") && !isMatched {
                    matchesFilter = true
                }
                
                return matchesFilter
            }
        }
        
        // 필터링된 결과 저장
        self.filteredMatches = filtered

        // ViewModel로 변환
        self.filteredViewModel = filtered.map { convertToViewModel(match: $0) }
        
        // UI 업데이트
        self.presenter?.reloadMatchingList()
    }
    
    /// 장소, 경기 종류, 매칭 여부 필터 적용
    /// - Parameters:
    ///   - locationFilters: 선택된 장소 필터 리스트 (예: ["서울북부", "서울남부"])
    ///   - gameTypeFilters: 선택된 경기 종류 필터 리스트 (예: ["11 vs 11", "풋살"])
    ///   - statusFilters: 선택된 매칭 여부 필터 리스트 (예: ["매칭 완료", "매칭 중"])
    internal func applyFilters(locationFilters: [String], gameTypeFilters: [String], statusFilters: [String]) {
        // 필터 상태 저장
        self.currentLocationFilters = locationFilters
        self.currentGameTypeFilters = gameTypeFilters
        self.currentStatusFilters = statusFilters
        
        // 모든 필터 적용 (날짜 포함)
        self.applyAllFilters()
    }
    
    /// 필터 초기화 (날짜 필터는 유지, 장소/경기 종류 필터만 초기화)
    internal func clearFilters() {
        self.currentLocationFilters.removeAll()
        self.currentGameTypeFilters.removeAll()
        self.currentStatusFilters.removeAll()
        
        // 날짜 필터가 있으면 날짜 필터만 적용, 없으면 모든 필터 초기화
        if !selectedDate.isEmpty {
            self.applyAllFilters()
        } else {
            self.isFilterApplied = false
            self.filteredMatches.removeAll()
            self.filteredViewModel.removeAll()
            // UI 업데이트
            self.presenter?.reloadMatchingList()
        }
    }
    
    /// 현재 적용된 필터 확인
    internal func hasActiveFilters() -> Bool {
        return !selectedDate.isEmpty || !currentLocationFilters.isEmpty || !currentGameTypeFilters.isEmpty || !currentStatusFilters.isEmpty
    }
}

extension GameMatchingViewModel {
    private func changeDateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")

        let changedSelectedDate = dateFormatter.string(from: date)

        return changedSelectedDate
    }
}
