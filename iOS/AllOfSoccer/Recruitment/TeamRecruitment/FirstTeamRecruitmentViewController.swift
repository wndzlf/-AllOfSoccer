//
//  SecondRecruitmentViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/12.
//

import UIKit

class FirstTeamRecruitmentViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let headerView = UIView()
    private let callPreviousInformationButton = UIButton(type: .system)
    
    // Date/Time & Location Section
    private let dateLocationLabel = UILabel()
    private let dateTimeView = RoundView()
    private let calendarImageView = UIImageView()
    private let dateTimeLabel = UILabel()
    private let placeView = RoundView()
    private let placeImageView = UIImageView()
    private let placeLabel = UILabel()
    
    // Game Style Section
    private let gameStyleLabel = UILabel()
    private let gameTypeStackView = UIStackView()
    private let sixMatchButton = IBSelectTableButton()
    private let elevenMatchButton = IBSelectTableButton()
    private let genderStackView = UIStackView()
    private let manMatchButton = IBSelectTableButton()
    private let womanMatchButton = IBSelectTableButton()
    private let mixMatchButton = IBSelectTableButton()
    private let shoesStackView = UIStackView()
    private let futsalShoesButton = IBSelectTableButton()
    private let soccerShoesButton = IBSelectTableButton()
    
    // Fee Section
    private let feeLabel = UILabel()
    private let feeView = RoundView()
    private let feeImageView = UIImageView()
    private let priceTextField = UITextField()
    
    // Bottom Button
    private let nextButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "팀 모집 글쓰기"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonItemTouchUp)
        )
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Header
        headerView.backgroundColor = .systemBackground
        callPreviousInformationButton.setTitle("이전 글 불러오기", for: .normal)
        callPreviousInformationButton.setImage(UIImage(named: "ArchiveBox"), for: .normal)
        callPreviousInformationButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        callPreviousInformationButton.setTitleColor(.black, for: .normal)
        callPreviousInformationButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Date/Location Section
        dateLocationLabel.text = "일시/장소"
        dateLocationLabel.font = UIFont.systemFont(ofSize: 16)
        dateLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateTimeView.backgroundColor = .white
        dateTimeView.layer.cornerRadius = 6
        dateTimeView.translatesAutoresizingMaskIntoConstraints = false
        
        calendarImageView.image = UIImage(named: "Calendar")
        calendarImageView.contentMode = .scaleAspectFit
        calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dateTimeLabel.text = "날짜와 시간을 선택해주세요."
        dateTimeLabel.font = UIFont.systemFont(ofSize: 14)
        dateTimeLabel.textColor = UIColor(red: 0.537, green: 0.556, blue: 0.580, alpha: 1.0)
        dateTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        placeView.backgroundColor = .white
        placeView.layer.cornerRadius = 6
        placeView.translatesAutoresizingMaskIntoConstraints = false
        
        placeImageView.image = UIImage(named: "MapPinLine")
        placeImageView.contentMode = .scaleAspectFit
        placeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        placeLabel.text = "장소를 선택해주세요."
        placeLabel.font = UIFont.systemFont(ofSize: 14)
        placeLabel.textColor = UIColor(red: 0.537, green: 0.556, blue: 0.580, alpha: 1.0)
        placeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Game Style Section
        gameStyleLabel.text = "경기방식"
        gameStyleLabel.font = UIFont.systemFont(ofSize: 16)
        gameStyleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        setupGameTypeButtons()
        setupGenderButtons()
        setupShoesButtons()
        
        // Fee Section
        feeLabel.text = "참가비"
        feeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        feeLabel.textColor = .black
        feeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        feeView.backgroundColor = .systemBackground
        feeView.layer.cornerRadius = 6
        feeView.translatesAutoresizingMaskIntoConstraints = false
        
        feeImageView.image = UIImage(named: "CurrencyCircleDollar")
        feeImageView.contentMode = .scaleAspectFit
        feeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        priceTextField.placeholder = "금액을 입력해주세요."
        priceTextField.font = UIFont.systemFont(ofSize: 14)
        priceTextField.keyboardType = .numberPad
        priceTextField.delegate = self
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Bottom Button
        nextButton.setTitle("다음 (1/2)", for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupGameTypeButtons() {
        gameTypeStackView.axis = .horizontal
        gameTypeStackView.distribution = .fillEqually
        gameTypeStackView.spacing = 10
        gameTypeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        sixMatchButton.setTitle("6 vs 6", for: .normal)
        elevenMatchButton.setTitle("11 vs 11", for: .normal)
        
        [sixMatchButton, elevenMatchButton].forEach { button in
            button.backgroundColor = .white
            button.layer.cornerRadius = 6
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 0.866, green: 0.870, blue: 0.882, alpha: 1.0).cgColor
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(UIColor(red: 0.615, green: 0.623, blue: 0.627, alpha: 1.0), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupGenderButtons() {
        genderStackView.axis = .horizontal
        genderStackView.distribution = .fillEqually
        genderStackView.spacing = 10
        genderStackView.translatesAutoresizingMaskIntoConstraints = false
        
        manMatchButton.setTitle("남성 매치", for: .normal)
        womanMatchButton.setTitle("여성 매치", for: .normal)
        mixMatchButton.setTitle("혼성 매치", for: .normal)
        
        [manMatchButton, womanMatchButton, mixMatchButton].forEach { button in
            button.backgroundColor = .white
            button.layer.cornerRadius = 6
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 0.866, green: 0.870, blue: 0.882, alpha: 1.0).cgColor
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(UIColor(red: 0.615, green: 0.623, blue: 0.627, alpha: 1.0), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupShoesButtons() {
        shoesStackView.axis = .horizontal
        shoesStackView.distribution = .fillEqually
        shoesStackView.spacing = 10
        shoesStackView.translatesAutoresizingMaskIntoConstraints = false
        
        futsalShoesButton.setTitle("풋살화 필수", for: .normal)
        soccerShoesButton.setTitle("축구화 필수", for: .normal)
        
        [futsalShoesButton, soccerShoesButton].forEach { button in
            button.backgroundColor = .white
            button.layer.cornerRadius = 6
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor(red: 0.866, green: 0.870, blue: 0.882, alpha: 1.0).cgColor
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(UIColor(red: 0.615, green: 0.623, blue: 0.627, alpha: 1.0), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add subviews to contentView
        contentView.addSubview(headerView)
        headerView.addSubview(callPreviousInformationButton)
        
        contentView.addSubview(dateLocationLabel)
        contentView.addSubview(dateTimeView)
        dateTimeView.addSubview(calendarImageView)
        dateTimeView.addSubview(dateTimeLabel)
        contentView.addSubview(placeView)
        placeView.addSubview(placeImageView)
        placeView.addSubview(placeLabel)
        
        contentView.addSubview(gameStyleLabel)
        contentView.addSubview(gameTypeStackView)
        gameTypeStackView.addArrangedSubview(sixMatchButton)
        gameTypeStackView.addArrangedSubview(elevenMatchButton)
        contentView.addSubview(genderStackView)
        genderStackView.addArrangedSubview(manMatchButton)
        genderStackView.addArrangedSubview(womanMatchButton)
        genderStackView.addArrangedSubview(mixMatchButton)
        contentView.addSubview(shoesStackView)
        shoesStackView.addArrangedSubview(futsalShoesButton)
        shoesStackView.addArrangedSubview(soccerShoesButton)
        
        contentView.addSubview(feeLabel)
        contentView.addSubview(feeView)
        feeView.addSubview(feeImageView)
        feeView.addSubview(priceTextField)
        
        view.addSubview(nextButton)
        
        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Header constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 52),
            
            callPreviousInformationButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            callPreviousInformationButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        // Date/Location constraints
        NSLayoutConstraint.activate([
            dateLocationLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            dateLocationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            dateTimeView.topAnchor.constraint(equalTo: dateLocationLabel.bottomAnchor, constant: 12),
            dateTimeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateTimeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            dateTimeView.heightAnchor.constraint(equalToConstant: 50),
            
            calendarImageView.leadingAnchor.constraint(equalTo: dateTimeView.leadingAnchor, constant: 26),
            calendarImageView.centerYAnchor.constraint(equalTo: dateTimeView.centerYAnchor),
            calendarImageView.widthAnchor.constraint(equalToConstant: 18),
            calendarImageView.heightAnchor.constraint(equalToConstant: 18),
            
            dateTimeLabel.leadingAnchor.constraint(equalTo: calendarImageView.trailingAnchor, constant: 10),
            dateTimeLabel.centerYAnchor.constraint(equalTo: dateTimeView.centerYAnchor),
            
            placeView.topAnchor.constraint(equalTo: dateTimeView.bottomAnchor, constant: 10),
            placeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            placeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            placeView.heightAnchor.constraint(equalToConstant: 50),
            
            placeImageView.leadingAnchor.constraint(equalTo: placeView.leadingAnchor, constant: 26),
            placeImageView.centerYAnchor.constraint(equalTo: placeView.centerYAnchor),
            placeImageView.widthAnchor.constraint(equalToConstant: 18),
            placeImageView.heightAnchor.constraint(equalToConstant: 18),
            
            placeLabel.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 10),
            placeLabel.centerYAnchor.constraint(equalTo: placeView.centerYAnchor)
        ])
        
        // Game Style constraints
        NSLayoutConstraint.activate([
            gameStyleLabel.topAnchor.constraint(equalTo: placeView.bottomAnchor, constant: 20),
            gameStyleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            gameTypeStackView.topAnchor.constraint(equalTo: gameStyleLabel.bottomAnchor, constant: 12),
            gameTypeStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            gameTypeStackView.heightAnchor.constraint(equalToConstant: 36),
            
            genderStackView.topAnchor.constraint(equalTo: gameTypeStackView.bottomAnchor, constant: 10),
            genderStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            genderStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            genderStackView.heightAnchor.constraint(equalToConstant: 36),
            
            shoesStackView.topAnchor.constraint(equalTo: genderStackView.bottomAnchor, constant: 10),
            shoesStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            shoesStackView.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Fee constraints
        NSLayoutConstraint.activate([
            feeLabel.topAnchor.constraint(equalTo: shoesStackView.bottomAnchor, constant: 20),
            feeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            feeView.topAnchor.constraint(equalTo: feeLabel.bottomAnchor, constant: 12),
            feeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            feeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            feeView.heightAnchor.constraint(equalToConstant: 50),
            
            feeImageView.leadingAnchor.constraint(equalTo: feeView.leadingAnchor, constant: 16),
            feeImageView.centerYAnchor.constraint(equalTo: feeView.centerYAnchor),
            feeImageView.widthAnchor.constraint(equalToConstant: 16),
            feeImageView.heightAnchor.constraint(equalToConstant: 16),
            
            priceTextField.leadingAnchor.constraint(equalTo: feeImageView.trailingAnchor, constant: 10),
            priceTextField.trailingAnchor.constraint(equalTo: feeView.trailingAnchor, constant: -16),
            priceTextField.centerYAnchor.constraint(equalTo: feeView.centerYAnchor)
        ])
        
        // Bottom button constraints
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 62)
        ])
        
        // Content view bottom constraint
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: feeView.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupActions() {
        [sixMatchButton, elevenMatchButton, manMatchButton, womanMatchButton, mixMatchButton, futsalShoesButton, soccerShoesButton].forEach { button in
            button.addTarget(self, action: #selector(matchButtonTouchUp), for: .touchUpInside)
        }
        
        callPreviousInformationButton.addTarget(self, action: #selector(callPreviousInformationButtonTouchUp), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTouchUp), for: .touchUpInside)
        
        // Add tap gesture for date/time and place views
        let dateTimeTap = UITapGestureRecognizer(target: self, action: #selector(calendarButtonTouchUp))
        dateTimeView.addGestureRecognizer(dateTimeTap)
        
        let placeTap = UITapGestureRecognizer(target: self, action: #selector(placeButtonTouchUp))
        placeView.addGestureRecognizer(placeTap)
    }

    // MARK: - Actions
    @objc private func backButtonItemTouchUp(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @objc private func calendarButtonTouchUp(_ sender: UITapGestureRecognizer) {
        let recruitmentCalendarView = RecruitmentCalendarView()
        recruitmentCalendarView.delegate = self
        subviewConstraints(view: recruitmentCalendarView)
    }

    @objc private func placeButtonTouchUp(_ sender: UITapGestureRecognizer) {
        let searchPlaceView = SearchPlaceView()
        searchPlaceView.delegate = self
        subviewConstraints(view: searchPlaceView)
    }

    @objc private func callPreviousInformationButtonTouchUp(_ sender: UIButton) {
        let callPreviousInformationView = CallPreviusMatchingInformationView()
        callPreviousInformationView.delegate = self
        subviewConstraints(view: callPreviousInformationView)
    }
    
    @objc private func nextButtonTouchUp(_ sender: UIButton) {
        // 날짜와 시간이 선택되었는지 확인
        guard dateTimeLabel.text != "날짜와 시간을 선택해주세요." else {
            // 알림 표시
            let alert = UIAlertController(title: "알림", message: "날짜와 시간을 선택해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let secondViewController = SecondTeamRecruitmentViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
    }

    @objc func matchButtonTouchUp(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    private func subviewConstraints(view: UIView) {
        guard let navigationController = self.navigationController else { return }
        navigationController.view.addsubviews(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: navigationController.view.topAnchor, constant: 0),
            view.leadingAnchor.constraint(equalTo: navigationController.view.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: navigationController.view.trailingAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: navigationController.view.bottomAnchor, constant: 0)
        ])
    }
}

// MARK: - Extensions
extension FirstTeamRecruitmentViewController: RecruitmentCalendarViewDelegate {
    func cancelButtonDidSelected(_ view: RecruitmentCalendarView) {
        view.removeFromSuperview()
    }

    func okButtonDidSelected(_ view: RecruitmentCalendarView, selectedDate: String) {
        // 선택된 날짜와 시간을 표시
        dateTimeLabel.text = selectedDate
        dateTimeLabel.textColor = .black // 선택된 경우 검은색으로 변경
        view.removeFromSuperview()
    }
}

extension FirstTeamRecruitmentViewController: SearchPlaceViewDelegate {
    func cancelButtonDidSelected(_ view: SearchPlaceView) {
        view.removeFromSuperview()
    }

    func okButtonDidSelected(_ view: SearchPlaceView) {
        view.removeFromSuperview()
    }
}

extension FirstTeamRecruitmentViewController: CallPreviusMatchingInformationViewDelegate {
    func cancelButtonDidSelected(_ view: CallPreviusMatchingInformationView) {
        view.removeFromSuperview()
    }
    
    func OKButtonDidSelected(_ view: CallPreviusMatchingInformationView) {
        view.removeFromSuperview()
    }
}

extension FirstTeamRecruitmentViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.keyboardWillAppear()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension FirstTeamRecruitmentViewController {
    func dismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTouchOutside))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboardTouchOutside() {
        view.endEditing(true)
    }
}

extension FirstTeamRecruitmentViewController {
    private func keyboardWillAppear() {
        // 키보드 처리 로직
    }

    private func keyboardWillDisapper() {
        // 키보드 처리 로직
    }
}
