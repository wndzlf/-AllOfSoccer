//
//  GameMatchingViewModelTests.swift
//  AllOfSoccerTests
//
//  Created by Antigravity on 2025/11/22.
//

import XCTest
@testable import AllOfSoccer

class GameMatchingViewModelTests: XCTestCase {
    
    var viewModel: GameMatchingViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = GameMatchingViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testToggleLike() {
        // Given
        // Wait for async fetch to complete (Mock data setup)
        let expectation = XCTestExpectation(description: "Fetch Data")
        
        // Use a delay to allow init's Task to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        guard viewModel.count > 0 else {
            XCTFail("ViewModel should have data")
            return
        }
        
        let indexPath = IndexPath(row: 0, section: 0)
        let initialViewModel = viewModel.fetchViewModel(indexPath: indexPath)
        let initialLikeStatus = initialViewModel.isFavorite
        
        // When
        viewModel.toggleLike(at: indexPath)
        
        // Wait for API simulation and UI update
        let toggleExpectation = XCTestExpectation(description: "Toggle Like")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            toggleExpectation.fulfill()
        }
        
        wait(for: [toggleExpectation], timeout: 2.0)
        
        // Then
        let updatedViewModel = viewModel.fetchViewModel(indexPath: indexPath)
        XCTAssertNotEqual(initialLikeStatus, updatedViewModel.isFavorite, "Like status should be toggled")
    }
}
