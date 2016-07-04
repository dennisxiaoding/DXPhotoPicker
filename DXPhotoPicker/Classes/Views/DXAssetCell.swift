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
    
    // MARK: properties
    private var asset: PHAsset?
    
    private var selectItemBlock: ((selectItem: Bool, asset: PHAsset) -> Bool)?
    
    lazy var imageView: UIImageView = {
        let imv = UIImageView(image: UIImage(named: "assets_placeholder_picture"))
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(DXAssetCell.checkButtonAction), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private lazy var checkImageView: UIImageView = {
        let imv = UIImageView(frame: CGRectZero)
        imv.contentMode = .ScaleAspectFit
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    private var assetSeleted: Bool = false
    
    // MARK: life time
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func prepareForReuse() {
        self.assetSeleted = false
        if (self.imageView.image != nil) {
            self.imageView.image = nil
        }
        if self.asset != nil {
            self.asset = nil
        }
        
    }
    
    // MARK: public methods
    
    func fillWithAsset(asset: PHAsset, isAssetSelected: Bool) {
        self.asset = asset
        assetSeleted = isAssetSelected
        checkButton(assetSeleted, animated: false)
    }
    
    func selectItemBlock(block: (selected: Bool, asset: PHAsset) -> Bool) {
        self.selectItemBlock = block
    }
    
    
    // MARK: convenience
    
    func checkButton(selected: Bool, animated: Bool) {
        if selected {
            self.checkImageView.image = UIImage(named: "photo_check_selected")
            if animated == false {
                return
            }
            UIView.animateWithDuration(0.2,
                animations: {
                    [unowned self] () -> Void in
                    self.checkImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);},
                completion: {
                    [unowned self](stop) -> Void in
                    UIView.animateWithDuration(0.2, animations: { [unowned self]() -> Void in
                        self.checkImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                        })
                })
        } else {
            self.checkImageView.image = UIImage(named: "photo_check_default")
        }
    }
    
    private func setupView() {
        contentView.addSubview(imageView)
        contentView.addSubview(checkImageView)
        contentView.addSubview(checkButton)
        let viewBindingsDict = [
            "posterImageView":imageView,
            "checkButton": checkButton,
            "checkImageView": checkImageView
        ]
        let mertic = ["sideLength": 25]
        let imageViewVFLV = "V:|-0-[posterImageView]-0-|"
        let imageViewVFLH = "H:|-0-[posterImageView]-0-|"
        let imageViewContraintsV = NSLayoutConstraint.constraintsWithVisualFormat(
            imageViewVFLV,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewBindingsDict
        )
        let imageViewContraintsH = NSLayoutConstraint.constraintsWithVisualFormat(
            imageViewVFLH,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewBindingsDict
        )
        let checkImageViewVFLH = "H:[checkImageView(sideLength)]-3-|"
        let checkImageViewVFLV = "V:|-3-[checkImageView(sideLength)]"
        let checkImageViewContrainsH = NSLayoutConstraint.constraintsWithVisualFormat(
            checkImageViewVFLH,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: mertic,
            views: viewBindingsDict
        )
        let checkImageViewContrainsV = NSLayoutConstraint.constraintsWithVisualFormat(
            checkImageViewVFLV,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: mertic,
            views: viewBindingsDict
        )
        let checkConstraitRight = NSLayoutConstraint(
            item: checkButton,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 0
        )
        let checkConstraitTop = NSLayoutConstraint(
            item: checkButton,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: contentView,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0
        )
        let checkContraitWidth = NSLayoutConstraint(
            item: checkButton,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: imageView,
            attribute: .Width,
            multiplier: 0.5,
            constant: 0
        )
        let checkConsraintHeight = NSLayoutConstraint(
            item: checkButton,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: checkButton,
            attribute: .Height,
            multiplier: 1.0,
            constant: 0
        )
        addConstraints(imageViewContraintsV)
        addConstraints(imageViewContraintsH)
        addConstraints(checkImageViewContrainsH)
        addConstraints(checkImageViewContrainsV)
        addConstraints([checkConstraitRight,checkConstraitTop,checkContraitWidth,checkConsraintHeight])
    }
    
    // MARK:UI actions
    @objc private func checkButtonAction() {
        assetSeleted = !assetSeleted
        guard selectItemBlock != nil else {
            return
        }
        assetSeleted = selectItemBlock!(selectItem: assetSeleted, asset: asset!)
        checkButton(assetSeleted, animated: true)
    }
}