//
//  SecondRecruitmentViewController.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/08/12.
//

import UIKit

// MARK: - GameOption Model
struct GameOption {
    let title: String
    let type: GameOptionType
}

enum GameOptionType {
    case gameType
    case gender
    case shoes
    case selection
}

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
    private let placeTextField = UITextField()
    
    // Game Style Section
    private let gameStyleLabel = UILabel()
    private let gameOptionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // Data for CollectionView
    private var gameOptions = [
        GameOption(title: "6 vs 6", type: .gameType),
        GameOption(title: "11 vs 11", type: .gameType),
        GameOption(title: "남성 매치", type: .gender),
        GameOption(title: "여성 매치", type: .gender),
        GameOption(title: "혼성 매치", type: .gender),
        GameOption(title: "풋살화 필수", type: .shoes),
        GameOption(title: "축구화 필수", type: .shoes),
        GameOption(title: "선출 포함", type: .selection)
    ]
    
    private var selectedOptions: Set<Int> = []
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewHeight()
    }
    
    private func updateCollectionViewHeight() {
        // CollectionView의 contentSize에 맞게 높이 업데이트
        let contentHeight = gameOptionsCollectionView.collectionViewLayout.collectionViewContentSize.height
        if contentHeight > 0 {
            collectionViewHeightConstraint?.constant = contentHeight
            view.layoutIfNeeded()
        }
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
        
        placeTextField.placeholder = "장소를 입력해주세요."
        placeTextField.font = UIFont.systemFont(ofSize: 14)
        placeTextField.textColor = .black
        placeTextField.delegate = self
        placeTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Game Style Section
        gameStyleLabel.text = "경기방식"
        gameStyleLabel.font = UIFont.systemFont(ofSize: 16)
        gameStyleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        setupCollectionViews()
        
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
    
    private func setupCollectionViews() {
        // Register cells
        gameOptionsCollectionView.register(GameOptionCell.self, forCellWithReuseIdentifier: "GameOptionCell")
        
        // Set delegates
        gameOptionsCollectionView.delegate = self
        gameOptionsCollectionView.dataSource = self
        
        // Configure layout
        configureCollectionViewLayout(gameOptionsCollectionView)
    }
    
    private func configureCollectionViewLayout(_ collectionView: UICollectionView) {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 12
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
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
        placeView.addSubview(placeTextField)
        
        contentView.addSubview(gameStyleLabel)
        contentView.addSubview(gameOptionsCollectionView)
        
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
            
            placeTextField.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 10),
            placeTextField.trailingAnchor.constraint(equalTo: placeView.trailingAnchor, constant: -16),
            placeTextField.centerYAnchor.constraint(equalTo: placeView.centerYAnchor)
        ])
        
        // Game Style constraints
        NSLayoutConstraint.activate([
            gameStyleLabel.topAnchor.constraint(equalTo: placeView.bottomAnchor, constant: 20),
            gameStyleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            gameOptionsCollectionView.topAnchor.constraint(equalTo: gameStyleLabel.bottomAnchor, constant: 12),
            gameOptionsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            gameOptionsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        // 높이 제약 조건 추가 및 저장
        collectionViewHeightConstraint = gameOptionsCollectionView.heightAnchor.constraint(equalToConstant: 100)
        collectionViewHeightConstraint?.isActive = true
        
        // Fee constraints
        NSLayoutConstraint.activate([
            feeLabel.topAnchor.constraint(equalTo: gameOptionsCollectionView.bottomAnchor, constant: 20),
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
        callPreviousInformationButton.addTarget(self, action: #selector(callPreviousInformationButtonTouchUp), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTouchUp), for: .touchUpInside)
        
        // Add tap gesture for date/time view
        let dateTimeTap = UITapGestureRecognizer(target: self, action: #selector(calendarButtonTouchUp))
        dateTimeView.addGestureRecognizer(dateTimeTap)
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
        
        // 장소가 입력되었는지 확인
        guard let placeText = placeTextField.text, !placeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // 알림 표시
            let alert = UIAlertController(title: "알림", message: "장소를 입력해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let secondViewController = SecondTeamRecruitmentViewController()
        navigationController?.pushViewController(secondViewController, animated: true)
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



extension FirstTeamRecruitmentViewController: CallPreviusMatchingInformationViewDelegate {
    func cancelButtonDidSelected(_ view: CallPreviusMatchingInformationView) {
        view.removeFromSuperview()
    }
    
    func OKButtonDidSelected(_ view: CallPreviusMatchingInformationView) {
        view.removeFromSuperview()
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension FirstTeamRecruitmentViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameOptionCell", for: indexPath) as! GameOptionCell
        
        let option = gameOptions[indexPath.item]
        let isSelected = selectedOptions.contains(indexPath.item)
        
        cell.configure(with: option.title, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let option = gameOptions[indexPath.item]
        
        // 같은 타입의 다른 옵션들 선택 해제
        for (index, gameOption) in gameOptions.enumerated() {
            if gameOption.type == option.type && index != indexPath.item {
                selectedOptions.remove(index)
            }
        }
        
        // 현재 옵션 토글
        if selectedOptions.contains(indexPath.item) {
            selectedOptions.remove(indexPath.item)
        } else {
            selectedOptions.insert(indexPath.item)
        }
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = 40
        let cellPadding: CGFloat = 32 // Cell 내부 좌우 여백을 더 늘려서 여유롭게
        
        let option = gameOptions[indexPath.item]
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let textSize = option.title.size(withAttributes: [.font: font])
        let width = textSize.width + (cellPadding * 2)
        
        return CGSize(width: width, height: height)
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
