//
//  IntroductionDetailView.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/09/11.
//

import UIKit

enum Comment: Int {
    case first
    case second
    case third
    case fourth
    case fifth

    var content: String {
        switch self {
        case .first: return "편하게 연락주세요."
        case .second: return "매너있게 운동하실 분 기다립니다."
        case .third: return "문자로 연락주세요."
        case .fourth: return "연락시 팀 소개 부탁드립니다."
        case .fifth: return "직접입력"
        }
    }
}

protocol IntroductionDetailViewDelegate: AnyObject {
    func cancelButtonDidSelected(_ view: IntroductionDetailView)
    func OKButtonDidSelected(_ view: IntroductionDetailView, _ model: [Comment])
}

class IntroductionDetailView: UIView {

    weak var delegate: IntroductionDetailViewDelegate?
    private var commentsModel: [Comment] = []
    
    // 선택된 항목들을 저장하는 프로퍼티 추가
    var selectedComments: [Comment] = [] {
        didSet {
            updateButtonStates()
        }
    }
    
    private func updateButtonStates() {
        let buttons = commentButtonStackView.arrangedSubviews.compactMap { $0 as? SeletableButton }
        buttons.forEach { button in
            if let comment = Comment(rawValue: button.tag) {
                button.isSelected = selectedComments.contains(comment)
            }
        }
    }

    private var baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()

    private var firstCommentButton: SeletableButton = {
        let button = SeletableButton()
        button.setTitle(Comment.first.content, for: .normal)
        button.normalImage = UIImage(systemName: "checkmark.circle")
        button.selectImage = UIImage(systemName: "checkmark.circle.fill")
        button.normalBackgroundColor = UIColor.clear
        button.selectBackgroundColor = UIColor.clear
        button.normalBorderColor = UIColor.clear
        button.selectBorderColor = UIColor.clear
        button.normalTintColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
        button.selectTintColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        button.normalTitleColor = UIColor.black
        button.selectTitleColor = UIColor.black
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left
        button.tag = Comment.first.rawValue

        button.addTarget(self, action: #selector(commentButtonTouchUp(_:)), for: .touchUpInside)

        return button
    }()

    private var secondCommentButton: SeletableButton = {
        let button = SeletableButton()
        button.setTitle(Comment.second.content, for: .normal)
        button.normalImage = UIImage(systemName: "checkmark.circle")
        button.selectImage = UIImage(systemName: "checkmark.circle.fill")
        button.normalBackgroundColor = UIColor.clear
        button.selectBackgroundColor = UIColor.clear
        button.normalBorderColor = UIColor.clear
        button.selectBorderColor = UIColor.clear
        button.normalTintColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
        button.selectTintColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        button.normalTitleColor = UIColor.black
        button.selectTitleColor = UIColor.black
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left
        button.tag = Comment.second.rawValue

        button.addTarget(self, action: #selector(commentButtonTouchUp(_:)), for: .touchUpInside)

        return button
    }()

    private var thirdCommentButton: SeletableButton = {
        let button = SeletableButton()
        button.setTitle(Comment.third.content, for: .normal)
        button.normalImage = UIImage(systemName: "checkmark.circle")
        button.selectImage = UIImage(systemName: "checkmark.circle.fill")
        button.normalBackgroundColor = UIColor.clear
        button.selectBackgroundColor = UIColor.clear
        button.normalBorderColor = UIColor.clear
        button.selectBorderColor = UIColor.clear
        button.normalTintColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
        button.selectTintColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        button.normalTitleColor = UIColor.black
        button.selectTitleColor = UIColor.black
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left
        button.tag = Comment.third.rawValue

        button.addTarget(self, action: #selector(commentButtonTouchUp(_:)), for: .touchUpInside)

        return button
    }()

    private var fourthCommentButton: SeletableButton = {
        let button = SeletableButton()
        button.setTitle(Comment.fourth.content, for: .normal)
        button.normalImage = UIImage(systemName: "checkmark.circle")
        button.selectImage = UIImage(systemName: "checkmark.circle.fill")
        button.normalBackgroundColor = UIColor.clear
        button.selectBackgroundColor = UIColor.clear
        button.normalBorderColor = UIColor.clear
        button.selectBorderColor = UIColor.clear
        button.normalTintColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
        button.selectTintColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        button.normalTitleColor = UIColor.black
        button.selectTitleColor = UIColor.black
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left
        button.tag = Comment.fourth.rawValue

        button.addTarget(self, action: #selector(commentButtonTouchUp(_:)), for: .touchUpInside)

        return button
    }()

    private var fifthCommentButton: SeletableButton = {
        let button = SeletableButton()
        button.setTitle(Comment.fifth.content, for: .normal)
        button.normalImage = UIImage(systemName: "checkmark.circle")
        button.selectImage = UIImage(systemName: "checkmark.circle.fill")
        button.normalBackgroundColor = UIColor.clear
        button.selectBackgroundColor = UIColor.clear
        button.normalBorderColor = UIColor.clear
        button.selectBorderColor = UIColor.clear
        button.normalTintColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
        button.selectTintColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1)
        button.normalTitleColor = UIColor.black
        button.selectTitleColor = UIColor.black
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left
        button.tag = Comment.fifth.rawValue

        button.addTarget(self, action: #selector(commentButtonTouchUp(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var commentButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.firstCommentButton, self.secondCommentButton, self.thirdCommentButton, self.fourthCommentButton, self.fifthCommentButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 19
        stackView.distribution = .fillEqually

        return stackView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 246/255, green: 247/255, blue: 250/255, alpha: 1).cgColor
        button.clipsToBounds = true
        button.setBackgroundColor(UIColor(red: 246/255, green: 247/255, blue: 250/255, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonDidSelected), for: .touchUpInside)

        return button
    }()

    private lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("선택", for: .normal)
        button.setBackgroundColor(UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(red: 236/255, green: 95/255, blue: 95/255, alpha: 1).cgColor
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(OKButtonDidSelected), for: .touchUpInside)

        return button
    }()

    private lazy var OKCancelButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, okButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()

    @objc private func commentButtonTouchUp(_ sender: UIButton) {
        guard let tappedComment = Comment(rawValue: sender.tag) else { return }

        // 직접입력은 단독 선택
        if tappedComment == .fifth {
            if selectedComments.contains(.fifth) {
                selectedComments.removeAll { $0 == .fifth }
            } else {
                selectedComments = [.fifth]
            }
            return
        }

        // 일반 문구를 누르면 직접입력은 항상 해제
        selectedComments.removeAll { $0 == .fifth }

        if let index = selectedComments.firstIndex(of: tappedComment) {
            selectedComments.remove(at: index)
        } else {
            selectedComments.append(tappedComment)
        }
    }

    @objc func cancelButtonDidSelected(sender: UIButton) {
        self.delegate?.cancelButtonDidSelected(self)
    }

    @objc func OKButtonDidSelected(sender: UIButton) {
        self.commentsModel = selectedComments.sorted { $0.rawValue < $1.rawValue }
        self.delegate?.OKButtonDidSelected(self, self.commentsModel)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }

    private func loadView() {
        setSuperView()
        setConstraint()
    }

    private func setSuperView() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    }

    private func setConstraint() {
        self.addsubviews(self.baseView)
        self.baseView.addsubviews(self.commentButtonStackView,self.OKCancelButtonStackView)

        NSLayoutConstraint.activate([

            self.baseView.topAnchor.constraint(equalTo: self.topAnchor, constant: 257),
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -257),

            self.commentButtonStackView.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 30),
            self.commentButtonStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 32),
            self.commentButtonStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -32),
            self.commentButtonStackView.bottomAnchor.constraint(equalTo: self.OKCancelButtonStackView.topAnchor, constant: -30),

            self.OKCancelButtonStackView.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 32),
            self.OKCancelButtonStackView.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -32),
            self.OKCancelButtonStackView.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -24),
            self.OKCancelButtonStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func configure(with selectedComments: [Comment]) {
        self.selectedComments = selectedComments
    }
}
