//
//  RoundButton.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/03.
//

import UIKit

@IBDesignable
final class RoundButton: UIButton {
    @IBInspectable var normalBackgroundColor: UIColor = #colorLiteral(red: 0.1333333333, green: 0.1333333333, blue: 0.1333333333, alpha: 1) {
        didSet {
            update()
        }
    }

    @IBInspectable var normalTitleColor: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) {
        didSet {
            update()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 10.0 {
        didSet {
            update()
        }
    }

    @IBInspectable var borderColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) {
        didSet {
            update()
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            update()
        }
    }

    @IBInspectable var widthInset: CGFloat = 0



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

    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width + widthInset, height: super.intrinsicContentSize.height)
    }

    func update() {
        layer.cornerRadius = cornerRadius
        backgroundColor = normalBackgroundColor
        setTitleColor(normalTitleColor, for: .normal)
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
    }
}
