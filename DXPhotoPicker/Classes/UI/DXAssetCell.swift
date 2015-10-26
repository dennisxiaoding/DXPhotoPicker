//
//  DXAssetCell.swift
//  DXPhotoPickerDemo
//
//  Created by DingXiao on 15/10/26.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

@available(iOS 8.0, *)
class DXAssetCell: UICollectionViewCell {

    // MARK: public methods
    func fillWithAsset(asset: PHAsset, isAssetSelected: Bool) {
        self.asset = asset
        self.selected = isAssetSelected
    }
    
    func selectItemBlock(block: (selectItem: Bool, asset: PHAsset) -> Void) {
        self.selectItemBlock = block
    }
    
    var asset: PHAsset?
    
    private var selectItemBlock: ((selectItem: Bool, asset: PHAsset) -> Void)?
    
    private lazy var imageView: UIImageView = {
        let imv = UIImageView(image: UIImage(named: "assets_placeholder_picture"))
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: Selector("checkButtonAction"), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private lazy var checkImageView: UIImageView = {
        let imv = UIImageView(frame: CGRectZero)
        imv.contentMode = .ScaleAspectFit
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
// MARK: convenience
    
    private func setupView() {
        contentView.addSubview(imageView)
        contentView.addSubview(checkImageView)
        contentView.addSubview(checkButton)
        // TODO: autolayout
    }
    

    
// MARK:UI actions
    @objc private func checkButtonAction() {
        self.selected = !self.selected
        guard self.selectItemBlock != nil else {
            return
        }
        self.selectItemBlock!(selectItem: self.selected, asset: self.asset!)
    }
}