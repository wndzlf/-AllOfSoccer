//
//  TeamMatchViewModel.swift
//  AllOfSoccer
//
//  Created by iOS Developer on 2026/02/06
//

import Foundation

class TeamMatchViewModel {
    // MARK: - Properties
    var matches: [Match] = [] {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("TeamMatchViewModelMatchesChanged"), object: nil)
        }
    }

    var isLoading: Bool = false {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("TeamMatchViewModelLoadingChanged"), object: nil)
        }
    }

    var errorMessage: String? = nil {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("TeamMatchViewModelErrorChanged"), object: nil)
        }
    }

    var currentPage: Int = 1
    var hasMorePages: Bool = true

    // Filter properties
    var selectedLocation: String? = nil
    var selectedDate: String? = nil
    var selectedMatchType: String? = nil
    var selectedGenderType: String? = nil
    var selectedShoesRequirement: String? = nil
    var selectedAgeMin: Int? = nil
    var selectedAgeMax: Int? = nil
    var selectedSkillLevel: String? = nil
    var selectedFeeMin: Int? = nil
    var selectedFeeMax: Int? = nil
    var selectedStatus: String? = nil

    private let apiService = APIService.shared
    private let pageLimit = 20

    // MARK: - Initialization
    init() {
        fetchMatches(page: 1)
    }

    // MARK: - Methods
    func fetchMatches(page: Int = 1) {
        isLoading = true
        errorMessage = nil

        apiService.getMatches(
            page: page,
            limit: pageLimit,
            location: selectedLocation,
            date: selectedDate,
            matchType: selectedMatchType,
            genderType: selectedGenderType,
            shoesRequirement: selectedShoesRequirement,
            ageMin: selectedAgeMin,
            ageMax: selectedAgeMax,
            skillLevel: selectedSkillLevel,
            feeMin: selectedFeeMin,
            feeMax: selectedFeeMax,
            status: selectedStatus
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if page == 1 {
                        self?.matches = response.data
                    } else {
                        self?.matches.append(contentsOf: response.data)
                    }
                    self?.currentPage = page
                    self?.hasMorePages = page < response.pagination.totalPages
                    self?.isLoading = false

                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                    print("매칭 목록 조회 실패: \(error)")
                }
            }
        }
    }

    func loadNextPage() {
        guard !isLoading && hasMorePages else { return }
        fetchMatches(page: currentPage + 1)
    }

    func refreshMatches() {
        currentPage = 1
        fetchMatches(page: 1)
    }

    func applyFilter(
        location: String? = nil,
        date: String? = nil,
        matchType: String? = nil,
        genderType: String? = nil,
        shoesRequirement: String? = nil,
        ageMin: Int? = nil,
        ageMax: Int? = nil,
        skillLevel: String? = nil,
        feeMin: Int? = nil,
        feeMax: Int? = nil,
        status: String? = nil
    ) {
        selectedLocation = location
        selectedDate = date
        selectedMatchType = matchType
        selectedGenderType = genderType
        selectedShoesRequirement = shoesRequirement
        selectedAgeMin = ageMin
        selectedAgeMax = ageMax
        selectedSkillLevel = skillLevel
        selectedFeeMin = feeMin
        selectedFeeMax = feeMax
        selectedStatus = status

        refreshMatches()
    }

    func clearFilters() {
        selectedLocation = nil
        selectedDate = nil
        selectedMatchType = nil
        selectedGenderType = nil
        selectedShoesRequirement = nil
        selectedAgeMin = nil
        selectedAgeMax = nil
        selectedSkillLevel = nil
        selectedFeeMin = nil
        selectedFeeMax = nil
        selectedStatus = nil

        refreshMatches()
    }

    func hasActiveFilters() -> Bool {
        return selectedLocation != nil ||
               selectedDate != nil ||
               selectedMatchType != nil ||
               selectedGenderType != nil ||
               selectedShoesRequirement != nil ||
               selectedAgeMin != nil ||
               selectedAgeMax != nil ||
               selectedSkillLevel != nil ||
               selectedFeeMin != nil ||
               selectedFeeMax != nil ||
               selectedStatus != nil
    }
}
