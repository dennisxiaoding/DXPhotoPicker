//
//  DXSendButton.swift
//  DXPhotosPickerDemo
//
//  Created by Ding Xiao on 15/10/14.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

class DXSendButton: UIView {
    
    struct DXSendButtonConfig {
        static let sendButtonTintNormalColor = "#1FB823"
        static let sendButtonTintHighlightedColor = "#C9EFCA"
        static let sendButtonTintDisabledColor = "#C9EFCA"
        static let sendButtonTextWitdh = 38.0
        static let commonSize = CGSizeMake(20, 30)
        static let sendButtonFont = UIFont.systemFontOfSize(15.0)
    }
    
    var badgeValue: String = "0" {
        didSet {
            self.badgeValueLabel.text = badgeValue;
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: public
    
    func addTarget(target: AnyObject?, action: Selector) {
        self.sendButton.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // MARK: lazy load
    
    private lazy var badgeValueLabel: UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.font = DXSendButtonConfig.sendButtonFont
        label.textAlignment = NSTextAlignment.Center
        return label
    }()
    
    private lazy var backGroudView: UIView = {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor(hexColor: DXSendButtonConfig.sendButtonTintNormalColor)
        view.layer.cornerRadius = DXSendButtonConfig.commonSize.width/2
        return view
    }()
    
    private lazy var sendButton: UIButton = {
       let button = UIButton(type: UIButtonType.Custom)
        button.setTitle(DXlocalizedString("send", comment: "发送"), forState: UIControlState.Normal)
        button.setTitleColor(UIColor(hexColor: DXSendButtonConfig.sendButtonTintNormalColor), forState: UIControlState.Normal)
        button.setTitleColor(UIColor(hexColor: DXSendButtonConfig.sendButtonTintHighlightedColor), forState: UIControlState.Highlighted)
        button.setTitleColor(UIColor(hexColor: DXSendButtonConfig.sendButtonTintDisabledColor), forState: UIControlState.Disabled)
        button.titleLabel?.font = DXSendButtonConfig.sendButtonFont
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0)
        button.backgroundColor = UIColor.clearColor()
        return button
    }()
}
