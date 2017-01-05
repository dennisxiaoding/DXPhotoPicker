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
        let lb = UILabel(frame: CGRect.zero)
        let text = DXlocalized(string: "UnAuthorizedTip", comment: "UnAuthorizedTip") as NSString
        let infoDic = Bundle.main.infoDictionary
        var displayName = infoDic!["CFBundleDisplayName"] as? NSString
        if displayName == nil {
            displayName = infoDic!["CFBundleName"] as? NSString
            if displayName == nil {
                displayName = ""
            }
        }
        let tipString = NSString(format: text, displayName!)
        lb.text = tipString as String
        lb.textColor = UIColor.black
        lb.font = UIFont.systemFont(ofSize: 14.0)
        lb.textAlignment = NSTextAlignment.center
        lb.numberOfLines = 0
        lb.backgroundColor = UIColor.clear
        lb.lineBreakMode = NSLineBreakMode.byTruncatingTail
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
        ] as [String : Any]
        let mertic = [
            "imageLength": 130,
            "labelHeight": 60
        ]
        let vflV = "V:|-120-[imageView(imageLength)]-30-[label(<=labelHeight@750)]"
        let vflH = "H:|-33-[label]-33-|"
        let contstraintsV: Array = NSLayoutConstraint.constraints(withVisualFormat: vflV,
            options: NSLayoutFormatOptions.alignAllCenterX,
            metrics: mertic,
            views: viewBindingsDict)
        let contstraintsH: Array = NSLayoutConstraint.constraints(withVisualFormat: vflH,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: mertic,
            views: viewBindingsDict)
        let imageViewConttraintsWidth = NSLayoutConstraint(item: imageView,
            attribute: NSLayoutAttribute.width,
            relatedBy: NSLayoutRelation.equal,
            toItem: nil,
            attribute: NSLayoutAttribute.notAnAttribute,
            multiplier: 0,
            constant: 130.0)
        self.addConstraints(contstraintsV)
        self.addConstraints(contstraintsH)
        self.addConstraint(imageViewConttraintsWidth)
    }
}
