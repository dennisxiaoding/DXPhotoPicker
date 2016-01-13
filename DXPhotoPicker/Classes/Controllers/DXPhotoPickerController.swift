//
//  DXPhototPickerController.swift
//  DXPhotoPicker
//
//  Created by Ding Xiao on 15/10/13.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

@available(iOS 8.0, *)
@objc public protocol DXPhotoPickerControllerDelegate: NSObjectProtocol {
    /**
     seletced call back
     
     - parameter photosPicker: the photoPicker
     - parameter sendImages:   selected images
     - parameter isFullImage:  if the selected image is high quality
     */
    optional func photoPickerController(photoPicker: DXPhotoPickerController?, sendImages: [PHAsset]?, isFullImage: Bool)
    
    /**
     cancel selected
     */
    optional func photoPickerDidCancel(photoPicker: DXPhotoPickerController)
}

@available(iOS 8.0, *)
public class DXPhotoPickerController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    struct DXPhotoPickerConfig {
        /// set the max selected number
        static let maxSeletedNumber = 9
    }

    
    public weak var photoPickerDelegate: DXPhotoPickerControllerDelegate?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
        self.interactivePopGestureRecognizer?.enabled = true
        
        func showAlbumList() {
            let viewController = DXAlbumTableViewController()
            self.viewControllers = [viewController]
        }
        
        func showImageFlow() {
            let rootVC = DXAlbumTableViewController()
            let imageFlowVC = DXImageFlowViewController(identifier: DXPickerHelper.fetchAlbumIdentifier())
            self.viewControllers = [rootVC,imageFlowVC]
        }
        
        func chargeAuthorizationStatus(status: PHAuthorizationStatus) {
    
            let viewController = viewControllers.first as? DXAlbumTableViewController
            guard viewController != nil else {
                showAlbumList()
                return
            }
            switch (status) {
            case .Authorized:
                viewController!.reloadTableView()
            case .Denied:
                viewController!.showUnAuthorizedTipsView()
                break
            case .Restricted:
                viewController!.showUnAuthorizedTipsView()
                break
            case .NotDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                    guard status != .NotDetermined else {
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        chargeAuthorizationStatus(status)
                    })
                })
            }
            
        }
        
        if DXPickerHelper.fetchAlbumIdentifier() == nil {
            showAlbumList()
            chargeAuthorizationStatus(PHPhotoLibrary.authorizationStatus())
        } else {
            if DXPickerHelper.fetchAlbumIdentifier()!.isEmpty {
                showAlbumList()
                chargeAuthorizationStatus(PHPhotoLibrary.authorizationStatus())
            } else {
                showImageFlow()
            }
        }
    }
}
