//
//  DXFullImageButton.swift
//  DXPhotoPickerDemo
//
//  Created by DingXiao on 15/10/30.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

class DXFullImageButton: UIView {
    
    struct DXFullImageButtonParam {
        static let buttonPadding: CGFloat = 20
        static let buttonImageWidth: CGFloat = 16
        static let buttonFont = UIFont.systemFontOfSize(13)
    }
    
    // MARK: lazy load property
    
    private lazy var fullImageButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = self.backgroundColor
        self.addSubview(button)
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imv = UIImageView(frame: CGRectZero)
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.backgroundColor = self.backgroundColor
        return imv
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.text = DXlocalizedString("fullImage", comment: "原图")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = self.backgroundColor
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = .Left
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    private lazy var imageSizeLabel: UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = self.backgroundColor
        label.font = UIFont.systemFontOfSize(13)
        label.textAlignment = .Left
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRectZero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.stopAnimating()
        return view
    }()
    
    // MARK: public
    var text: String {
        didSet {
            imageSizeLabel.text = text
        }
    }
    
    var selected: Bool {
        didSet {
            imageSizeLabel.hidden = !selected
            if selected {
                imageView.image = UIImage(named: "photo_full_image_selected")
            } else {
                imageView.image = UIImage(named: "photo_full_image_unselected")
            }
        }
    }
    
    func addTarget(target: AnyObject?, action: Selector) {
        fullImageButton.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func shouldAnimating(animated: Bool) {
        if selected {
            imageSizeLabel.hidden = animated
            if animated {
                indicatorView.startAnimating()
            } else {
                indicatorView.stopAnimating()
            }
        }
    }
    
    // MARK: priviate
    
    private func setupView() {
        backgroundColor = UIColor.clearColor()
        addSubview(fullImageButton)
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(imageSizeLabel)
        addSubview(indicatorView)
        imageView.image = UIImage(named: "photo_full_image_unselected")
        let viewBindingsDict = [
            "fullImageButton":fullImageButton,
            "imageView": imageView,
            "nameLabel": nameLabel,
            "imageSizeLabel": imageSizeLabel,
            "indicatorView": indicatorView
        ]
        
        let btVflH = "H:|-0-[fullImageButton]-0-|"
        let btVflV = "V:|-0-[fullImageButton]-0-|"
        let vflH = "H:|-0-[imageView(20)]-5-[nameLabel(>=2)]-5-[imageSizeLabel(80)]"
        let constraintsVflH = NSLayoutConstraint.constraintsWithVisualFormat(vflH, options: .AlignAllCenterY, metrics: nil, views: viewBindingsDict)
        let btContstraintsH = NSLayoutConstraint.constraintsWithVisualFormat(btVflH, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewBindingsDict)
        let btContstraintsV = NSLayoutConstraint.constraintsWithVisualFormat(btVflV, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewBindingsDict)
        let imageCenter = NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: fullImageButton, attribute: .CenterY, multiplier: 1, constant: 0)
        let imageViewHeight = NSLayoutConstraint(item: imageView, attribute: .Height, relatedBy: .Equal, toItem: imageView, attribute: .Width, multiplier: 1, constant: 0)
        let nameLabelHeight = NSLayoutConstraint(item: nameLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 30)
        let imageSizeLabelHeight = NSLayoutConstraint(item: imageSizeLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 30)
        let indicatorViewWidth = NSLayoutConstraint(item: indicatorView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 26)
        let indicatorViewLeading = NSLayoutConstraint(item: indicatorView, attribute: .Leading, relatedBy: .Equal, toItem: imageSizeLabel, attribute: .Leading, multiplier: 1, constant: 0)
        let indicatorViewCenterY = NSLayoutConstraint(item: indicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: imageSizeLabel, attribute: .CenterY, multiplier: 1, constant: 0)
        let indicatorViewHeight = NSLayoutConstraint(item: indicatorView, attribute: .Height, relatedBy: .Equal, toItem: indicatorView, attribute: .Width, multiplier: 1, constant: 0)
        
        
        addConstraints(btContstraintsH)
        addConstraints(btContstraintsV)
        addConstraints(constraintsVflH)
        addConstraints([imageCenter, imageViewHeight, nameLabelHeight, imageSizeLabelHeight,indicatorViewCenterY,indicatorViewLeading,indicatorViewWidth,indicatorViewHeight])
    }
    
    // MARK: init
    override init(frame: CGRect) {
        selected = false
        text = ""
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        selected = false
        text = ""
        super.init(coder: aDecoder)
    }
}
