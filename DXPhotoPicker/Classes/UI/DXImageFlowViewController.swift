//
//  DXImageFlowViewController.swift
//  DXPhotoPickerDemo
//
//  Created by Ding Xiao on 15/10/23.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

class DXImageFlowViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DXPhotoBroswerDelegate {
    
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
            title = self.currentAlbum.name
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
                    let indexPath = NSIndexPath(forRow: self.assetsArray.count-1, inSection: 0);
                    self.imageFlowCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false);
                }
            }
        }
        setupView()
        setUpData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbarHidden = false
        imageFlowCollectionView.reloadData()
        sendButton.badgeValue = "\(selectedAssetsArray.count)"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.toolbarHidden = true
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
    
    @objc private func previewAction() {
        browserPhotoAsstes(selectedAssetsArray, pageIndex: 0)
    }
    
// MARK: priviate 
    
    private func browserPhotoAsstes(assets: [PHAsset], pageIndex: Int) {
        let browser = DXPhotoBrowser(photosArray: assets, currentIndex: pageIndex, isFullImage: isFullImage)
        browser.delegate = self
        browser.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(browser, animated: true)
    }
    
// MARK: DXPhotoBroswerDelegate
    
    func sendImagesFromPhotoBrowser(photoBrowser: DXPhotoBrowser, currentAsset: PHAsset) {
    // TODO:  seleted images action
    }
    
    func seletedPhotosNumberInPhotoBrowser(photoBrowser: DXPhotoBrowser) -> Int {
        return selectedAssetsArray.count
    }
    
    func photoBrowser(photoBrowser: DXPhotoBrowser, currentPhotoAssetIsSeleted asset: PHAsset) -> Bool {
        return selectedAssetsArray.contains(asset)
    }
    
    func photoBrowser(photoBrowser: DXPhotoBrowser, seletedAsset asset: PHAsset) -> Bool {
        if selectedAssetsArray.count >= DXPhotoBrowser.DXPhotoBrowserConfig.maxSeletedNumber {
            // TODO: show tips
            return false
        }
        selectedAssetsArray.append(asset)
        return true
    }
    
    func photoBrowser(photoBrowser: DXPhotoBrowser, deseletedAsset asset: PHAsset) {
        let index = selectedAssetsArray.indexOf(asset)
        guard index != nil else {
            return;
        }
        selectedAssetsArray.removeAtIndex(index!)
    }
    
    func photoBrowser(photoBrowser: DXPhotoBrowser, seleteFullImage fullImage: Bool) {
        isFullImage = fullImage
    }

    
// MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DXImageFlowConfig.dxAssetCellReuseIdentifier, forIndexPath: indexPath) as! DXAssetCell
        cell.fillWithAsset(assetsArray[indexPath.row], isAssetSelected: selectedAssetsArray.contains(assetsArray[indexPath.row]))
        cell.selectItemBlock {[unowned self] (selected, asset) -> Bool in
            if selected == true {
                guard self.selectedAssetsArray.count < DXPhotoBrowser.DXPhotoBrowserConfig.maxSeletedNumber else {
                    return false
                }
                if self.selectedAssetsArray.contains(asset) == false {
                    self.selectedAssetsArray.append(asset);
                    self.sendButton.badgeValue = "\(self.selectedAssetsArray.count)"
                    return true
                }
                return false
            } else {
                if self.selectedAssetsArray.contains(asset) == true {
                    let index = self.selectedAssetsArray.indexOf(asset)
                    self.selectedAssetsArray.removeAtIndex(index!)
                     self.sendButton.badgeValue = "\(self.selectedAssetsArray.count)"
                }
                return false
            }
        }
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
        browserPhotoAsstes(assetsArray, pageIndex: indexPath.row)
    }
}
