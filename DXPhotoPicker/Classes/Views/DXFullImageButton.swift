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
        static let buttonFont = UIFont.systemFont(ofSize: 13)
    }
    
    // MARK: lazy load property
    
    private lazy var fullImageButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = self.backgroundColor
        self.addSubview(button)
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imv = UIImageView(frame: CGRect.zero)
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.backgroundColor = self.backgroundColor
        return imv
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = DXlocalized(string: "fullImage", comment: "原图")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = self.backgroundColor
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = UIColor.white
        return label
    }()
    
    private lazy var imageSizeLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = self.backgroundColor
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .left
        label.textColor = UIColor.white
        return label
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        view.stopAnimating()
        return view
    }()
    
    // MARK: public
    var text: String {
        didSet {
            self.imageSizeLabel.text = text
        }
    }
    
    var selected: Bool {
        didSet {
            self.imageSizeLabel.isHidden = !selected
            if selected {
                self.imageView.image = UIImage(named: "photo_full_image_selected")
            } else {
                self.imageView.image = UIImage(named: "photo_full_image_unselected")
            }
        }
    }
    
    func addTarget(target: AnyObject?, action: Selector) {
        self.fullImageButton.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
    }
    
    func shouldAnimating(animated: Bool) {
        if selected {
            self.imageSizeLabel.isHidden = animated
            if animated {
                self.indicatorView.startAnimating()
            } else {
                self.indicatorView.stopAnimating()
            }
        }
    }
    
    // MARK: priviate
    
    private func setupView() {
        self.backgroundColor = UIColor.clear
        self.addSubview(fullImageButton)
        self.addSubview(imageView)
        self.addSubview(nameLabel)
        self.addSubview(imageSizeLabel)
        self.addSubview(indicatorView)
        self.imageView.image = UIImage(named: "photo_full_image_unselected")
        let viewBindingsDict = [
            "fullImageButton":fullImageButton,
            "imageView": imageView,
            "nameLabel": nameLabel,
            "imageSizeLabel": imageSizeLabel,
            "indicatorView": indicatorView
        ] as [String : Any]
        
        let btVflH = "H:|-0-[fullImageButton]-0-|"
        let btVflV = "V:|-0-[fullImageButton]-0-|"
        let vflH = "H:|-0-[imageView(20)]-5-[nameLabel(>=2)]-5-[imageSizeLabel(80)]"
        let constraintsVflH = NSLayoutConstraint.constraints(withVisualFormat: vflH, options: .alignAllCenterY, metrics: nil, views: viewBindingsDict)
        let btContstraintsH = NSLayoutConstraint.constraints(withVisualFormat: btVflH, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewBindingsDict)
        let btContstraintsV = NSLayoutConstraint.constraints(withVisualFormat: btVflV, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewBindingsDict)
        let imageCenter = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: fullImageButton, attribute: .centerY, multiplier: 1, constant: 0)
        let imageViewHeight = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: imageView, attribute: .width, multiplier: 1, constant: 0)
        let nameLabelHeight = NSLayoutConstraint(item: nameLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 30)
        let imageSizeLabelHeight = NSLayoutConstraint(item: imageSizeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 30)
        let indicatorViewWidth = NSLayoutConstraint(item: indicatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 26)
        let indicatorViewLeading = NSLayoutConstraint(item: indicatorView, attribute: .leading, relatedBy: .equal, toItem: imageSizeLabel, attribute: .leading, multiplier: 1, constant: 0)
        let indicatorViewCenterY = NSLayoutConstraint(item: indicatorView, attribute: .centerY, relatedBy: .equal, toItem: imageSizeLabel, attribute: .centerY, multiplier: 1, constant: 0)
        let indicatorViewHeight = NSLayoutConstraint(item: indicatorView, attribute: .height, relatedBy: .equal, toItem: indicatorView, attribute: .width, multiplier: 1, constant: 0)
        
        
        self.addConstraints(btContstraintsH)
        self.addConstraints(btContstraintsV)
        self.addConstraints(constraintsVflH)
        self.addConstraints([imageCenter, imageViewHeight, nameLabelHeight, imageSizeLabelHeight,indicatorViewCenterY,indicatorViewLeading,indicatorViewWidth,indicatorViewHeight])
    }
    
    // MARK: init
    override init(frame: CGRect) {
        self.selected = false
        self.text = ""
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.selected = false
        self.text = ""
        super.init(coder: aDecoder)
    }
}
