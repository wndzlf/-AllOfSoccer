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
        let gameMatchingVC = GameMatchingViewController()
        let gameMatchingNav = UINavigationController(rootViewController: gameMatchingVC)
        gameMatchingNav.tabBarItem = UITabBarItem(
            title: "팀 매치",
            image: UIImage(systemName: "person.3"),
            selectedImage: UIImage(systemName: "person.3.fill")
        )

        let mercenaryVC = MercenaryMatchViewController()
        let mercenaryNav = UINavigationController(rootViewController: mercenaryVC)
        mercenaryNav.tabBarItem = UITabBarItem(
            title: "용병 모집",
            image: UIImage(systemName: "person.badge.plus"),
            selectedImage: UIImage(systemName: "person.badge.plus.fill")
        )

        let myPageVC = MyPageViewController()
        let myPageNav = UINavigationController(rootViewController: myPageVC)
        myPageNav.tabBarItem = UITabBarItem(
            title: "마이페이지",
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: UIImage(systemName: "person.crop.circle.fill")
        )

        viewControllers = [gameMatchingNav, mercenaryNav, myPageNav]
    }
}
