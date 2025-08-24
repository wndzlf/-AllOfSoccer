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
            // 수도권
            "서울-강남/서초", "서울-강동/송파", "서울-강북/도봉", "서울-강서/양천", 
            "서울-관악/동작", "서울-광진/성동", "서울-노원/중랑", "서울-마포/서대문",
            "서울-영등포/구로", "서울-용산/중구", "서울-은평/강북",
            
            // 경기도
            "경기-수원/화성", "경기-성남/분당", "경기-용인", "경기-안산/시흥",
            "경기-부천/광명", "경기-안양/의왕", "경기-평택/오산", "경기-하남/구리",
            "경기-남양주/가평", "경기-양평/여주", "경기-이천/안성", "경기-포천/동두천",
            "경기-고양/파주", "경기-김포/강화",
            
            // 인천
            "인천-미추홀/연수", "인천-남동/부평", "인천-계양/서구", "인천-강화/옹진",
            
            // 강원도
            "강원-춘천/화천", "강원-원주/횡성", "강원-강릉/동해", "강원-삼척/태백",
            "강원-속초/고성", "강원-양양/인제", "강원-평창/정선", "강원-영월/정선",
            
            // 충청도
            "충북-청주/보은", "충북-충주/제천", "충북-진천/음성", "충북-옥천/영동",
            "충남-천안/아산", "충남-공주/부여", "충남-보령/서천", "충남-논산/계룡",
            "충남-당진/홍성", "충남-서산/태안",
            
            // 전라도
            "전북-전주/완주", "전북-군산/익산", "전북-정읍/남원", "전북-김제/부안",
            "전북-진안/무주", "전북-장수/임실", "전북-순창/고창",
            "전남-목포/무안", "전남-여수/순천", "전남-나주/화순", "전남-광양/구례",
            "전남-담양/곡성", "전남-장성/영광", "전남-진도/완도", "전남-해남/강진",
            "전남-고흥/보성", "전남-신안",
            
            // 경상도
            "경북-포항/영천", "경북-경주/울진", "경북-안동/예천", "경북-구미/김천",
            "경북-상주/문경", "경북-영주/봉화", "경북-의성/청송", "경북-영양/영덕",
            "경북-청도/성주", "경북-고령/합천", "경북-칠곡/군위",
            "경남-창원/마산", "경남-진주/사천", "경남-통영/거제", "경남-김해/양산",
            "경남-밀양/의령", "경남-함안/창녕", "경남-거창/합천", "경남-산청/하동",
            "경남-남해/고성",
            
            // 제주도
            "제주-제주시", "제주-서귀포시",
            
            // 기타
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

    internal var count: Int {
        self.matchingListViewModel.count
    }

    internal func fetchViewModel(indexPath: IndexPath) -> GameMatchListViewModel {
        self.matchingListViewModel[indexPath.row]
    }
    
    // 원본 Match 데이터 반환
    internal func getOriginalMatch(at indexPath: IndexPath) -> Match? {
        guard indexPath.row < originalMatches.count else { return nil }
        return originalMatches[indexPath.row]
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
        // 목 Match 데이터 생성
        let mockMatches = [
            Match(
                id: 1,
                title: "FC 캘란 모집",
                description: "11대 11 실력 하하 구장비 7천원",
                date: "2024-09-14",
                location: "양원역 구장",
                address: "서울시 강북구 양원역 근처",
                latitude: 37.5665,
                longitude: 126.9780,
                fee: 7000,
                maxParticipants: 22,
                currentParticipants: 15,
                matchType: "11v11",
                genderType: "male",
                shoesRequirement: "cleats",
                ageRangeMin: 25,
                ageRangeMax: 35,
                skillLevelMin: "beginner",
                skillLevelMax: "intermediate",
                teamIntroduction: "안녕하세요 FC 캘란입니다. 잘부탁드립니다. 실력 최하하 매너 최상상 팁입니다!!!!",
                status: "recruiting",
                isActive: true,
                createdAt: "2024-09-01T10:00:00Z",
                updatedAt: "2024-09-01T10:00:00Z",
                team: Team(
                    id: 1,
                    name: "FC 캘란",
                    logo: nil,
                    captain: User(id: 1, name: "김캡틴", profileImage: nil)
                )
            ),
            Match(
                id: 2,
                title: "FC 바르셀로나 모집",
                description: "11대 11 실력 하하 구장비 5만원",
                date: "2024-09-14",
                location: "태릉중학교",
                address: "서울시 노원구 태릉로 456 태릉중학교 운동장",
                latitude: 37.5665,
                longitude: 126.9780,
                fee: 50000,
                maxParticipants: 22,
                currentParticipants: 18,
                matchType: "11v11",
                genderType: "male",
                shoesRequirement: "cleats",
                ageRangeMin: 30,
                ageRangeMax: 50,
                skillLevelMin: "advanced",
                skillLevelMax: "expert",
                teamIntroduction: "FC 바르셀로나입니다. 저희는 실력 있는 분들과 함께하는 경기를 선호합니다. 이번 경기는 특별히 구장비가 5만원으로 비싸지만, 최고급 인조잔디 구장에서 진행됩니다. 경기 후에는 근처 맛집에서 회식도 예정되어 있습니다. 실력이 상급이신 분들만 연락주시고, 경기 중 매너도 중요하게 생각합니다. 특히 이번 경기는 다른 팀과의 친선경기이므로 더욱 신중하게 선수들을 모집하고 있습니다. 많은 관심 부탁드립니다!",
                status: "recruiting",
                isActive: true,
                createdAt: "2024-09-01T10:00:00Z",
                updatedAt: "2024-09-01T10:00:00Z",
                team: Team(
                    id: 2,
                    name: "FC 바르셀로나",
                    logo: nil,
                    captain: User(id: 2, name: "박캡틴", profileImage: nil)
                )
            ),
            Match(
                id: 3,
                title: "FC 뮌헨 모집",
                description: "11대 11 실력 하하 구장비 7천원",
                date: "2024-09-14",
                location: "용산 아이파크몰",
                address: "서울시 용산구 한강대로23길 55",
                latitude: 37.5665,
                longitude: 126.9780,
                fee: 7000,
                maxParticipants: 22,
                currentParticipants: 12,
                matchType: "11v11",
                genderType: "male",
                shoesRequirement: "cleats",
                ageRangeMin: 20,
                ageRangeMax: 40,
                skillLevelMin: "beginner",
                skillLevelMax: "advanced",
                teamIntroduction: "안녕하세요 FC 뮌헨입니다. 즐겁게 축구하실 분들을 모집합니다!",
                status: "recruiting",
                isActive: true,
                createdAt: "2024-09-01T10:00:00Z",
                updatedAt: "2024-09-01T10:00:00Z",
                team: Team(
                    id: 3,
                    name: "FC 뮌헨",
                    logo: nil,
                    captain: User(id: 3, name: "이캡틴", profileImage: nil)
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
