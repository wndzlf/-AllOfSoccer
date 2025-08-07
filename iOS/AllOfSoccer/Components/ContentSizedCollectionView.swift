//
//  ContentSizedCollectionView.swift
//  AllOfSoccer
//
//  Created by 최원석 on 2021/07/03.
//

import UIKit

class ContentSizedCollectionView: UICollectionView {
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: collectionViewLayout.collectionViewContentSize.height)
    }
}
