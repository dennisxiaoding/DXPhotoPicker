//
//  DXFullImageButton.swift
//  DXPhotoPickerDemo
//
//  Created by DingXiao on 15/10/30.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

class DXFullImageButton: UIView {
// MARK: public
    var text: String {
        didSet {
            DXLog(text)
        }
    }
    
    var selected: Bool {
        didSet {
            
        }
    }
    
    func addTarget(target: AnyObject?, action: Selector) {
//        self.sendButton.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
    }
    
// MARK: init 
    override init(frame: CGRect) {
        selected = false
        text = ""
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
