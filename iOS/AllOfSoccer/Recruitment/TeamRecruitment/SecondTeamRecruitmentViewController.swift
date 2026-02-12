import UIKit
import RangeSeekSlider

class SecondTeamRecruitmentViewController: UIViewController {

    // FirstTeamRecruitmentViewController에서 전달받은 데이터
    var matchCreationData: MatchCreationData?

    private var tableViewModel: [Comment] = []
    private var isDirectInputMode = false
    private let directInputTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 6
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(red: 0.866, green: 0.870, blue: 0.882, alpha: 1.0).cgColor
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.isScrollEnabled = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isHidden = true
        return textView
    }()
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let headerView = UIView()
    private let callTeamInformationButton = UIButton(type: .system)
    
    // Team Name Section
    private let teamNameLabel = UILabel()
    private let teamNameView = RoundView()
    private let teamNameImageView = UIImageView()
    private let teamNameTextField = UITextField()
    
    // Age Range Section
    private let ageRangeLabel = UILabel()
    private let ageRangeSlider = RangeSeekSlider()
    private var ageSliderLabels: [UILabel] = []
    
    // Skill Section
    private let skillLabel = UILabel()
    private let skillSlider = OneThumbSlider()
    private var skillSliderLabels: [UILabel] = []
    
    // Introduction Section
    private let introductionLabel = UILabel()
    private let introductionTableView = IntrinsicTableView()
    private let addIntroductionButton = RoundButton()
    
    // Contact Section
    private let contactLabel = UILabel()
    private let contactView = RoundView()
    private let contactImageView = UIImageView()
    private let contactTextField = UITextField()
    private let informationCheckButton = IBSelectTableButton()
    private let informationAgreementLabel = UILabel()
    
    // Bottom Button
    private let registerButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUI()
        setupConstraints()
        setupActions()
        setupSliders()
        setupIntroductionTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setAgeLabelsLayout()
        setSkillLabelsLayout()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        title = "팀 모집 글쓰기"
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Header
        headerView.backgroundColor = .systemBackground
        callTeamInformationButton.setTitle("팀 소개 불러오기", for: .normal)
        callTeamInformationButton.setImage(UIImage(named: "ArchiveBox"), for: .normal)
        callTeamInformationButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        callTeamInformationButton.setTitleColor(.black, for: .normal)
        callTeamInformationButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Team Name Section
        teamNameLabel.text = "팀이름"
        teamNameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        teamNameLabel.textColor = .black
        teamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        teamNameView.backgroundColor = .systemBackground
        teamNameView.layer.cornerRadius = 6
        teamNameView.translatesAutoresizingMaskIntoConstraints = false
        
        teamNameImageView.image = UIImage(named: "UserCircle")
        teamNameImageView.contentMode = .scaleAspectFit
        teamNameImageView.translatesAutoresizingMaskIntoConstraints = false
        
        teamNameTextField.placeholder = "팀이름을 적어주세요."
        teamNameTextField.font = UIFont.systemFont(ofSize: 14)
        teamNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Age Range Section
        ageRangeLabel.text = "나이대"
        ageRangeLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        ageRangeLabel.textColor = .black
        ageRangeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        ageRangeSlider.translatesAutoresizingMaskIntoConstraints = false
        ageRangeSlider.minValue = 10
        ageRangeSlider.maxValue = 70
        ageRangeSlider.selectedMinValue = 30
        ageRangeSlider.selectedMaxValue = 50
        ageRangeSlider.step = 10
        ageRangeSlider.enableStep = true
        ageRangeSlider.handleDiameter = 18
        ageRangeSlider.lineHeight = 6
        ageRangeSlider.colorBetweenHandles = UIColor(red: 0.937, green: 0.729, blue: 0.729, alpha: 1.0)
        ageRangeSlider.handleColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)
        ageRangeSlider.handleBorderColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)
        ageRangeSlider.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        ageRangeSlider.tintColor = UIColor(red: 0.925, green: 0.925, blue: 0.925, alpha: 1.0)
        // 슬라이더 thumb 위치 조정을 위한 설정 추가
        ageRangeSlider.minDistance = 0
        ageRangeSlider.maxDistance = 60
        ageRangeSlider.disableRange = false // 두 thumb 모두 사용
        ageRangeSlider.enableStep = true
        ageRangeSlider.hideLabels = true // 기본 라벨 숨기기
        
        // Create age labels
        let ageValues = ["10", "20", "30", "40", "50", "60", "70"]
        ageSliderLabels = ageValues.map { value in
            let label = UILabel()
            label.text = value
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(red: 0.439, green: 0.439, blue: 0.439, alpha: 0.847)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }
        
        // Skill Section
        skillLabel.text = "실력"
        skillLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        skillLabel.textColor = .black
        skillLabel.translatesAutoresizingMaskIntoConstraints = false
        
        skillSlider.translatesAutoresizingMaskIntoConstraints = false
        skillSlider.minimumValue = 0
        skillSlider.maximumValue = 6
        skillSlider.value = 3 // 중간값으로 초기 설정
        skillSlider.minimumTrackTintColor = UIColor(red: 0.925, green: 0.925, blue: 0.925, alpha: 1.0)
        skillSlider.maximumTrackTintColor = UIColor(red: 0.925, green: 0.925, blue: 0.925, alpha: 1.0)
        skillSlider.setThumbImage(UIImage(systemName: "circle.fill")?.withTintColor(UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0), renderingMode: .alwaysOriginal), for: .normal)
        
        // 슬라이더 값을 정수로만 설정되도록
        skillSlider.addTarget(self, action: #selector(skillSliderValueChanged), for: .valueChanged)
        
        // Create skill labels
        let skillValues = ["최하", "하", "중하", "중", "중상", "상", "최상"]
        skillSliderLabels = skillValues.map { value in
            let label = UILabel()
            label.text = value
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(red: 0.439, green: 0.439, blue: 0.439, alpha: 0.847)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }
        
        // Introduction Section
        introductionLabel.text = "소개글"
        introductionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        introductionLabel.textColor = .black
        introductionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        introductionTableView.backgroundColor = .clear
        introductionTableView.translatesAutoresizingMaskIntoConstraints = false
        introductionTableView.layer.cornerRadius = 8
        introductionTableView.layer.borderWidth = 1
        introductionTableView.layer.borderColor = UIColor(red: 0.866, green: 0.870, blue: 0.882, alpha: 1.0).cgColor
        introductionTableView.backgroundColor = .white
        
        addIntroductionButton.setTitle("글 추가", for: .normal)
        addIntroductionButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addIntroductionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        addIntroductionButton.setTitleColor(.black, for: .normal)
        addIntroductionButton.backgroundColor = .white
        addIntroductionButton.layer.cornerRadius = 6
        addIntroductionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Contact Section
        contactLabel.text = "연락처"
        contactLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        contactLabel.textColor = .black
        contactLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contactView.backgroundColor = .systemBackground
        contactView.layer.cornerRadius = 6
        contactView.translatesAutoresizingMaskIntoConstraints = false
        
        contactImageView.image = UIImage(named: "Phone")
        contactImageView.contentMode = .scaleAspectFit
        contactImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contactTextField.placeholder = "대표 연락처를 입력해주세요."
        contactTextField.font = UIFont.systemFont(ofSize: 14)
        contactTextField.translatesAutoresizingMaskIntoConstraints = false
        
        informationCheckButton.translatesAutoresizingMaskIntoConstraints = false
        informationCheckButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        informationCheckButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        informationCheckButton.normalTintColor = UIColor(red: 0.803, green: 0.803, blue: 0.803, alpha: 1.0)
        informationCheckButton.selectTintColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)
        informationCheckButton.normalBackgroundColor = .clear
        informationCheckButton.selectBackgroundColor = .clear
        informationCheckButton.normalBorderColor = .clear
        informationCheckButton.selectBorderColor = .clear
        informationCheckButton.borderWidth = 0
        
        informationAgreementLabel.text = "연락처 공개 안내에 동의합니다."
        informationAgreementLabel.font = UIFont.systemFont(ofSize: 14)
        informationAgreementLabel.textColor = .darkGray
        informationAgreementLabel.isUserInteractionEnabled = true
        informationAgreementLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Bottom Button
        registerButton.setTitle("등록하기", for: .normal)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.backgroundColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        // TextView placeholder 설정
        directInputTextView.text = "소개글을 직접 입력해주세요"
        directInputTextView.textColor = UIColor.lightGray
        directInputTextView.delegate = self
    }
    
    private func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add subviews to contentView
        contentView.addSubview(headerView)
        headerView.addSubview(callTeamInformationButton)
        
        contentView.addSubview(teamNameLabel)
        contentView.addSubview(teamNameView)
        teamNameView.addSubview(teamNameImageView)
        teamNameView.addSubview(teamNameTextField)
        
        contentView.addSubview(ageRangeLabel)
        contentView.addSubview(ageRangeSlider)
        ageSliderLabels.forEach { contentView.addSubview($0) }
        
        contentView.addSubview(skillLabel)
        contentView.addSubview(skillSlider)
        skillSliderLabels.forEach { contentView.addSubview($0) }
        
        contentView.addSubview(introductionLabel)
        contentView.addSubview(introductionTableView)
        contentView.addSubview(addIntroductionButton)
        contentView.addSubview(directInputTextView)
        
        contentView.addSubview(contactLabel)
        contentView.addSubview(contactView)
        contactView.addSubview(contactImageView)
        contactView.addSubview(contactTextField)
        contentView.addSubview(informationCheckButton)
        contentView.addSubview(informationAgreementLabel)
        
        view.addSubview(registerButton)
        
        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: registerButton.topAnchor, constant: -29),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Header constraints
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 52),
            
            callTeamInformationButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            callTeamInformationButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        // Team Name constraints
        NSLayoutConstraint.activate([
            teamNameLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            teamNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            teamNameView.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor, constant: 12),
            teamNameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            teamNameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            teamNameView.heightAnchor.constraint(equalToConstant: 50),
            
            teamNameImageView.leadingAnchor.constraint(equalTo: teamNameView.leadingAnchor, constant: 16),
            teamNameImageView.centerYAnchor.constraint(equalTo: teamNameView.centerYAnchor),
            teamNameImageView.widthAnchor.constraint(equalToConstant: 18),
            teamNameImageView.heightAnchor.constraint(equalToConstant: 18),
            
            teamNameTextField.leadingAnchor.constraint(equalTo: teamNameImageView.trailingAnchor, constant: 10),
            teamNameTextField.trailingAnchor.constraint(equalTo: teamNameView.trailingAnchor, constant: -16),
            teamNameTextField.centerYAnchor.constraint(equalTo: teamNameView.centerYAnchor)
        ])
        
        // Age Range constraints
        NSLayoutConstraint.activate([
            ageRangeLabel.topAnchor.constraint(equalTo: teamNameView.bottomAnchor, constant: 32),
            ageRangeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            ageRangeSlider.topAnchor.constraint(equalTo: ageRangeLabel.bottomAnchor, constant: 24),
            ageRangeSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ageRangeSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ageRangeSlider.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        // Skill constraints
        NSLayoutConstraint.activate([
            skillLabel.topAnchor.constraint(equalTo: ageRangeSlider.bottomAnchor, constant: 48),
            skillLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            skillSlider.topAnchor.constraint(equalTo: skillLabel.bottomAnchor, constant: 24),
            skillSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            skillSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            skillSlider.heightAnchor.constraint(equalToConstant: 31)
        ])
        
        // Introduction constraints
        NSLayoutConstraint.activate([
            introductionLabel.topAnchor.constraint(equalTo: skillSlider.bottomAnchor, constant: 40),
            introductionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            introductionTableView.topAnchor.constraint(equalTo: introductionLabel.bottomAnchor, constant: 16),
            introductionTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            introductionTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            addIntroductionButton.topAnchor.constraint(equalTo: introductionTableView.bottomAnchor, constant: 16),
            addIntroductionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addIntroductionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addIntroductionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Contact constraints
        NSLayoutConstraint.activate([
            contactLabel.topAnchor.constraint(equalTo: addIntroductionButton.bottomAnchor, constant: 20),
            contactLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            contactView.topAnchor.constraint(equalTo: contactLabel.bottomAnchor, constant: 12),
            contactView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contactView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contactView.heightAnchor.constraint(equalToConstant: 50),
            
            contactImageView.leadingAnchor.constraint(equalTo: contactView.leadingAnchor, constant: 16),
            contactImageView.centerYAnchor.constraint(equalTo: contactView.centerYAnchor),
            contactImageView.widthAnchor.constraint(equalToConstant: 18),
            contactImageView.heightAnchor.constraint(equalToConstant: 18),
            
            contactTextField.leadingAnchor.constraint(equalTo: contactImageView.trailingAnchor, constant: 10),
            contactTextField.trailingAnchor.constraint(equalTo: contactView.trailingAnchor, constant: -16),
            contactTextField.centerYAnchor.constraint(equalTo: contactView.centerYAnchor),
            
            informationCheckButton.topAnchor.constraint(equalTo: contactView.bottomAnchor, constant: 30),
            informationCheckButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            informationCheckButton.widthAnchor.constraint(equalToConstant: 22),
            informationCheckButton.heightAnchor.constraint(equalToConstant: 22),
            
            informationAgreementLabel.centerYAnchor.constraint(equalTo: informationCheckButton.centerYAnchor),
            informationAgreementLabel.leadingAnchor.constraint(equalTo: informationCheckButton.trailingAnchor, constant: 8),
            informationAgreementLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
        ])
        
        // Bottom button constraints
        NSLayoutConstraint.activate([
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            registerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 62)
        ])
        
        // Content view bottom constraint
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: informationCheckButton.bottomAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            directInputTextView.topAnchor.constraint(equalTo: introductionLabel.bottomAnchor, constant: 16),
            directInputTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            directInputTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            directInputTextView.heightAnchor.constraint(equalToConstant: 128)
        ])
    }
    
    private func setupActions() {
        addIntroductionButton.addTarget(self, action: #selector(addIntroductionButtonTouchUp), for: .touchUpInside)
        informationCheckButton.addTarget(self, action: #selector(informationCheckButtonTouchUp), for: .touchUpInside)
        callTeamInformationButton.addTarget(self, action: #selector(callTeamInformationButtonTouchUp), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTeamInformationTouchUp), for: .touchUpInside)

        let agreementTapGesture = UITapGestureRecognizer(target: self, action: #selector(informationAgreementLabelTouchUp))
        informationAgreementLabel.addGestureRecognizer(agreementTapGesture)
    }
    
    private func setupSliders() {
        skillSlider.addTarget(self, action: #selector(skillSliderValueChanged), for: .valueChanged)
        
        // RangeSeekSlider 설정 추가
        ageRangeSlider.delegate = self
    }
    
    private func setupIntroductionTableView() {
        introductionTableView.delegate = self
        introductionTableView.dataSource = self
        introductionTableView.register(TeamIntroductionTableViewCell.self, forCellReuseIdentifier: "IntroductionTableViewCell")
        introductionTableView.separatorStyle = .none
        introductionTableView.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        introductionTableView.showsVerticalScrollIndicator = false
        introductionTableView.showsHorizontalScrollIndicator = false
        introductionTableView.estimatedRowHeight = 50
        introductionTableView.rowHeight = UITableView.automaticDimension
        introductionTableView.isScrollEnabled = false
    }

    private func toggleInputMode(isDirectInput: Bool) {
        isDirectInputMode = isDirectInput
        introductionTableView.isHidden = isDirectInput
        directInputTextView.isHidden = !isDirectInput
        
        if isDirectInput {
            directInputTextView.becomeFirstResponder()
            if directInputTextView.text == "소개글을 직접 입력해주세요" {
                directInputTextView.text = ""
                directInputTextView.textColor = .black
            }
            // 기존 선택된 항목들 초기화
            tableViewModel.removeAll()
            introductionTableView.reloadData()
        } else {
            directInputTextView.resignFirstResponder()
            directInputTextView.text = "소개글을 직접 입력해주세요"
            directInputTextView.textColor = .lightGray
        }
    }

    // MARK: - Actions
    @objc private func addIntroductionButtonTouchUp(_ sender: RoundButton) {
        let introductionDetailView = IntroductionDetailView()
        introductionDetailView.delegate = self
        
        // 기존 선택된 항목들 전달
        let selectedComments = tableViewModel
        introductionDetailView.configure(with: selectedComments)
        
        self.subviewConstraints(view: introductionDetailView)
    }

    @objc private func informationCheckButtonTouchUp(_ sender: IBSelectTableButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func informationAgreementLabelTouchUp() {
        informationCheckButton.isSelected.toggle()
    }

    @objc private func callTeamInformationButtonTouchUp(_ sender: UIButton) {
        let callTeamInformationView = CallTeamInformationView()
        callTeamInformationView.delegate = self
        subviewConstraints(view: callTeamInformationView)
    }

    @objc func registerTeamInformationTouchUp(_ sender: UIButton) {
        // FirstVC에서 전달받은 데이터 확인
        guard var data = matchCreationData else {
            showAlert(message: "매칭 정보가 없습니다. 이전 화면에서 다시 시작해주세요.")
            return
        }

        // 팀 이름 확인
        guard let teamName = teamNameTextField.text, !teamName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(message: "팀 이름을 입력해주세요.")
            return
        }

        // 연락처 필수 정책
        let contact = contactTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !contact.isEmpty else {
            showAlert(message: "회장 연락처를 입력해주세요.")
            return
        }

        // 최소한의 전화번호 형식 검증 (숫자 8자리 이상)
        let contactDigits = contact.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        guard contactDigits.count >= 8 else {
            showAlert(message: "연락처 형식이 올바르지 않습니다.")
            return
        }

        // 연락처 공개 동의 확인
        guard informationCheckButton.isSelected else {
            showAlert(message: "연락처 공개 안내에 동의해주세요.") { [weak self] in
                self?.scrollToAgreementSection()
            }
            return
        }

        // 나머지 데이터 수집
        data.teamName = teamName
        data.ageRangeMin = Int(ageRangeSlider.selectedMinValue)
        data.ageRangeMax = Int(ageRangeSlider.selectedMaxValue)

        // 스킬 레벨 변환 (0-6 슬라이더 값 -> 문자열)
        let skillLevels = ["beginner", "beginner", "intermediate", "intermediate", "advanced", "advanced", "expert"]
        let skillIndex = Int(skillSlider.value)
        data.skillLevelMin = skillLevels[min(skillIndex, skillLevels.count - 1)]
        data.skillLevelMax = data.skillLevelMin

        // 팀 소개 수집 (테이블뷰 또는 직접입력)
        if isDirectInputMode {
            let directInputText = directInputTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if directInputText.isEmpty || directInputText == "소개글을 직접 입력해주세요" {
                data.teamIntroduction = nil
            } else {
                data.teamIntroduction = directInputText
            }
        } else {
            let introTexts = tableViewModel.map { $0.content }
            let joinedIntro = introTexts.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            data.teamIntroduction = joinedIntro.isEmpty ? nil : joinedIntro
        }

        // 연락처
        data.contactInfo = contact

        // 로딩 인디케이터 표시
        sender.isEnabled = false
        sender.setTitle("등록 중...", for: .normal)

        // API 호출
        APIService.shared.createMatch(data: data) { [weak self] result in
            sender.isEnabled = true
            sender.setTitle("등록하기", for: .normal)

            switch result {
            case .success(let response):
                if response.success {
                    self?.showAlert(message: "매칭이 성공적으로 등록되었습니다!") {
                        // 메인 화면으로 복귀
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                } else {
                    self?.showAlert(message: response.message ?? "매칭 등록에 실패했습니다.")
                }
            case .failure(let error):
                self?.showAlert(message: "네트워크 오류: \(error.localizedDescription)")
            }
        }
    }

    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }

    @objc func skillSliderValueChanged(_ sender: UISlider) {
        // 가장 가까운 정수값으로 반올림
        let roundedValue = round(sender.value)
        sender.value = roundedValue
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

    private func setAgeLabelsLayout() {
        let labelPositions = createLabelXPositions(rangeSlider: self.ageRangeSlider, customSlider: nil)
        setLabelsConstraint(slider: self.ageRangeSlider, labelXPositons: labelPositions, labels: self.ageSliderLabels)
    }

    private func setSkillLabelsLayout() {
        let labelPositions = createLabelXPositions(rangeSlider: nil, customSlider: self.skillSlider)
        
        // 슬라이더의 값 범위를 라벨 위치에 맞게 조정
        skillSlider.minimumValue = 0
        skillSlider.maximumValue = 6
        
        setLabelsConstraint(slider: self.skillSlider, labelXPositons: labelPositions, labels: self.skillSliderLabels)
    }

    private func createLabelXPositions(rangeSlider: UIControl?, customSlider: UISlider?) -> [CGFloat] {
        var labelsXPosition: [CGFloat] = []

        if let rangeSlider = rangeSlider {
            // RangeSeekSlider의 경우 (나이대)
            let sliderWidth = rangeSlider.frame.width
            let handleRadius: CGFloat = 9
            let effectiveWidth = sliderWidth - (2 * handleRadius)
            let division: CGFloat = 6
            let stepWidth = effectiveWidth / division
            
            for i in 0...6 {
                labelsXPosition.append(handleRadius + (stepWidth * CGFloat(i)))
            }
        } else if let customSlider = customSlider {
            // UISlider의 경우 (실력)
            let trackRect = customSlider.trackRect(forBounds: customSlider.bounds)
            let division: CGFloat = 6
            for i in 0...6 {
                let progress = CGFloat(i) / division
                labelsXPosition.append(trackRect.minX + (trackRect.width * progress))
            }
        }

        return labelsXPosition
    }

    private func setLabelsConstraint(slider: UIControl, labelXPositons: [CGFloat], labels: [UILabel]) {
        for index in 0..<labels.count {
            guard let label = labels[safe: index] else { return }
            guard let labelPosition = labelXPositons[safe: index] else { return }
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.removeFromSuperview()
            contentView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 12),
                label.centerXAnchor.constraint(equalTo: slider.leadingAnchor, constant: labelPosition)
            ])
        }
    }

    private func scrollToAgreementSection() {
        let targetRect = CGRect(
            x: 0,
            y: max(informationCheckButton.frame.minY - 20, 0),
            width: contentView.bounds.width,
            height: 80
        )
        scrollView.scrollRectToVisible(targetRect, animated: true)
    }
}

// MARK: - Extensions
extension SecondTeamRecruitmentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // 스와이프 액션 비활성화
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension SecondTeamRecruitmentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IntroductionTableViewCell", for: indexPath) as? TeamIntroductionTableViewCell else {
            return UITableViewCell()
        }

        guard let model = self.tableViewModel[safe: indexPath.row] else { return UITableViewCell() }

        cell.configure(model)
        cell.delegate = self
        cell.backgroundColor = .white
        cell.contentView.backgroundColor = .white

        return cell
    }
}

extension SecondTeamRecruitmentViewController: TeamIntroductionTableViewCellDelegate {
    func updownButtonDidSelected(_ tableviewCell: TeamIntroductionTableViewCell) {
        // 위아래 방향키 기능 비활성화
    }

    func removeButtonDidSeleced(_ tableviewCell: TeamIntroductionTableViewCell) {
        if let indexPath = introductionTableView.indexPath(for: tableviewCell) {
            self.tableViewModel.remove(at: indexPath.row)
            self.introductionTableView.reloadData()
            
            // 셀이 삭제된 후 테이블뷰 높이 업데이트
            self.updateTableViewHeight()
        }
    }
    
    private func updateTableViewHeight() {
        // 모든 셀의 예상 높이 합산
        var totalHeight: CGFloat = 0
        for i in 0..<tableViewModel.count {
            let indexPath = IndexPath(row: i, section: 0)
            totalHeight += self.tableView(introductionTableView, heightForRowAt: indexPath)
        }
        
        // 최소 높이 설정
        let minHeight: CGFloat = 50
        let finalHeight = max(minHeight, totalHeight)
        
        // 애니메이션과 함께 높이 업데이트
        UIView.animate(withDuration: 0.3) {
            self.introductionTableView.constraints.forEach { constraint in
                if constraint.firstAttribute == .height {
                    constraint.constant = finalHeight
                }
            }
            self.view.layoutIfNeeded()
        }
    }
}

extension SecondTeamRecruitmentViewController: IntroductionDetailViewDelegate {
    func cancelButtonDidSelected(_ view: IntroductionDetailView) {
        view.removeFromSuperview()
    }

    func OKButtonDidSelected(_ view: IntroductionDetailView, _ selectedComments: [Comment]) {
        DispatchQueue.main.async {
            if selectedComments.contains(where: { $0.content == "직접입력" }) {
                self.toggleInputMode(isDirectInput: true)
            } else {
                self.toggleInputMode(isDirectInput: false)
                self.tableViewModel = selectedComments
                self.introductionTableView.reloadData()
                
                // 테이블뷰 높이 업데이트
                self.updateTableViewHeight()
            }
            view.removeFromSuperview()
        }
    }
}

extension SecondTeamRecruitmentViewController: CallTeamInformationViewDelegate {
    func cancelButtonDidSelected(_ view: CallTeamInformationView) {
        view.removeFromSuperview()
    }

    func OKButtonDidSelected(_ view: CallTeamInformationView) {
        view.removeFromSuperview()
    }
}

extension SecondTeamRecruitmentViewController: DeleteTeamInformationViewDelegate {
    func cancelButtonDidSelected(_ view: DeleteTeamInformationView) {
        view.removeFromSuperview()
    }

    func OKButtonDidSelected(_ view: DeleteTeamInformationView) {
        view.removeFromSuperview()
    }
}

// RangeSeekSliderDelegate 구현
extension SecondTeamRecruitmentViewController: RangeSeekSliderDelegate {
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        // 슬라이더 값이 변경될 때마다 레이블 위치 업데이트
        setAgeLabelsLayout()
    }
}

// MARK: - UITextViewDelegate
extension SecondTeamRecruitmentViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "소개글을 직접 입력해주세요"
            textView.textColor = .lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 현재 텍스트의 길이 계산
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // 최대 길이 제한 (예: 500자)
        return updatedText.count <= 500
    }
}
