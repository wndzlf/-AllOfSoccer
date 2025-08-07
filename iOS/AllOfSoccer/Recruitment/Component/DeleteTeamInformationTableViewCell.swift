
import UIKit

protocol DeleteTeamInformationTableViewCellDelegate: AnyObject {
    func didSelect(teamInfo: DeleteTeamInformationView.TeamInfo)
}

class DeleteTeamInformationTableViewCell: UITableViewCell {

    internal weak var delegate: DeleteTeamInformationTableViewCellDelegate?

    private var teamInfo: DeleteTeamInformationView.TeamInfo?

    private var trashButton: SeletableButton = {
        let button = SeletableButton()
        button.normalImage = UIImage(systemName: "trash")
        button.selectImage = UIImage(systemName: "trash")
        button.normalBackgroundColor = UIColor.clear
        button.selectBackgroundColor = UIColor.clear
        button.normalBorderColor = UIColor.clear
        button.selectBorderColor = UIColor.clear
        button.normalTintColor = .black
        button.selectTintColor = .black
        button.normalTitleColor = UIColor.black
        button.selectTitleColor = UIColor.black

        button.addTarget(self, action: #selector(trashButtonTouchUp), for: .touchUpInside)

        return button
    }()

    private var mainLabel: UILabel = {
        let label = UILabel()
        label.text = "모두의 축구"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black

        return label
    }()

    private var subLabel: UILabel = {
        let label = UILabel()
        label.text = "20대 중반 - 30대 중반 / 실력 중하"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 157/255, green: 159/255, blue: 160/255, alpha: 1)

        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    private func setConstraints() {
        self.contentView.addsubviews(trashButton, mainLabel, subLabel)
        NSLayoutConstraint.activate([
            self.trashButton.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.trashButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),

            self.mainLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            self.mainLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),

            self.subLabel.topAnchor.constraint(equalTo: self.mainLabel.bottomAnchor, constant: 5),
            self.subLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            self.subLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5)
        ])
    }

    internal func configure(teamInfo: DeleteTeamInformationView.TeamInfo) {
        
    }

    @objc func trashButtonTouchUp(_ sender: SeletableButton) {

        if let data = self.teamInfo {
            delegate?.didSelect(teamInfo: data)
        }
    }
}
