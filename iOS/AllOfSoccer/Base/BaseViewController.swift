//
//  BaseViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2022/01/25.
//

import UIKit

class BaseViewController: UIViewController {

    var indicatorBackgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        return backgroundView
    }()

    var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.white
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension BaseViewController {
    func setIndicator() {
        self.view.addSubview(self.indicatorBackgroundView)
        self.indicatorBackgroundView.addSubview(self.activityIndicator)
        self.indicatorBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.indicatorBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.indicatorBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.indicatorBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.indicatorBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        self.activityIndicator.center = self.view.center
        self.activityIndicator.startAnimating()
    }

    func removeIndicator() {
        self.indicatorBackgroundView.removeFromSuperview()
    }
}
