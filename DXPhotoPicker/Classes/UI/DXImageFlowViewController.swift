//
//  DXImageFlowViewController.swift
//  DXPhotoPickerDemo
//
//  Created by Ding Xiao on 15/10/23.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

class DXImageFlowViewController: UIViewController {
    
    private var currentAlbum: DXAlbum
    private var assetsArray: [PHAsset]
    private var selectedAssetsArray: [PHAsset]
    private var isFullImage = false
    
    private var imageFlowCollectionView: UICollectionView?
    private var sendButton: DXSendButton?
    
// MARK: Initializers
    init(album: DXAlbum) {
        currentAlbum = album
        assetsArray = []
        selectedAssetsArray = []
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        currentAlbum = DXAlbum()
        assetsArray = []
        selectedAssetsArray = []
        super.init(coder: aDecoder)
    }

// MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func setupView() {
            view.backgroundColor = UIColor.whiteColor()
            createBarButtonItemAtPosition(
                .Left,
                normalImage: UIImage(named: "back_normal"),
                highlightImage: UIImage(named: "back_highlight"),
                action: Selector("backButtonAction")
            )
            createBarButtonItemAtPosition(
                .Right,
                text: DXlocalizedString("cancel", comment: "取消"),
                action: Selector("cancelAction")
            )
            
            let item1 = UIBarButtonItem(
                title: DXlocalizedString("preview", comment: "预览"),
                style: .Plain,
                target: self,
                action: Selector("previewAction")
            )
            let item2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let item3 = UIBarButtonItem(customView: self.sendButton!)
            let item4 = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
            item4.width = -10
            setToolbarItems([item1,item2,item3,item4], animated: false)
        }
        
        func setUpData() {
            assetsArray = DXPickerManaher.sharedManager
        }
    }

// MARK: button actons
    private func backButtonAction() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func cancelAction() {
        let navController = navigationController as? DXPhototPickerController
        if (navController != nil && navController!.photoPickerDelegate!.respondsToSelector("photoPickerDidCancel:")) {
            navController!.photoPickerDelegate!.photoPickerDidCancel!(navController!)
        }
    }
}
