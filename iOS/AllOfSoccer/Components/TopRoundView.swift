//
//  TopRoundView.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/03.
//

import UIKit

@IBDesignable
final class TopRoundView: UIView {
    @IBInspectable var topCornerRadius: CGFloat = 30.0 {
        didSet {
            update()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        update()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        update()
    }

    override func prepareForInterfaceBuilder() {
        update()
    }

    func update() {
        layer.cornerRadius = topCornerRadius
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
}
