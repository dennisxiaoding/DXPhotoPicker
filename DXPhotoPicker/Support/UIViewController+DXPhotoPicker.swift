//
//  UIViewController+DXPhotoPicker.swift
//  DXPhotoPickerDemo
//
//  Created by DingXiao on 15/10/22.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

public enum DXPhotoPickerNavigationBarPosition: Int {
    case left
    case right
}

public extension UIViewController {
    
    public func createBarButtonItemAt(
        position: DXPhotoPickerNavigationBarPosition,
        normalImage: UIImage?,
        highlightImage: UIImage?,
        action: Selector) {
            let button = UIButton(type: .custom)
            var insets = UIEdgeInsets.zero
            switch position {
            case .left :
                insets = UIEdgeInsetsMake(0, -20, 0, 20)
            case .right :
                insets = UIEdgeInsetsMake(0, 13, 0, -13)
            }
            button.imageEdgeInsets = insets
            button.addTarget(self, action: action, for: .touchUpInside)
            button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            button.setImage(normalImage, for: .normal)
            button.setImage(highlightImage, for: .highlighted)
            
            let barButtonItem = UIBarButtonItem(customView: button)
            switch position {
            case .left:
                self.navigationItem.leftBarButtonItem = barButtonItem
            case .right:
                self.navigationItem.rightBarButtonItem = barButtonItem
            }
    }
    
    public func createBarButtonItemAt(
        position: DXPhotoPickerNavigationBarPosition,
        text: String,
        action: Selector
        ) {
            let button = UIButton(type: .custom)
            var insets = UIEdgeInsets.zero
            switch position {
            case .left :
                insets = UIEdgeInsetsMake(0, -49+26, 0, 19)
            case .right :
                insets = UIEdgeInsetsMake(0, 49-26, 0, -19)
            }
            button.imageEdgeInsets = insets
            button.addTarget(self, action: action, for: .touchUpInside)
            button.frame = CGRect(x: 0, y: 0, width: 64, height: 30)
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitleColor(UIColor(hexColor: "808080"), for: .highlighted)
            button.setTitleColor(UIColor.gray, for: .normal)

            let barButtonItem = UIBarButtonItem(customView: button)
            switch position {
            case .left:
                self.navigationItem.leftBarButtonItem = barButtonItem
            case .right:
                let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                item.width = -10
                self.navigationItem.rightBarButtonItems = [item ,barButtonItem]
            }
    }

    public func createBackBarButtonItem(
        normalImage: UIImage,
        highlightImage: UIImage,
        backTitle: String,
        action: Selector
        ) {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 84, height: 44)
            button.setTitleColor(UIColor(hexColor: "808080"), for: .highlighted)
            button.setTitleColor(UIColor.lightGray, for: .normal)
            button.setTitle(backTitle, for: .normal)
            button.setTitle(backTitle, for: .highlighted)
            button.setImage(normalImage, for: .normal)
            button.setImage(highlightImage, for: .highlighted)
            let imageInset = UIEdgeInsetsMake(0, -20, 0, 60)
            let titleInset = UIEdgeInsetsMake(0, -45, 0, -15)
            button.imageEdgeInsets = imageInset
            button.titleEdgeInsets = titleInset
            button.addTarget(self, action: action, for: .touchUpInside)
            button.frame = CGRect(x: 0, y: 0, width: 64, height: 30)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.contentHorizontalAlignment = .left
            
            let barButtonItem = UIBarButtonItem(customView: button)
            self.navigationItem.leftBarButtonItem = barButtonItem
    }
    
    @discardableResult
    public func pop(animated: Bool) -> UIViewController? {
        return self.navigationController?.popViewController(animated: animated)
    }
    
    @discardableResult
    public func popToRoot(animated: Bool) -> [UIViewController]? {
        return self.navigationController?.popToRootViewController(animated: animated);
    }
}

