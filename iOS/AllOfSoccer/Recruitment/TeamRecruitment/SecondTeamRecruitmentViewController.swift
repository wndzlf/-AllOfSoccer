import UIKit
import RangeSeekSlider

class SecondTeamRecruitmentViewController: UIViewController {

    private var tableViewModel: [Comment] = []

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
    private let rememberLabel = UILabel()
    
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
        skillSlider.minimumValue = 10
        skillSlider.maximumValue = 70
        skillSlider.value = 40
        skillSlider.minimumTrackTintColor = UIColor(red: 0.925, green: 0.925, blue: 0.925, alpha: 1.0)
        skillSlider.maximumTrackTintColor = UIColor(red: 0.925, green: 0.925, blue: 0.925, alpha: 1.0)
        skillSlider.thumbTintColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)
        skillSlider.setThumbImage(UIImage(systemName: "circle.fill")?.withTintColor(UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0), renderingMode: .alwaysOriginal), for: .normal)
        
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
        
        introductionTableView.backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        introductionTableView.translatesAutoresizingMaskIntoConstraints = false
        
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
        informationCheckButton.tintColor = UIColor(red: 0.803, green: 0.803, blue: 0.803, alpha: 1.0)
        
        rememberLabel.text = "이 정보 다음에 기억하기"
        rememberLabel.font = UIFont.systemFont(ofSize: 16)
        rememberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Bottom Button
        registerButton.setTitle("등록하기", for: .normal)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.backgroundColor = UIColor(red: 0.925, green: 0.372, blue: 0.372, alpha: 1.0)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
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
        
        contentView.addSubview(contactLabel)
        contentView.addSubview(contactView)
        contactView.addSubview(contactImageView)
        contactView.addSubview(contactTextField)
        contentView.addSubview(informationCheckButton)
        contentView.addSubview(rememberLabel)
        
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
            introductionTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            introductionTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            introductionTableView.heightAnchor.constraint(equalToConstant: 128),
            
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
            
            rememberLabel.leadingAnchor.constraint(equalTo: informationCheckButton.trailingAnchor, constant: 10),
            rememberLabel.centerYAnchor.constraint(equalTo: informationCheckButton.centerYAnchor)
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
    }
    
    private func setupActions() {
        addIntroductionButton.addTarget(self, action: #selector(addIntroductionButtonTouchUp), for: .touchUpInside)
        informationCheckButton.addTarget(self, action: #selector(informationCheckButtonTouchUp), for: .touchUpInside)
        callTeamInformationButton.addTarget(self, action: #selector(callTeamInformationButtonTouchUp), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTeamInformationTouchUp), for: .touchUpInside)
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
    }

    // MARK: - Actions
    @objc private func addIntroductionButtonTouchUp(_ sender: RoundButton) {
        let introductionDetailView = IntroductionDetailView()
        introductionDetailView.delegate = self
        self.subviewConstraints(view: introductionDetailView)
    }

    @objc private func informationCheckButtonTouchUp(_ sender: IBSelectTableButton) {
        sender.isSelected = !sender.isSelected
    }

    @objc private func callTeamInformationButtonTouchUp(_ sender: UIButton) {
        let callTeamInformationView = CallTeamInformationView()
        callTeamInformationView.delegate = self
        subviewConstraints(view: callTeamInformationView)
    }

    @objc func registerTeamInformationTouchUp(_ sender: UIButton) {
        let deleteTeamInformationView = DeleteTeamInformationView()
        deleteTeamInformationView.delegate = self
        subviewConstraints(view: deleteTeamInformationView)
    }

    @objc func skillSliderValueChanged(_ sender: OneThumbSlider) {
        let values = "(\(sender.value)"
        print("Range slider value changed: \(values)")
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
        setLabelsConstraint(slider: self.skillSlider, labelXPositons: labelPositions, labels: self.skillSliderLabels)
    }

    private func createLabelXPositions(rangeSlider: UIControl?, customSlider: UISlider?) -> [CGFloat] {
        var labelsXPosition: [CGFloat] = []

        if let rangeSlider = rangeSlider {
            // RangeSeekSlider의 경우 (나이대)
            let sliderWidth = rangeSlider.frame.width
            let handleRadius: CGFloat = 9 // handleDiameter의 절반
            let effectiveWidth = sliderWidth - (2 * handleRadius) // 실제 사용 가능한 너비
            let division: CGFloat = 6 // 6개의 간격으로 7개의 포인트
            let stepWidth = effectiveWidth / division
            
            // 각 라벨의 x 위치 계산
            for i in 0...6 {
                let xPosition = handleRadius + (stepWidth * CGFloat(i))
                labelsXPosition.append(xPosition)
            }
        } else if let customSlider = customSlider {
            // UISlider의 경우 (실력)
            let sliderWidth = customSlider.frame.width
            let thumbWidth: CGFloat = 20 // thumb 이미지의 너비
            let effectiveWidth = sliderWidth - thumbWidth
            let division: CGFloat = 6
            let stepWidth = effectiveWidth / division
            
            // 각 라벨의 x 위치 계산
            for i in 0...6 {
                let xPosition = (thumbWidth/2) + (stepWidth * CGFloat(i))
                labelsXPosition.append(xPosition)
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
            
            // 모든 라벨에 대해 중앙 정렬 적용
            let xPosition = labelPosition - (label.intrinsicContentSize.width / 2)
            
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 12),
                label.leadingAnchor.constraint(equalTo: slider.leadingAnchor, constant: xPosition)
            ])
        }
    }
}

// MARK: - Extensions
extension SecondTeamRecruitmentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.tableViewModel[sourceIndexPath.row]
        self.tableViewModel.remove(at: sourceIndexPath.row)
        self.tableViewModel.insert(movedObject, at: destinationIndexPath.row)
        self.introductionTableView.isEditing = false
        self.introductionTableView.reloadData()
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

        return cell
    }
}

extension SecondTeamRecruitmentViewController: TeamIntroductionTableViewCellDelegate {
    func updownButtonDidSelected(_ tableviewCell: TeamIntroductionTableViewCell) {
        self.introductionTableView.isEditing = true
    }

    func removeButtonDidSeleced(_ tableviewCell: TeamIntroductionTableViewCell) {
        self.tableViewModel.removeLast()
        self.introductionTableView.reloadData()
    }
}

extension SecondTeamRecruitmentViewController: IntroductionDetailViewDelegate {
    func cancelButtonDidSelected(_ view: IntroductionDetailView) {
        view.removeFromSuperview()
    }

    func OKButtonDidSelected(_ view: IntroductionDetailView, _ model: [Comment]) {
        DispatchQueue.main.async {
            self.tableViewModel = model
            self.introductionTableView.reloadData()
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
