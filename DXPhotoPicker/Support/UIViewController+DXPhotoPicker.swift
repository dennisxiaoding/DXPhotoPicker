//
//  UIViewController+DXPhotoPicker.swift
//  DXPhotoPickerDemo
//
//  Created by DingXiao on 15/10/22.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

public enum DXPhotoPickerNavigationBarPosition: Int {
    case Left
    case Right
}

public extension UIViewController {
    
    public func createBarButtonItemAtPosition(
        position: DXPhotoPickerNavigationBarPosition,
        normalImage: UIImage?,
        highlightImage: UIImage?,
        action: Selector
        ) {
            let button = UIButton(type: .Custom)
            var insets = UIEdgeInsetsZero
            switch position {
            case .Left :
                insets = UIEdgeInsetsMake(0, -20, 0, 20)
            case .Right :
                insets = UIEdgeInsetsMake(0, 13, 0, -13)
            }
            button.imageEdgeInsets = insets
            button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
            button.frame = CGRectMake(0, 0, 44, 44)
            button.setImage(normalImage, forState: .Normal)
            button.setImage(highlightImage, forState: .Highlighted)
            
            let barButtonItem = UIBarButtonItem(customView: button)
            switch position {
            case .Left:
                self.navigationItem.leftBarButtonItem = barButtonItem
            case .Right:
                self.navigationItem.rightBarButtonItem = barButtonItem
            }
    }
    
    public func createBarButtonItemAtPosition(
        position: DXPhotoPickerNavigationBarPosition,
        text: String,
        action: Selector
        ) {
            let button = UIButton(type: .Custom)
            var insets = UIEdgeInsetsZero
            switch position {
            case .Left :
                insets = UIEdgeInsetsMake(0, -49+26, 0, 19)
            case .Right :
                insets = UIEdgeInsetsMake(0, 49-26, 0, -19)
            }
            button.imageEdgeInsets = insets
            button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
            button.frame = CGRectMake(0, 0, 64, 30)
            button.setTitle(text, forState: .Normal)
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
            button.setTitleColor(UIColor(hexColor: "808080"), forState: .Highlighted)
            button.setTitleColor(UIColor.grayColor(), forState: .Normal)

            let barButtonItem = UIBarButtonItem(customView: button)
            switch position {
            case .Left:
                self.navigationItem.leftBarButtonItem = barButtonItem
            case .Right:
                let item = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
                item.width = -10
                self.navigationItem.rightBarButtonItems = [item ,barButtonItem]
            }
    }

    public func createBackBarButtonItemStatusNormalImage(
        normalImage: UIImage,
        highlightImage: UIImage,
        backTitle: String,
        action: Selector
        ) {
            let button = UIButton(type: .Custom)
            button.frame = CGRectMake(0, 0, 84, 44)
            button.setTitleColor(UIColor(hexColor: "808080"), forState: .Highlighted)
            button.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            button.setTitle(backTitle, forState: .Normal)
            button.setTitle(backTitle, forState: .Highlighted)
            button.setImage(normalImage, forState: .Normal)
            button.setImage(highlightImage, forState: .Highlighted)
            let imageInset = UIEdgeInsetsMake(0, -20, 0, 60)
            let titleInset = UIEdgeInsetsMake(0, -45, 0, -15)
            button.imageEdgeInsets = imageInset
            button.titleEdgeInsets = titleInset
            button.addTarget(self, action: action, forControlEvents: .TouchUpInside)
            button.frame = CGRectMake(0, 0, 64, 30)
            button.titleLabel?.font = UIFont.systemFontOfSize(15)
            button.contentHorizontalAlignment = .Left
            
            let barButtonItem = UIBarButtonItem(customView: button)
            self.navigationItem.leftBarButtonItem = barButtonItem
    }
    
}