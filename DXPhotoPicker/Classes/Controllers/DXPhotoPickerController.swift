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
    @objc optional func photoPickerController(photoPicker: DXPhotoPickerController?, sendImages: [PHAsset]?, isFullImage: Bool)
    
    /**
     cancel selected
     */
    @objc optional func photoPickerDidCancel(photoPicker: DXPhotoPickerController)
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
        self.interactivePopGestureRecognizer?.isEnabled = true
        
        func showAlbumList() {
            let viewController = DXAlbumTableViewController()
            self.viewControllers = [viewController]
        }
        
        func showImageFlow() {
            let rootVC = DXAlbumTableViewController()
            let imageFlowVC = DXImageFlowViewController(identifier: DXPickerHelper.fetchAlbumIdentifier())
            self.viewControllers = [rootVC,imageFlowVC]
        }
        
        func chargeAuthorization(status: PHAuthorizationStatus) {
    
            let viewController = viewControllers.first as? DXAlbumTableViewController
            guard viewController != nil else {
                showAlbumList()
                return
            }
            switch (status) {
            case .authorized:
                DispatchQueue.main.async {
                    viewController!.reloadTableView()
                }
                
            case .denied:
                DispatchQueue.main.async {
                    viewController!.showUnAuthorizedTipsView()
                }
                
            case .restricted:
                DispatchQueue.main.async {
                    viewController!.showUnAuthorizedTipsView()
                }

            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                    guard status != .notDetermined else {
                        return
                    }
                    DispatchQueue.main.async{ () -> Void in
                        chargeAuthorization(status: status)
                    }
                })
            }
            
        }
        
        if DXPickerHelper.fetchAlbumIdentifier() == nil {
            showAlbumList()
            chargeAuthorization(status: PHPhotoLibrary.authorizationStatus())
        } else {
            if DXPickerHelper.fetchAlbumIdentifier()!.isEmpty {
                showAlbumList()
                chargeAuthorization(status: PHPhotoLibrary.authorizationStatus())
            } else {
                showImageFlow()
            }
        }
    }
}
