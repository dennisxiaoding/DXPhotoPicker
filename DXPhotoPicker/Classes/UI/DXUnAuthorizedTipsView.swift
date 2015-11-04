//
//  DXUnAuthorizedTipsView.swift
//  DXPhotoPickerDemo
//
//  Created by DingXiao on 15/10/16.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

class DXUnAuthorizedTipsView: UIView {
    
    lazy var imageView: UIImageView! = {
        let imv = UIImageView(image: UIImage(named: "image_unAuthorized"))
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()
    
    lazy var label: UILabel! = {
        let lb = UILabel(frame: CGRectZero)
        let text = DXlocalizedString("UnAuthorizedTip", comment: "UnAuthorizedTip") as NSString
        let infoDic = NSBundle.mainBundle().infoDictionary
        var displayName = infoDic!["CFBundleDisplayName"] as? NSString
        if displayName == nil {
            displayName = infoDic!["CFBundleName"] as? NSString
            if displayName == nil {
                displayName = ""
            }
        }
        let tipString = NSString(format: text, displayName!)
        lb.text = tipString as String
        lb.textColor = UIColor.blackColor()
        lb.font = UIFont.systemFontOfSize(14.0)
        lb.textAlignment = NSTextAlignment.Center
        lb.numberOfLines = 0
        lb.backgroundColor = UIColor.clearColor()
        lb.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        addSubview(imageView)
        addSubview(label)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        let viewBindingsDict = [
            "label": label,
            "imageView": imageView
        ]
        let mertic = [
            "imageLength": 130,
            "labelHeight": 60
        ]
        let vflV = "V:|-120-[imageView(imageLength)]-30-[label(<=labelHeight@750)]"
        let vflH = "H:|-33-[label]-33-|"
        let contstraintsV: Array = NSLayoutConstraint.constraintsWithVisualFormat(vflV,
            options: NSLayoutFormatOptions.AlignAllCenterX,
            metrics: mertic,
            views: viewBindingsDict)
        let contstraintsH: Array = NSLayoutConstraint.constraintsWithVisualFormat(vflH,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: mertic,
            views: viewBindingsDict)
        let imageViewConttraintsWidth = NSLayoutConstraint(item: imageView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 0,
            constant: 130.0)
        self.addConstraints(contstraintsV)
        self.addConstraints(contstraintsH)
        self.addConstraint(imageViewConttraintsWidth)
    }
}
