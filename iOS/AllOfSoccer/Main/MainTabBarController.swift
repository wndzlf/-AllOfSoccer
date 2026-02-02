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
        // 1. GameMatching ViewController 생성
        let gameMatchingVC = GameMatchingViewController()
        let gameMatchingNav = UINavigationController(rootViewController: gameMatchingVC)
        gameMatchingNav.tabBarItem = UITabBarItem(
            title: "팀 매치",
            image: UIImage(systemName: "person.3"),
            selectedImage: UIImage(systemName: "person.3.fill")
        )

        // 2. MercenaryMatch ViewController 생성
        let mercenaryVC = MercenaryMatchViewController()
        let mercenaryNav = UINavigationController(rootViewController: mercenaryVC)
        mercenaryNav.tabBarItem = UITabBarItem(
            title: "용병 모집",
            image: UIImage(systemName: "person.badge.plus"),
            selectedImage: UIImage(systemName: "person.badge.plus.fill")
        )

        // 3. 기존 viewControllers 가져오기 (MyPage 등)
        var controllers: [UIViewController] = []

        // 탭 추가
        controllers.append(gameMatchingNav)
        controllers.append(mercenaryNav)

        // 기존 스토리보드에서 로드된 다른 뷰컨트롤러들 추가
        if let existingControllers = viewControllers {
            for controller in existingControllers {
                // GameMatching과 MercenaryMatch placeholder가 아닌 것만 추가
                let isGameMatching = controller is UINavigationController && controller.tabBarItem.title == "팀 매치"
                let isMercenary = controller is UINavigationController && controller.tabBarItem.title == "용병 모집"

                if !isGameMatching && !isMercenary {
                    controllers.append(controller)
                }
            }
        }

        viewControllers = controllers
    }
}
