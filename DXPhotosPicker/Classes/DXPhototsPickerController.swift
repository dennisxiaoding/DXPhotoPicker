//
//  DXPhototsPickerController.swift
//  DXPhotosPicker
//
//  Created by Ding Xiao on 15/10/13.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

@available(iOS 8.0, *)
@objc public protocol DXPhototsPickerControllerDelegate: NSObjectProtocol {
    optional func photosPickerController(photosPicker: DXPhototsPickerController?, sendImages: [AnyObject]?, isFullImage: Bool)
}

@available(iOS 8.0, *)
public class DXPhototsPickerController: UINavigationController {

    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
