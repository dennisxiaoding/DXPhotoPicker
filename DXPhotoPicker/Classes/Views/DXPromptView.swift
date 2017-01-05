//
//  DXPromptView.swift
//  DXPhotosPickerDemo
//
//  Created by DingXiao on 15/10/13.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

public class DXPromptView: UIWindow {

    convenience init(imageName: String?, message: String?) {
        self.init()
        self.isHidden = false
        self.alpha = 1.0
        self.windowLevel = UIWindowLevelStatusBar + 1.0
        self.backgroundColor = UIColor(red: 0x17/255.0, green: 0x17/255.0, blue: 0x17/255.0, alpha: 0.9)
        self.layer.masksToBounds = true
        let image = UIImage(named: imageName!)
        let imageView = UIImageView(image: image)
        self.addSubview(imageView)
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = message
        label.sizeToFit()
        self.addSubview(label)
    }
    
    public class func showWithImageName(imageName: String, message: String) {
        
    }

}
