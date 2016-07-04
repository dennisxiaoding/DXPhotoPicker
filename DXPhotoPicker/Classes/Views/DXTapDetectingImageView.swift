//
//  DXTapDetectingImageView.swift
//  DXPhotosPickerDemo
//  Inspired by MWTapDetectingImageView github:https://github.com/mwaterfall/MWPhotoBrowser
//  Created by Ding Xiao on 15/10/14.
//  Copyright © 2015年 Dennis. All rights reserved.
//
//  A swift version of MWTapDetectingImageView

import UIKit

@objc protocol DXTapDetectingImageViewDelegate: NSObjectProtocol {
    optional func imageView(imageView: DXTapDetectingImageView?, singleTapDetected touch: UITouch?)
    optional func imageView(imageView: DXTapDetectingImageView?, doubleTapDetected touch: UITouch?)
    optional func imageView(imageView: DXTapDetectingImageView?, tripleTapDetected touch: UITouch?)
}

class DXTapDetectingImageView: UIImageView, DXTapDetectingImageViewDelegate {
    
    weak var tapDelegate: DXTapDetectingImageViewDelegate?
    
    // MARK: initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.userInteractionEnabled = true
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.userInteractionEnabled = true
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        self.userInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: touch events
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        func handleSingleTap(touch: UITouch?) {
            tapDelegate?.imageView?(self, singleTapDetected: touch)
        }
        
        func handleDoubleTap(touch: UITouch?) {
            tapDelegate?.imageView?(self, doubleTapDetected: touch)
        }
        
        func handleTripleTap(touch: UITouch?) {
            tapDelegate?.imageView?(self, tripleTapDetected: touch)
        }
        
        let touch = touches.first
        let tapcount = touch?.tapCount
        switch(tapcount!) {
        case 1: handleSingleTap(touch)
        case 2: handleDoubleTap(touch)
        case 3: handleTripleTap(touch)
        default: break
        }
    }
}
