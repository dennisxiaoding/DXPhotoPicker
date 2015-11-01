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
        static let buttonPadding: CGFloat = 10
        static let buttonImageWidth: CGFloat = 16
        static let buttonFont = UIFont.systemFontOfSize(13)
    }
    
    // MARK: lazy load property
    
    private lazy var fullImageButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.dx_width = self.fullImageButtonWidth()
        button.dx_height = 28
        button.backgroundColor = self.backgroundColor
        button.setTitle(DXlocalizedString("fullImage", comment: "原图"), forState: .Normal)
        button.titleLabel?.font = DXFullImageButtonParam.buttonFont
        button.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        button.setImage(UIImage(named: "photo_full_image_unselected"), forState: .Normal)
        button.setImage(UIImage(named: "photo_full_image_selected"), forState: .Selected)
        button.contentVerticalAlignment = .Bottom
        button.titleEdgeInsets = UIEdgeInsetsMake(0 ,DXFullImageButtonParam.buttonPadding - DXFullImageButtonParam.buttonImageWidth, 6, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(6, 0, 6, self.fullImageButtonWidth() - DXFullImageButtonParam.buttonImageWidth)
        return button
    }()
    
    private lazy var imageSizeLabel: UILabel = {
        let label = UILabel(frame: CGRectMake(100,4,self.dx_width-100,20))
        label.backgroundColor = self.backgroundColor
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = .Left
        label.textColor = UIColor.whiteColor()
        return label
    }()
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(frame: CGRectMake(self.fullImageButton.dx_width,2,26,26))
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
            fullImageButton.selected = selected
            fullImageButton.dx_width = fullImageButtonWidth()
            fullImageButton.titleEdgeInsets = UIEdgeInsetsMake(0, DXFullImageButtonParam.buttonPadding - DXFullImageButtonParam.buttonImageWidth, 6, 0)
            fullImageButton.imageEdgeInsets = UIEdgeInsetsMake(6, 0, 6, fullImageButton.dx_width - DXFullImageButtonParam.buttonImageWidth)
            imageSizeLabel.dx_left = fullImageButton.dx_width
            imageSizeLabel.dx_width = self.dx_width - fullImageButton.dx_width
            imageSizeLabel.hidden = !selected
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
        self.dx_height = 28
        self.dx_width = CGRectGetWidth(UIScreen.mainScreen().bounds)/2 - 20
        addSubview(fullImageButton)
        addSubview(imageSizeLabel)
        addSubview(indicatorView)
    }
    
    private func fullImageButtonWidth() -> CGFloat {
        let string = DXlocalizedString("fullImage", comment: "原图") as NSString
        let rect = string.boundingRectWithSize(
            CGSizeMake(200, 20),
            options: .TruncatesLastVisibleLine,
            attributes: [NSFontAttributeName: DXFullImageButtonParam.buttonFont],
            context: nil
        )
        return CGRectGetWidth(rect)
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
        fatalError("init(coder:) has not been implemented")
    }
}
