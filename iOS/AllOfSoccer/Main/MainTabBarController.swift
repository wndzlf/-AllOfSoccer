//
//  MainTabBarController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/04.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        // GameMatching ViewController 생성
        let gameMatchingVC = GameMatchingViewController()
        let gameMatchingNav = UINavigationController(rootViewController: gameMatchingVC)
        gameMatchingNav.tabBarItem = UITabBarItem(
            title: "팀 매치",
            image: UIImage(systemName: "person.3"),
            selectedImage: UIImage(systemName: "person.3.fill")
        )
        
        // 기존 viewControllers 가져오기 (MyPage 등)
        var controllers: [UIViewController] = []
        
        // GameMatching을 첫 번째로 추가
        controllers.append(gameMatchingNav)
        
        // 기존 스토리보드에서 로드된 다른 뷰컨트롤러들 추가
        if let existingControllers = viewControllers {
            for controller in existingControllers {
                // GameMatching placeholder가 아닌 것만 추가
                if !(controller is UINavigationController && controller.tabBarItem.title == "팀 매치") {
                    controllers.append(controller)
                }
            }
        }
        
        viewControllers = controllers
    }
}
