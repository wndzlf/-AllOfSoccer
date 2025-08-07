//
//  SeletableButton.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/10/01.
//

import UIKit

class SeletableButton: UIButton {

    var normalImage: UIImage? {
        didSet {
            update()
        }
    }

    var selectImage: UIImage? {
        didSet {
            update()
        }
    }

    var normalBackgroundColor: UIColor = #colorLiteral(red: 0.9647058824, green: 0.968627451, blue: 0.9803921569, alpha: 1) {
        didSet {
            update()
        }
    }

    var selectBackgroundColor: UIColor = #colorLiteral(red: 0.9254901961, green: 0.3725490196, blue: 0.3725490196, alpha: 1) {
        didSet {
            update()
        }
    }

    var normalTitleColor: UIColor = #colorLiteral(red: 0.6156862745, green: 0.6235294118, blue: 0.6274509804, alpha: 1)  {
        didSet {
            update()
        }
    }

    var selectTitleColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            update()
        }
    }

    var normalBorderColor: UIColor = #colorLiteral(red: 0.8666666667, green: 0.8705882353, blue: 0.8823529412, alpha: 1) {
        didSet {
            update()
        }
    }

    var selectBorderColor: UIColor = #colorLiteral(red: 0.9254901961, green: 0.3725490196, blue: 0.3725490196, alpha: 1) {
        didSet {
            update()
        }
    }

    var normalTintColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            update()
        }
    }

    var selectTintColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) {
        didSet {
            update()
        }
    }

    var cornerRadius: CGFloat = 6.0 {
        didSet {
            update()
        }
    }

    var borderWidth: CGFloat = 1 {
        didSet {
            update()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        update()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        update()
    }

    override var isSelected: Bool {
        didSet {
            update()
        }
    }

    private func update() {
        layer.cornerRadius = cornerRadius
        setTitleColor(normalTitleColor, for: .normal)
        setTitleColor(selectTitleColor, for: .selected)
        backgroundColor = isSelected ? selectBackgroundColor : normalBackgroundColor
        layer.borderColor = isSelected ? selectBorderColor.cgColor : normalBorderColor.cgColor
        tintColor = isSelected ? selectTintColor : normalTintColor
        layer.borderWidth = borderWidth
        setImage(normalImage, for: .normal)
        setImage(selectImage, for: .selected)
    }
}
