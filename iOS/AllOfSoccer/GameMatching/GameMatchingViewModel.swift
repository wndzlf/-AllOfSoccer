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

    var tagTitle: String {
        switch self {
        case .location: return "장소"
        case .game: return "경기 종류"
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

    internal var count: Int {
        // 필터링된 데이터가 있으면 필터링된 데이터 개수 반환
        return filteredViewModel.isEmpty ? matchingListViewModel.count : filteredViewModel.count
    }

    internal func fetchViewModel(indexPath: IndexPath) -> GameMatchListViewModel {
        // 필터링된 데이터가 있으면 필터링된 데이터 반환
        return filteredViewModel.isEmpty ? matchingListViewModel[indexPath.row] : filteredViewModel[indexPath.row]
    }
    
    // 원본 Match 데이터 반환
    internal func getOriginalMatch(at indexPath: IndexPath) -> Match? {
        // 필터링된 데이터가 있으면 필터링된 데이터에서 가져오기
        let matches = filteredMatches.isEmpty ? originalMatches : filteredMatches
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

    private func fetchMatchingList() async throws {
        // 서버에서 매칭 데이터 가져오기
        APIService.shared.getMatches(
            page: 1,
            limit: 20,
            status: "recruiting"
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let matchResponse):
                    // 원본 데이터 저장
                    self?.originalMatches = matchResponse.data
                    
                    // 서버 데이터를 ViewModel로 변환
                    self?.matchingListViewModel = matchResponse.data.map { match in
                        // 날짜 형식 변환 (서버: "2024-01-01" -> UI: "01.01.월")
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let date = dateFormatter.date(from: match.date) ?? Date()
                        
                        let displayFormatter = DateFormatter()
                        displayFormatter.dateFormat = "MM.dd.E"
                        displayFormatter.locale = Locale(identifier: "ko_KR")
                        let displayDate = displayFormatter.string(from: date)
                        
                        // 시간은 기본값으로 설정 (서버에서 시간 정보가 별도로 없음)
                        let time = "20:00"
                        
                        // 설명 생성
                        let description = "\(match.matchType) 실력 하하 구장비 \(match.fee)원"
                        
                        return GameMatchListViewModel(
                            date: displayDate,
                            time: time,
                            address: match.location,
                            description: description,
                            isFavorite: true,
                            isRecruiting: match.status == "recruiting",
                            teamName: match.team?.name ?? "알 수 없음"
                        )
                    }
                    self?.presenter?.reloadMatchingList()
                    
                case .failure(let error):
                    print("매칭 데이터 가져오기 실패: \(error)")
                    // 에러 시 목 데이터 사용
                    self?.setupMockData()
                    self?.presenter?.reloadMatchingList()
                    self?.presenter?.showErrorMessage()
                }
            }
        }
    }
    
    // 목 데이터 설정
    private func setupMockData() {
        // 목 Match 데이터 생성 - 더 다양한 데이터
        let mockMatches = [
            // 서울남부 지역 - 11 vs 11
            Match(
                id: 1,
                title: "FC 강남 모집",
                description: "11 vs 11 실력 중상 구장비 10만원",
                date: "2024-11-20",
                location: "서울남부",
                address: "서울시 강남구 역삼동 테헤란로 축구장",
                latitude: 37.4979,
                longitude: 127.0276,
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
                teamIntroduction: "안녕하세요 FC 강남입니다. 강남 지역에서 활동하는 팀으로 실력 있는 선수들을 모집합니다!",
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-01T10:00:00Z",
                updatedAt: "2024-11-01T10:00:00Z",
                team: Team(
                    id: 1,
                    name: "FC 강남",
                    logo: nil,
                    captain: User(id: 1, name: "김강남", profileImage: nil)
                )
            ),
            // 서울남부 지역 - 풋살
            Match(
                id: 2,
                title: "송파 풋살 모집",
                description: "풋살 실력 하상 구장비 5만원",
                date: "2024-11-21",
                location: "서울남부",
                address: "서울시 송파구 석촌호수 풋살장",
                latitude: 37.5109,
                longitude: 127.1012,
                fee: 50000,
                maxParticipants: 10,
                currentParticipants: 7,
                matchType: "풋살",
                genderType: "male",
                shoesRequirement: "indoor",
                ageRangeMin: 20,
                ageRangeMax: 35,
                skillLevelMin: "beginner",
                skillLevelMax: "intermediate",
                teamIntroduction: "송파에서 즐기는 풋살! 편하게 오세요~",
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-02T10:00:00Z",
                updatedAt: "2024-11-02T10:00:00Z",
                team: Team(
                    id: 2,
                    name: "송파 FC",
                    logo: nil,
                    captain: User(id: 2, name: "박송파", profileImage: nil)
                )
            ),
            // 서울북부 지역 - 11 vs 11
            Match(
                id: 3,
                title: "강북 FC 팀원 모집",
                description: "11 vs 11 실력 하하 구장비 7만원",
                date: "2024-11-22",
                location: "서울북부",
                address: "서울시 강북구 수유동 축구장",
                latitude: 37.6396,
                longitude: 127.0254,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-03T10:00:00Z",
                updatedAt: "2024-11-03T10:00:00Z",
                team: Team(
                    id: 3,
                    name: "강북 FC",
                    logo: nil,
                    captain: User(id: 3, name: "최강북", profileImage: nil)
                )
            ),
            // 서울북부 지역 - 풋살
            Match(
                id: 4,
                title: "마포 풋살 친구들",
                description: "풋살 실력 중하 구장비 6만원",
                date: "2024-11-23",
                location: "서울북부",
                address: "서울시 마포구 상암동 월드컵공원 풋살장",
                latitude: 37.5682,
                longitude: 126.8965,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-04T10:00:00Z",
                updatedAt: "2024-11-04T10:00:00Z",
                team: Team(
                    id: 4,
                    name: "마포 풋살단",
                    logo: nil,
                    captain: User(id: 4, name: "이마포", profileImage: nil)
                )
            ),
            // 경기남부 지역 - 11 vs 11
            Match(
                id: 5,
                title: "수원 삼성 블루윙즈 매치",
                description: "11 vs 11 실력 상상 구장비 15만원",
                date: "2024-11-24",
                location: "경기남부",
                address: "경기도 수원시 장안구 천천동 축구장",
                latitude: 37.3014,
                longitude: 127.0100,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-05T10:00:00Z",
                updatedAt: "2024-11-05T10:00:00Z",
                team: Team(
                    id: 5,
                    name: "수원 FC",
                    logo: nil,
                    captain: User(id: 5, name: "정수원", profileImage: nil)
                )
            ),
            // 경기남부 지역 - 풋살
            Match(
                id: 6,
                title: "분당 풋살 클럽",
                description: "풋살 실력 중중 구장비 8만원",
                date: "2024-11-25",
                location: "경기남부",
                address: "경기도 성남시 분당구 정자동 풋살장",
                latitude: 37.3595,
                longitude: 127.1052,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-06T10:00:00Z",
                updatedAt: "2024-11-06T10:00:00Z",
                team: Team(
                    id: 6,
                    name: "분당 풋살클럽",
                    logo: nil,
                    captain: User(id: 6, name: "강분당", profileImage: nil)
                )
            ),
            // 인천/부천 지역 - 11 vs 11
            Match(
                id: 7,
                title: "인천 유나이티드 매치",
                description: "11 vs 11 실력 중상 구장비 12만원",
                date: "2024-11-26",
                location: "인천/부천",
                address: "인천시 연수구 송도동 센트럴파크 축구장",
                latitude: 37.3895,
                longitude: 126.6431,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-07T10:00:00Z",
                updatedAt: "2024-11-07T10:00:00Z",
                team: Team(
                    id: 7,
                    name: "인천 FC",
                    logo: nil,
                    captain: User(id: 7, name: "한인천", profileImage: nil)
                )
            ),
            // 서울남부 지역 - 풋살
            Match(
                id: 8,
                title: "용산 풋살 리그",
                description: "풋살 실력 하중 구장비 5만원",
                date: "2024-11-27",
                location: "서울남부",
                address: "서울시 용산구 한강대로 용산 풋살장",
                latitude: 37.5326,
                longitude: 126.9900,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-08T10:00:00Z",
                updatedAt: "2024-11-08T10:00:00Z",
                team: Team(
                    id: 8,
                    name: "용산 풋살단",
                    logo: nil,
                    captain: User(id: 8, name: "서용산", profileImage: nil)
                )
            ),
            // 경기남부 지역 - 11 vs 11
            Match(
                id: 9,
                title: "용인 FC 리그",
                description: "11 vs 11 실력 중하 구장비 9만원",
                date: "2024-11-28",
                location: "경기남부",
                address: "경기도 용인시 수지구 풍덕천동 축구장",
                latitude: 37.3222,
                longitude: 127.0975,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-09T10:00:00Z",
                updatedAt: "2024-11-09T10:00:00Z",
                team: Team(
                    id: 9,
                    name: "용인 FC",
                    logo: nil,
                    captain: User(id: 9, name: "오용인", profileImage: nil)
                )
            ),
            // 서울남부 지역 - 풋살
            Match(
                id: 10,
                title: "영등포 풋살 매치",
                description: "풋살 실력 하하 구장비 4만원",
                date: "2024-11-29",
                location: "서울남부",
                address: "서울시 영등포구 여의도동 한강공원 풋살장",
                latitude: 37.5283,
                longitude: 126.9324,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-10T10:00:00Z",
                updatedAt: "2024-11-10T10:00:00Z",
                team: Team(
                    id: 10,
                    name: "영등포 풋살단",
                    logo: nil,
                    captain: User(id: 10, name: "윤영등포", profileImage: nil)
                )
            ),
            // 경기남부 지역 - 11 vs 11
            Match(
                id: 11,
                title: "안양 FC 대결",
                description: "11 vs 11 실력 중상 구장비 11만원",
                date: "2024-11-30",
                location: "경기남부",
                address: "경기도 안양시 만안구 안양천 축구장",
                latitude: 37.3943,
                longitude: 126.9568,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-11T10:00:00Z",
                updatedAt: "2024-11-11T10:00:00Z",
                team: Team(
                    id: 11,
                    name: "안양 FC",
                    logo: nil,
                    captain: User(id: 11, name: "임안양", profileImage: nil)
                )
            ),
            // 인천/부천 지역 - 풋살
            Match(
                id: 12,
                title: "부천 풋살 경기",
                description: "풋살 실력 중하 구장비 7만원",
                date: "2024-12-01",
                location: "인천/부천",
                address: "경기도 부천시 원미구 중동 풋살장",
                latitude: 37.5034,
                longitude: 126.7660,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-12T10:00:00Z",
                updatedAt: "2024-11-12T10:00:00Z",
                team: Team(
                    id: 12,
                    name: "부천 풋살클럽",
                    logo: nil,
                    captain: User(id: 12, name: "신부천", profileImage: nil)
                )
            ),
            // 서울북부 지역 - 11 vs 11
            Match(
                id: 13,
                title: "노원 FC 모집",
                description: "11 vs 11 실력 하상 구장비 8만원",
                date: "2024-12-02",
                location: "서울북부",
                address: "서울시 노원구 상계동 축구장",
                latitude: 37.6542,
                longitude: 127.0652,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-13T10:00:00Z",
                updatedAt: "2024-11-13T10:00:00Z",
                team: Team(
                    id: 13,
                    name: "노원 FC",
                    logo: nil,
                    captain: User(id: 13, name: "김노원", profileImage: nil)
                )
            ),
            // 경기북부 지역 - 풋살
            Match(
                id: 14,
                title: "일산 풋살 팀",
                description: "풋살 실력 중중 구장비 6만원",
                date: "2024-12-03",
                location: "경기북부",
                address: "경기도 고양시 일산동구 백석동 풋살장",
                latitude: 37.6572,
                longitude: 126.7859,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-14T10:00:00Z",
                updatedAt: "2024-11-14T10:00:00Z",
                team: Team(
                    id: 14,
                    name: "일산 풋살단",
                    logo: nil,
                    captain: User(id: 14, name: "장일산", profileImage: nil)
                )
            ),
            // 서울남부 지역 - 11 vs 11
            Match(
                id: 15,
                title: "관악 FC 팀매치",
                description: "11 vs 11 실력 하하 구장비 6만원",
                date: "2024-12-04",
                location: "서울남부",
                address: "서울시 관악구 신림동 관악산 축구장",
                latitude: 37.4784,
                longitude: 126.9516,
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
                status: "recruiting",
                isActive: true,
                createdAt: "2024-11-15T10:00:00Z",
                updatedAt: "2024-11-15T10:00:00Z",
                team: Team(
                    id: 15,
                    name: "관악 FC",
                    logo: nil,
                    captain: User(id: 15, name: "안관악", profileImage: nil)
                )
            )
        ]
        
        // 원본 데이터 저장
        self.originalMatches = mockMatches
        
        // ViewModel로 변환
        self.matchingListViewModel = mockMatches.map { match in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: match.date) ?? Date()
            
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MM.dd.E"
            displayFormatter.locale = Locale(identifier: "ko_KR")
            let displayDate = displayFormatter.string(from: date)
            
            let time = "20:00"
            let description = "\(match.matchType) 실력 하하 구장비 \(match.fee)원"
            
            return GameMatchListViewModel(
                date: displayDate,
                time: time,
                address: match.location,
                description: description,
                isFavorite: true,
                isRecruiting: match.status == "recruiting",
                teamName: match.team?.name ?? "알 수 없음"
            )
        }
    }

    // MARK: - Function
    internal func append(_ dates: [Date], _ date: Date?) {

        if let date = date {
            self.selectedDate.append(date)
        } else {
            self.selectedDate = dates
        }
    }

    internal func delete(_ date: Date) {
        let deselectedDateStr = self.changeDateToString(date)

        let selectedDateArry = self.selectedDate.map { $0.changedSringFromDate }

        guard let indexOfDate = selectedDateArry.firstIndex(of: deselectedDateStr) else { return }
        self.selectedDate.remove(at: indexOfDate)
    }
    
    // MARK: - 필터링 메서드
    
    /// 장소와 경기 종류 필터 적용
    /// - Parameters:
    ///   - locationFilters: 선택된 장소 필터 리스트 (예: ["서울-강남/서초", "서울-강동/송파"])
    ///   - gameTypeFilters: 선택된 경기 종류 필터 리스트 (예: ["11 vs 11", "풋살"])
    internal func applyFilters(locationFilters: [String], gameTypeFilters: [String]) {
        // 필터 상태 저장
        self.currentLocationFilters = locationFilters
        self.currentGameTypeFilters = gameTypeFilters
        
        // 필터가 모두 비어있으면 필터 초기화
        if locationFilters.isEmpty && gameTypeFilters.isEmpty {
            self.clearFilters()
            return
        }
        
        // 원본 데이터에서 필터링
        var filtered = originalMatches
        
        // 장소 필터 적용
        if !locationFilters.isEmpty {
            filtered = filtered.filter { match in
                locationFilters.contains(match.location)
            }
        }
        
        // 경기 종류 필터 적용
        if !gameTypeFilters.isEmpty {
            filtered = filtered.filter { match in
                gameTypeFilters.contains(match.matchType)
            }
        }
        
        // 필터링된 결과 저장
        self.filteredMatches = filtered
        
        // ViewModel로 변환
        self.filteredViewModel = filtered.map { match in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: match.date) ?? Date()
            
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MM.dd.E"
            displayFormatter.locale = Locale(identifier: "ko_KR")
            let displayDate = displayFormatter.string(from: date)
            
            let time = "20:00"
            let description = "\(match.matchType) 실력 하하 구장비 \(match.fee)원"
            
            return GameMatchListViewModel(
                date: displayDate,
                time: time,
                address: match.location,
                description: description,
                isFavorite: true,
                isRecruiting: match.status == "recruiting",
                teamName: match.team?.name ?? "알 수 없음"
            )
        }
        
        // UI 업데이트
        self.presenter?.reloadMatchingList()
    }
    
    /// 필터 초기화
    internal func clearFilters() {
        self.currentLocationFilters.removeAll()
        self.currentGameTypeFilters.removeAll()
        self.filteredMatches.removeAll()
        self.filteredViewModel.removeAll()
        
        // UI 업데이트
        self.presenter?.reloadMatchingList()
    }
    
    /// 현재 적용된 필터 확인
    internal func hasActiveFilters() -> Bool {
        return !currentLocationFilters.isEmpty || !currentGameTypeFilters.isEmpty
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
