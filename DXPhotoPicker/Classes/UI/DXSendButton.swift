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
        static let sendButtonTintDisabledColor = "#C9EFCB"
        static let sendButtonTextWitdh: CGFloat = 38.0
        static let commonSize = CGSizeMake(20, 20)
        static let sendButtonFont = UIFont.systemFontOfSize(15.0)
    }
    
    var badgeValue: String = "0" {
        didSet {
            
            func showBadgeValue() {
                self.badgeValueLabel.hidden = false
                self.backGroudView.hidden = false
                self.sendButton.enabled = true
            }
            
            func hideBadgeValue() {
                self.badgeValueLabel.hidden = true
                self.backGroudView.hidden = true
                self.sendButton.enabled = false
            }
            
            let str = badgeValue as NSString
            let rect = str.boundingRectWithSize(CGSizeMake(100, 20), options: .TruncatesLastVisibleLine, attributes: [NSFontAttributeName:DXSendButtonConfig.sendButtonFont], context: nil)
            self.badgeValueLabel.dx_width = (rect.size.width + 9) > 20 ? (rect.size.width + 9) : 20
            self.badgeValueLabel.dx_height = 20
            self.sendButton.dx_width = self.badgeValueLabel.dx_width + DXSendButtonConfig.sendButtonTextWitdh
            self.dx_width = self.sendButton.dx_width
            self.badgeValueLabel.text = badgeValue;
            
            if str.integerValue > 0 {
                showBadgeValue()
                self.backGroudView.transform = CGAffineTransformMakeScale(0, 0);
                UIView.animateWithDuration(0.2, animations: { [unowned self]() -> Void in
                    self.backGroudView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                    }, completion: { [unowned self] (completed) -> Void in
                        self.backGroudView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                })
            } else {
                hideBadgeValue()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRectMake(0, 0, 56, 26)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(backGroudView)
        addSubview(badgeValueLabel)
        addSubview(sendButton)
        self.badgeValue = "0"
    }
    
    // MARK: public
    
    func addTarget(target: AnyObject?, action: Selector) {
        self.sendButton.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // MARK: lazy load
    
    private lazy var badgeValueLabel: UILabel = {
        let label = UILabel(frame: CGRectMake(0, 0, 20, 20))
        label.dx_centerY = self.dx_centerY
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.whiteColor()
        label.font = DXSendButtonConfig.sendButtonFont
        label.textAlignment = NSTextAlignment.Center
        return label
    }()
    
    private lazy var backGroudView: UIView = {
        let view = UIView(frame: CGRectMake(0, 0, 20, 20))
        view.dx_centerY = self.dx_centerY
        view.backgroundColor = UIColor(hexColor: DXSendButtonConfig.sendButtonTintNormalColor)
        view.layer.cornerRadius = DXSendButtonConfig.commonSize.width/2
        return view
    }()
    
    private lazy var sendButton: UIButton = {
       let button = UIButton(type: UIButtonType.Custom)
        button.frame = self.bounds
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
