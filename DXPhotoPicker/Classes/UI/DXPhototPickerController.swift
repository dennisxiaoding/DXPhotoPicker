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
@objc public protocol DXPhototPickerControllerDelegate: NSObjectProtocol {
    optional func photoPickerController(photosPicker: DXPhototPickerController?, sendImages: [AnyObject]?, isFullImage: Bool)
    optional func photoPickerDidCancel(photoPicker: DXPhototPickerController)
}

@available(iOS 8.0, *)
public class DXPhototPickerController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    public weak var photoPickerDelegate: DXPhototPickerControllerDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
        self.interactivePopGestureRecognizer?.enabled = true
           DXLog("\(PHPhotoLibrary.authorizationStatus()) !")
        
        if DXPickerManager.sharedManager.defultAlbum == nil {
            showAlbumList()
        }
    }

    private func showAlbumList() {
        let viewController = DXAlbumTableViewController()
        self.viewControllers = [viewController]
    }
}
