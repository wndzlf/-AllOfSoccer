//
//  SliderLabels.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/09/30.
//

import UIKit

enum SliderType {
    case age
    case skill
}

class SliderLabels: UIView {

    private var firstLabel: UILabel?
    private var secondLabel: UILabel?
    private var thirdLabel: UILabel?
    private var fourthLabel: UILabel?
    private var fifthLabel: UILabel?
    private var sixthLabel: UILabel?
    private var sevenLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setLabels(_ sliderType: SliderType) {

    }
}
