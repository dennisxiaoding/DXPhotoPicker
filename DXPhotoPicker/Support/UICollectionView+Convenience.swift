//
//  UICollectionView+Convenience.swift
//  DXPhotoPickerDemo
//
//  Created by DingXiao on 15/12/30.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

extension UICollectionView {
    func aapl_indexPathsForElementsInRect(rect: CGRect) -> [NSIndexPath]? {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)
        if allLayoutAttributes?.count == 0 {
            return nil
        }
        var indexPaths = [NSIndexPath]()
        for (_, layoutAttributes) in allLayoutAttributes!.enumerated() {
            let indexPath = layoutAttributes.indexPath;
            indexPaths.append(indexPath as NSIndexPath)
        }
        return indexPaths
    }
}
