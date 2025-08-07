//
//  RoundView.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/03.
//

import UIKit

@IBDesignable
final class RoundView: UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }

    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    @IBInspectable var borderColor: UIColor = #colorLiteral(red: 0.8196078431, green: 0.8274509804, blue: 0.8549019608, alpha: 1) {
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

    func update() {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
    
}
