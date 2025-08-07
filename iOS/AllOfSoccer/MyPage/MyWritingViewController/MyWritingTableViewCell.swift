//
//  MyWritingTableViewCell.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/10/16.
//

import UIKit

protocol MyWritingTableViewCellDelegate: AnyObject {
    func deleteButtonDidSelected(tableViewModel: MyWritingViewController.TableViewModel)
}

class MyWritingTableViewCell: UITableViewCell {

    internal weak var delegate: MyWritingTableViewCellDelegate?
    private var tableViewModel: MyWritingViewController.TableViewModel?

    @IBOutlet private weak var dateAndLocationLabel: UILabel!
    @IBOutlet private weak var rulesLabel: UILabel!
    @IBOutlet private weak var feeLabel: UILabel!
    @IBOutlet private weak var teamInfoLabel: UILabel!
    @IBOutlet private weak var recruitmentStateLabel: UILabel!

    @IBAction private func deleteButtonTouchUp(_ sender: UIButton) {
        guard let tableViewModel = self.tableViewModel else { return}

        self.delegate?.deleteButtonDidSelected(tableViewModel: tableViewModel)
    }

    internal func configure(_ model: MyWritingViewController.TableViewModel) {

        self.tableViewModel = model
        self.dateAndLocationLabel.text = "\(model.date) \(model.location)"
        self.rulesLabel.text = "\(model.rules)"
        self.feeLabel.text = "\(String(describing: model.fee))"
        self.teamInfoLabel.text = "\(model.temaInfo)"
    }
}
