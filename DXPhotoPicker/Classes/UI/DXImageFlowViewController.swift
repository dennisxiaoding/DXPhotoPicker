//
//  DXImageFlowViewController.swift
//  DXPhotoPickerDemo
//
//  Created by Ding Xiao on 15/10/23.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

class DXImageFlowViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    struct DXImageFlowConfig {
        static let dxAssetCellReuseIdentifier = "dxAssetCellReuseIdentifier"
        static let kThumbSizeLength = (UIScreen.mainScreen().bounds.size.width-10)/4
    }
    
    
    private var currentAlbum: DXAlbum
    private var assetsArray: [PHAsset]
    private var selectedAssetsArray: [PHAsset]
    private var isFullImage = false
    
    private lazy var imageFlowCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 2.0
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.scrollDirection = .Vertical;
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(DXAssetCell.self, forCellWithReuseIdentifier: DXImageFlowConfig.dxAssetCellReuseIdentifier)
        return collectionView;
    }()
    private lazy var sendButton: DXSendButton = {
        let button = DXSendButton(frame: CGRectZero)
        return button
    }()
    
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
            self.title = self.currentAlbum.name
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
            let item3 = UIBarButtonItem(customView: self.sendButton)
            let item4 = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
            item4.width = -10
            setToolbarItems([item1,item2,item3,item4], animated: false)
            self.view.addSubview(imageFlowCollectionView)
            let viewBindDic = ["imageFlowCollectionView":imageFlowCollectionView]
            let vflH = "H:|-0-[imageFlowCollectionView]-0-|"
            let vflV = "V:|-0-[imageFlowCollectionView]-0-|"
            let contraintsH = NSLayoutConstraint.constraintsWithVisualFormat(vflH, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewBindDic)
            let contraintsV = NSLayoutConstraint.constraintsWithVisualFormat(vflV, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewBindDic)
            self.view.addConstraints(contraintsH)
            self.view.addConstraints(contraintsV)
            
        }
        
        func setUpData() {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                [unowned self] in
                self.assetsArray = DXPickerManager.sharedManager.fetchImageAssetsViaCollectionResults(self.currentAlbum.results)
                dispatch_async(dispatch_get_main_queue()) {
                    [unowned self] in
                    self.imageFlowCollectionView.reloadData()
                }
            }
            
        }
        setupView()
        setUpData()
    }

// MARK: button actons
    @objc private func backButtonAction() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @objc private func cancelAction() {
        let navController = navigationController as? DXPhototPickerController
        if (navController != nil && navController!.photoPickerDelegate!.respondsToSelector("photoPickerDidCancel:")) {
            navController!.photoPickerDelegate!.photoPickerDidCancel!(navController!)
        }
    }
    
// MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DXImageFlowConfig.dxAssetCellReuseIdentifier, forIndexPath: indexPath) as! DXAssetCell
        cell.fillWithAsset(assetsArray[indexPath.row], isAssetSelected: false)
       return cell
    }
    
// MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(DXImageFlowConfig.kThumbSizeLength, DXImageFlowConfig.kThumbSizeLength)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(2, 2, 2, 2)
    }

// MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        DXLog("\(indexPath)")
    }
}
