//
//  RoundStackView.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/25.
//

import UIKit

@IBDesignable
final class RoundStackView: UIStackView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }

    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
}
