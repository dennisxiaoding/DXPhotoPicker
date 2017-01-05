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
        static let commonSize = CGSize(width: 20, height: 20)
        static let sendButtonFont = UIFont.systemFont(ofSize: 15.0)
    }
    
    var badgeValue: String = "0" {
        didSet {
            
            func showBadgeValue() {
                self.badgeValueLabel.isHidden = false
                self.backGroudView.isHidden = false
                self.sendButton.isEnabled = true
            }
            
            func hideBadgeValue() {
                self.badgeValueLabel.isHidden = true
                self.backGroudView.isHidden = true
                self.sendButton.isEnabled = false
            }
            
            let str = badgeValue as NSString
            let rect = str.boundingRect(with: CGSize(width: 100, height: 20),
                                        options: .truncatesLastVisibleLine,
                                        attributes: [NSFontAttributeName:DXSendButtonConfig.sendButtonFont],
                                        context: nil)
            self.badgeValueLabel.dx_width = (rect.size.width + 9) > 20 ? (rect.size.width + 9) : 20
            self.badgeValueLabel.dx_height = 20
            self.sendButton.dx_width = self.badgeValueLabel.dx_width + DXSendButtonConfig.sendButtonTextWitdh
            self.dx_width = self.sendButton.dx_width
            self.badgeValueLabel.text = badgeValue;
            
            if str.integerValue > 0 {
                showBadgeValue()
                self.backGroudView.transform = CGAffineTransform(scaleX: 0, y: 0);
                UIView.animate(withDuration: 0.2, animations: { [unowned self]() -> Void in
                    self.backGroudView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    }, completion: { [unowned self] (completed) -> Void in
                        self.backGroudView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    })
            } else {
                hideBadgeValue()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: 56, height: 26)
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
        self.sendButton.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
    }
    
    // MARK: lazy load
    
    private lazy var badgeValueLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        label.dx_centerY = self.dx_centerY
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = DXSendButtonConfig.sendButtonFont
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    private lazy var backGroudView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.dx_centerY = self.dx_centerY
        view.backgroundColor = UIColor(hexColor: DXSendButtonConfig.sendButtonTintNormalColor)
        view.layer.cornerRadius = DXSendButtonConfig.commonSize.width/2
        return view
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.frame = self.bounds
        button.setTitle(DXlocalized(string: "send", comment: "发送"), for: UIControlState.normal)
        button.setTitleColor(UIColor(hexColor: DXSendButtonConfig.sendButtonTintNormalColor), for: UIControlState.normal)
        button.setTitleColor(UIColor(hexColor: DXSendButtonConfig.sendButtonTintHighlightedColor), for: UIControlState.highlighted)
        button.setTitleColor(UIColor(hexColor: DXSendButtonConfig.sendButtonTintDisabledColor), for: UIControlState.disabled)
        button.titleLabel?.font = DXSendButtonConfig.sendButtonFont
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0)
        button.backgroundColor = UIColor.clear
        return button
    }()
}
