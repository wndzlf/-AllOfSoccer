//
//  MyFavoriteTableViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/10/16.
//

import UIKit

protocol MyFavoriteTableViewCellDelegate: AnyObject {
    func favoriteButtonDidSelected(tableViewModel: MyFavoriteViewController.TableViewModel)
}

class MyFavoriteTableViewCell: UITableViewCell {

    internal weak var delegate: MyFavoriteTableViewCellDelegate?
    private var tableViewModel: MyFavoriteViewController.TableViewModel?

    @IBOutlet private weak var dateAndLocationLabel: UILabel!
    @IBOutlet private weak var rulesLabel: UILabel!
    @IBOutlet private weak var feeLabel: UILabel!
    @IBOutlet private weak var teamInfoLabel: UILabel!
    @IBOutlet private weak var recruitmentStateLabel: UILabel!

    @IBAction private func favoriteButtonTouchUp(_ sender: UIButton) {
        guard let tableViewModel = self.tableViewModel else { return}

        self.delegate?.favoriteButtonDidSelected(tableViewModel: tableViewModel)
    }

    internal func configure(_ model: MyFavoriteViewController.TableViewModel) {

        self.tableViewModel = model
        self.dateAndLocationLabel.text = "\(model.date) \(model.location)"
        self.rulesLabel.text = "\(model.rules)"
        self.feeLabel.text = "\(String(describing: model.fee))"
        self.teamInfoLabel.text = "\(model.temaInfo)"
        self.recruitmentStateLabel.text = "\(model.recruitmentState)"
    }
}
