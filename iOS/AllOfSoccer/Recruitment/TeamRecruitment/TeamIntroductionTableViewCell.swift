//
//  IntroductionTableViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/09/08.
//

import UIKit

protocol TeamIntroductionTableViewCellDelegate: AnyObject {
    func removeButtonDidSeleced(_ tableviewCell: TeamIntroductionTableViewCell)
}

class TeamIntroductionTableViewCell: UITableViewCell {

    weak var delegate: TeamIntroductionTableViewCellDelegate?

    // MARK: - UI Components
    private let containerView = RoundView()
    private let contentsLabel = UILabel()
    private let removeButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setupActions()
        disableGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupActions()
        disableGestures()
    }

    private func disableGestures() {
        // 모든 기본 제스처 비활성화
        for gesture in gestureRecognizers ?? [] {
            gesture.isEnabled = false
        }
        for gesture in contentView.gestureRecognizers ?? [] {
            gesture.isEnabled = false
        }
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        isUserInteractionEnabled = true
        
        // 스와이프와 드래그 비활성화
        shouldIndentWhileEditing = false
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 6
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentsLabel.text = "직접입력"
        contentsLabel.font = UIFont.systemFont(ofSize: 14)
        contentsLabel.textColor = .black
        contentsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentsLabel.numberOfLines = 0
        contentsLabel.lineBreakMode = .byWordWrapping
        
        removeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        removeButton.tintColor = UIColor(red: 0.615, green: 0.623, blue: 0.627, alpha: 1.0)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.isUserInteractionEnabled = true
    }
    
    private func setupConstraints() {
        contentView.addSubview(containerView)
        containerView.addSubview(contentsLabel)
        containerView.addSubview(removeButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            contentsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            contentsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentsLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -12),
            contentsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            removeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40.0),
            removeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 18),
            removeButton.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func setupActions() {
        removeButton.addTarget(self, action: #selector(removeButtonDidSelected), for: .touchUpInside)
    }

    @objc func removeButtonDidSelected(_ sender: UIButton) {
        self.delegate?.removeButtonDidSeleced(self)
    }

    func configure(_ model: Comment) {
        self.contentsLabel.text = model.content
    }
}
