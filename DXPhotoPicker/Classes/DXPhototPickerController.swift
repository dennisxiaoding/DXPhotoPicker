//
//  DXPhototPickerController.swift
//  DXPhotoPicker
//
//  Created by Ding Xiao on 15/10/13.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

public enum DXPhototPickerMediaType: Int {
    case Unknow
    case Image
    case Video
    case All
}

@available(iOS 8.0, *)
@objc protocol DXPhototPickerControllerDelegate: NSObjectProtocol {
    optional func photoPickerController(photosPicker: DXPhototPickerController?, sendImages: [AnyObject]?, isFullImage: Bool)
}

@available(iOS 8.0, *)
public class DXPhototPickerController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    var isDuringPushAnimating = false
    private weak var navDelegate: UINavigationControllerDelegate?
//    private lazy var defaultAblumName: String? = {
//        let string = NSUserDefaults.standardUserDefaults().objectForKey(<#T##defaultName: String##String#>)
//    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
        self.interactivePopGestureRecognizer?.enabled = true
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
