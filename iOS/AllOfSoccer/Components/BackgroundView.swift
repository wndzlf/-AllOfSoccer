//
//  BackGroundView.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/10/01.
//

import UIKit

class BackgroundView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        setBacgroundView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setBacgroundView()
    }

    func setBacgroundView() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    }
}
