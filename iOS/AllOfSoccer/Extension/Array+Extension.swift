//
//  Array+Extension.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/09/22.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }

    subscript(safe bounds: Range<Int>) -> ArraySlice<Element>? {
        guard self.indices.lowerBound <= bounds.lowerBound && self.indices.upperBound >= bounds.upperBound else {
            return nil
        }
        return self[bounds]
    }

    subscript(safe bounds: ClosedRange<Int>) -> ArraySlice<Element>? {
        guard self.indices.lowerBound <= bounds.lowerBound && self.indices.upperBound >= bounds.upperBound else {
            return nil
        }
        return self[bounds]
    }
}
