//
//  CalendarCollectionViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/15.
//

import UIKit


enum NumberOfDays: Int {
    case saturday = 0
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case webseday = 4
    case thursday = 5
    case friday = 6
}

class HorizontalCalendarCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    @IBOutlet internal weak var dayLabel: UILabel!
    @IBOutlet internal weak var dateLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    
    private var currentCellData: HorizontalCalendarModel?
    private var gradientLayer: CAGradientLayer?

    override func awakeFromNib() {
        // 셀의 배경을 투명하게 설정
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.clipsToBounds = false
        
        self.stackView.layer.cornerRadius = 15
        self.stackView.layer.borderWidth = 1.5
        self.stackView.backgroundColor = UIColor.white
        self.stackView.clipsToBounds = false

        self.stackView.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 245/255, alpha: 1.0).cgColor
    }

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.isSelected {
                    // 선택 시: 초록 배경, 진한 초록 테두리, 흰색 텍스트
                    self.stackView.backgroundColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1.0)
                    self.stackView.layer.borderColor = UIColor(red: 48/255, green: 219/255, blue: 91/255, alpha: 1.0).cgColor
                    self.stackView.layer.borderWidth = 2.0
                    self.dayLabel.textColor = UIColor.white
                    self.dateLabel.textColor = UIColor.white
                } else {
                    // 비선택 시: 흰 배경, 연한 회색 테두리, 요일별 텍스트
                    self.stackView.backgroundColor = UIColor.white
                    self.stackView.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 245/255, alpha: 1.0).cgColor
                    self.stackView.layer.borderWidth = 1.5
                    if let cellData = self.currentCellData {
                        self.updateTextColors(with: cellData)
                    } else {
                        self.updateTextColors()
                    }
                }
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 선택된 상태에서만 그라디언트 프레임을 갱신
        if let gradient = gradientLayer, isSelected {
            gradient.frame = self.stackView.bounds
        }
    }

    func configure(_ cellData: HorizontalCalendarModel) {
        self.currentCellData = cellData
        self.dayLabel.text = cellData.dayText
        self.dateLabel.text = cellData.weeksDayText
        self.updateTextColors(with: cellData)
    }
    
    private func updateTextColors(with cellData: HorizontalCalendarModel? = nil) {
        if let cellData = cellData {
            // 모델의 정보를 사용
            if cellData.isToday {
                self.dayLabel.textColor = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
                self.dateLabel.textColor = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
            } else {
                self.dayLabel.textColor = cellData.dayTextColor
                self.dateLabel.textColor = cellData.dateTextColor
            }
        } else {
            // 기존 로직 (fallback)
            if let dayText = self.dayLabel.text, let dateText = self.dateLabel.text {
                let isToday = self.isToday()
                
                if isToday {
                    self.dayLabel.textColor = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
                    self.dateLabel.textColor = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
                } else {
                    // 요일별 색상
                    switch dateText {
                    case "일":
                        self.dayLabel.textColor = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
                        self.dateLabel.textColor = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1.0)
                    case "토":
                        self.dayLabel.textColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                        self.dateLabel.textColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
                    default:
                        self.dayLabel.textColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
                        self.dateLabel.textColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
                    }
                }
            }
        }
    }
    
    private func isToday() -> Bool {
        // 현재 날짜와 비교하여 오늘인지 확인
        let calendar = Calendar.current
        let today = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        // 셀의 날짜 정보를 추출 (간단한 구현)
        if let dayText = self.dayLabel.text, let day = Int(dayText.replacingOccurrences(of: "M/", with: "")) {
            return day == todayComponents.day
        }
        return false
    }
}
