//
//  BlockingActivityIndicator.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/03.
//

import UIKit
import NVActivityIndicatorView

final class BlockingActivityIndicator: UIView {
    private let activityIndicator: NVActivityIndicatorView

    override init(frame: CGRect) {
        self.activityIndicator = NVActivityIndicatorView(frame: CGRect(origin: .zero,
                                                                       size: NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE),
                                                         type: .lineSpinFadeLoader)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        addSubview(activityIndicator)
        addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
