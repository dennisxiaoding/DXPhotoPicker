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
    
    private var selectItemBlock: ((Bool, PHAsset) -> Bool)?
    
    lazy var imageView: UIImageView = {
        let imv = UIImageView(image: UIImage(named: "assets_placeholder_picture"))
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    private lazy var checkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(DXAssetCell.checkButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var checkImageView: UIImageView = {
        let imv = UIImageView(frame: CGRect.zero)
        imv.contentMode = .scaleAspectFit
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
        self.checkButton(selected: assetSeleted, animated: false)
    }
    
    func selectItemBlock(block: @escaping (_ selected: Bool, _ asset: PHAsset) -> Bool) {
        self.selectItemBlock = block
    }
    
    
    // MARK: convenience
    
    func checkButton(selected: Bool, animated: Bool) {
        if selected {
            self.checkImageView.image = UIImage(named: "photo_check_selected")
            if animated == false {
                return
            }
            UIView.animate(withDuration: 0.2,
                animations: {
                    [unowned self] () -> Void in
                    self.checkImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2);},
                completion: {
                    [unowned self](stop) -> Void in
                    UIView.animate(withDuration: 0.2, animations: { [unowned self]() -> Void in
                        self.checkImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0);
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
        ] as [String : Any]
        let mertic = ["sideLength": 25]
        let imageViewVFLV = "V:|-0-[posterImageView]-0-|"
        let imageViewVFLH = "H:|-0-[posterImageView]-0-|"
        let imageViewContraintsV = NSLayoutConstraint.constraints(
            withVisualFormat: imageViewVFLV,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewBindingsDict
        )
        let imageViewContraintsH = NSLayoutConstraint.constraints(
            withVisualFormat: imageViewVFLH,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: viewBindingsDict
        )
        let checkImageViewVFLH = "H:[checkImageView(sideLength)]-3-|"
        let checkImageViewVFLV = "V:|-3-[checkImageView(sideLength)]"
        let checkImageViewContrainsH = NSLayoutConstraint.constraints(
            withVisualFormat: checkImageViewVFLH,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: mertic,
            views: viewBindingsDict
        )
        let checkImageViewContrainsV = NSLayoutConstraint.constraints(
            withVisualFormat: checkImageViewVFLV,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: mertic,
            views: viewBindingsDict
        )
        let checkConstraitRight = NSLayoutConstraint(
            item: checkButton,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0
        )
        let checkConstraitTop = NSLayoutConstraint(
            item: checkButton,
            attribute: .top,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .top,
            multiplier: 1.0,
            constant: 0
        )
        let checkContraitWidth = NSLayoutConstraint(
            item: checkButton,
            attribute: .width,
            relatedBy: .equal,
            toItem: imageView,
            attribute: .width,
            multiplier: 0.5,
            constant: 0
        )
        let checkConsraintHeight = NSLayoutConstraint(
            item: checkButton,
            attribute: .height,
            relatedBy: .equal,
            toItem: checkButton,
            attribute: .height,
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
        assetSeleted = selectItemBlock!(assetSeleted, asset!)
        self.checkButton(selected: assetSeleted, animated: true)
    }
}
