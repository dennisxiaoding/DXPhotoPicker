//
//  DXPhototPickerController.swift
//  DXPhotoPicker
//
//  Created by Ding Xiao on 15/10/13.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
@objc protocol DXPhototPickerControllerDelegate: NSObjectProtocol {
    optional func photoPickerController(photosPicker: DXPhototPickerController?, sendImages: [AnyObject]?, isFullImage: Bool)
}

@available(iOS 8.0, *)
public class DXPhototPickerController: UINavigationController, UINavigationControllerDelegate {

    var isDuringPushAnimating = false
    private weak var navDelegate: UINavigationControllerDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UINavigationControllerDelegate
    override weak public var delegate: UINavigationControllerDelegate? {
        didSet {
//            self.navDelegate = (delegate! != self ? delegate : nil)
        }
    }
    
}
