//
//  UITableViewCell+Extension.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/09/22.
//

import UIKit

extension UITableViewCell {

    static var reuseId: String {
        return String(describing: self)
    }
}
