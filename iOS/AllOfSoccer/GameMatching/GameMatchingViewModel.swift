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
        self.matchingListViewModel = [GameMatchListViewModel.mockData,
                                      GameMatchListViewModel.mockData1,
                                      GameMatchListViewModel.mockData2]
    }

    // MARK: - Properties
    internal private(set) var selectedDate: [Date] = []

    internal var count: Int {
        self.matchingListViewModel.count
    }

    internal func fetchViewModel(indexPath: IndexPath) -> GameMatchListViewModel {
        self.matchingListViewModel[indexPath.row]
    }

    private var matchingListViewModel: [GameMatchListViewModel] = []

    internal var formalStrSelectedDate: [String] {
        let strSelectedDate = self.selectedDate.map { self.changeDateToString($0) }
        return strSelectedDate
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
