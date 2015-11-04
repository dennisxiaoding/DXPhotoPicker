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
@objc public protocol DXPhototPickerControllerDelegate: NSObjectProtocol {
    optional func photoPickerController(photosPicker: DXPhototPickerController?, sendImages: [PHAsset]?, isFullImage: Bool)
    optional func photoPickerDidCancel(photoPicker: DXPhototPickerController)
}

@available(iOS 8.0, *)
public class DXPhototPickerController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    public weak var photoPickerDelegate: DXPhototPickerControllerDelegate?
    
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
            let imageFlowVC = DXImageFlowViewController(identifier: DXPickerManager.sharedManager.defultAlbumIdentifier)
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
        
        if DXPickerManager.sharedManager.defultAlbumIdentifier == nil {
            showAlbumList()
            chargeAuthorizationStatus(PHPhotoLibrary.authorizationStatus())
        } else {
            if DXPickerManager.sharedManager.defultAlbumIdentifier!.isEmpty {
                showAlbumList()
                chargeAuthorizationStatus(PHPhotoLibrary.authorizationStatus())
            } else {
                showImageFlow()
            }
        }
        
        
    }
}
