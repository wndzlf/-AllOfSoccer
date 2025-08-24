//
//  IntroductionTableViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/09/08.
//

import UIKit

protocol TeamIntroductionTableViewCellDelegate: AnyObject {
    func removeButtonDidSeleced(_ tableviewCell: TeamIntroductionTableViewCell)
    func updownButtonDidSelected(_ tableviewCell: TeamIntroductionTableViewCell)
}

class TeamIntroductionTableViewCell: UITableViewCell {

    weak var delegate: TeamIntroductionTableViewCellDelegate?

    // MARK: - UI Components
    private let containerView = RoundView()
    private let contentsLabel = UILabel()
    private let updownButton = UIButton(type: .system)
    private let removeButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupActions()
    }

    private func setupUI() {
        backgroundColor = UIColor(red: 0.964, green: 0.968, blue: 0.980, alpha: 1.0)
        selectionStyle = .none
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 6
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentsLabel.text = "직접입력"
        contentsLabel.font = UIFont.systemFont(ofSize: 14)
        contentsLabel.textColor = UIColor(red: 0.537, green: 0.556, blue: 0.580, alpha: 1.0)
        contentsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        updownButton.setImage(UIImage(named: "CaretUp"), for: .normal)
        updownButton.tintColor = UIColor(red: 0.615, green: 0.623, blue: 0.627, alpha: 1.0)
        updownButton.translatesAutoresizingMaskIntoConstraints = false
        
        removeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        removeButton.tintColor = UIColor(red: 0.615, green: 0.623, blue: 0.627, alpha: 1.0)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        contentView.addSubview(containerView)
        containerView.addSubview(contentsLabel)
        containerView.addSubview(updownButton)
        containerView.addSubview(removeButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11),
            containerView.heightAnchor.constraint(equalToConstant: 50),
            
            contentsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentsLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            updownButton.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -10),
            updownButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            updownButton.widthAnchor.constraint(equalToConstant: 20),
            updownButton.heightAnchor.constraint(equalToConstant: 20),
            
            removeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            removeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 18),
            removeButton.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func setupActions() {
        removeButton.addTarget(self, action: #selector(removeButtonDidSelected), for: .touchUpInside)
        updownButton.addTarget(self, action: #selector(updownButtonDidSelected), for: .touchUpInside)
    }

    @objc func removeButtonDidSelected(_ sender: UIButton) {
        self.delegate?.removeButtonDidSeleced(self)
    }

    @objc func updownButtonDidSelected(_ sender: Any) {
        self.delegate?.updownButtonDidSelected(self)
    }

    func configure(_ model: Comment) {
        self.contentsLabel.text = model.content
    }
}
