//
//  DXImageFlowViewController.swift
//  DXPhotoPickerDemo
//
//  Created by Ding Xiao on 15/10/23.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

class DXImageFlowViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DXPhotoBroswerDelegate {
    
    struct DXImageFlowConfig {
        static let dxAssetCellReuseIdentifier = "dxAssetCellReuseIdentifier"
        static let kThumbSizeLength = (UIScreen.mainScreen().bounds.size.width-10)/4
    }
    
    private var currentAlbum: DXAlbum?
    private var albumIdentifier: String?
    private var assetsArray: [PHAsset]
    private var selectedAssetsArray: [PHAsset]
    private var isFullImage = false
    private var imageManager: PHCachingImageManager?
    private var previousPreheatRect: CGRect = CGRectZero
    
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
        button.addTarget(self, action: #selector(DXImageFlowViewController.sendImage))
        return button
    }()
    
    // MARK: Initializers
    
    init(album: DXAlbum?) {
        currentAlbum = album
        assetsArray = []
        selectedAssetsArray = []
        super.init(nibName: nil, bundle: nil)
    }
    
    init(identifier: String?){
        albumIdentifier = identifier
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
    
    deinit {
        resetCachedAssets()
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
                action: #selector(DXImageFlowViewController.backButtonAction)
            )
            createBarButtonItemAtPosition(
                .Right,
                text: DXlocalizedString("cancel", comment: "取消"),
                action: #selector(DXImageFlowViewController.cancelAction)
            )
            
            let item1 = UIBarButtonItem(
                title: DXlocalizedString("preview", comment: "预览"),
                style: .Plain,
                target: self,
                action: #selector(DXImageFlowViewController.previewAction)
            )
            item1.tintColor = UIColor.blackColor()
            item1.enabled = false
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
            if currentAlbum == nil && albumIdentifier != nil {
                currentAlbum = DXPickerHelper.fetchAlbum()
            }
            title = currentAlbum?.name
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                [unowned self] in
                self.assetsArray = DXPickerHelper.fetchImageAssetsViaCollectionResults(self.currentAlbum!.results)
                dispatch_async(dispatch_get_main_queue()) {
                    [unowned self] in

                    self.imageManager = PHCachingImageManager()
                    self.imageFlowCollectionView.reloadData()
                    let item = self.imageFlowCollectionView.numberOfItemsInSection(0)
                    guard item != 0 else {
                        return
                    }
                    let lastItemIndex = NSIndexPath(forItem: item-1, inSection: 0)
                    self.imageFlowCollectionView.scrollToItemAtIndexPath(lastItemIndex, atScrollPosition: .Bottom, animated: false)
                }
            }
        }
        setupView()
        setUpData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbarHidden = false
        sendButton.badgeValue = "\(selectedAssetsArray.count)"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.toolbarHidden = true
        super.viewWillDisappear(animated)
    }
    
    // MARK: button actons
    
    @objc private func sendImage() {
        
        let photoPicker = navigationController as? DXPhotoPickerController
        guard (photoPicker != nil ) else {
            return
        }
        DXPickerHelper.saveIdentifier(currentAlbum?.identifier)
        DXLog(currentAlbum?.identifier)
        photoPicker!.photoPickerDelegate?.photoPickerController?(photoPicker, sendImages: selectedAssetsArray, isFullImage: isFullImage)
    }
    
    @objc private func backButtonAction() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @objc private func cancelAction() {
        let navController = navigationController as? DXPhotoPickerController
        navController?.photoPickerDelegate?.photoPickerDidCancel?(navController!)
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
    
    private func addAsset(asset: PHAsset) -> Bool {
        if selectedAssetsArray.count >= DXPhotoPickerController.DXPhotoPickerConfig.maxSeletedNumber {
            showTips()
            return false
        }
        if selectedAssetsArray.contains(asset) {
            return false;
        }
        selectedAssetsArray.append(asset)
        sendButton.badgeValue = "\(self.selectedAssetsArray.count)"
        if selectedAssetsArray.count > 0 {
            toolbarItems!.first!.enabled = true
        }
        return true
    }
    
    private func deleteAsset(asset: PHAsset) -> Bool {
        if selectedAssetsArray.contains(asset) {
            let index = selectedAssetsArray.indexOf(asset)
            guard index != nil else {
                return false
            }
            selectedAssetsArray.removeAtIndex(index!)
            sendButton.badgeValue = "\(self.selectedAssetsArray.count)"
            if selectedAssetsArray.count <= 0 {
                toolbarItems!.first!.enabled = false
            }
            return true
        }
        return false
    }
    
    private func showTips() {
        let alertString = NSString(format: DXlocalizedString("alertContent", comment: ""), NSNumber(integer: DXPhotoPickerController.DXPhotoPickerConfig.maxSeletedNumber))
        let alert = UIAlertController(title: DXlocalizedString("alertTitle", comment: ""), message: alertString as String, preferredStyle: .Alert)
        let action = UIAlertAction(title: DXlocalizedString("alertButton", comment: ""), style: .Cancel) { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(action)
        navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func displayImageInCell(cell: DXAssetCell, indexPath: NSIndexPath) {
        cell.fillWithAsset(assetsArray[indexPath.row], isAssetSelected: selectedAssetsArray.contains(assetsArray[indexPath.row]))
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.Exact
        let scale = UIScreen.mainScreen().scale
        let size = CGSizeMake(DXImageFlowConfig.kThumbSizeLength*scale, DXImageFlowConfig.kThumbSizeLength*scale);
        imageManager?.requestImageForAsset(assetsArray[indexPath.row], targetSize: size, contentMode: .AspectFill, options: options, resultHandler: { (image, obj) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = image
            })
        })
        cell.selectItemBlock {[unowned self] (selected, asset) -> Bool in
            if selected == true {
                return self.addAsset(asset)
            } else {
                self.deleteAsset(asset)
                return false
            }
        }
    }
    
    // MARK: DXPhotoBroswerDelegate
    
    func sendImagesFromPhotoBrowser(photoBrowser: DXPhotoBrowser, currentAsset: PHAsset?) {
        sendImage()
    }
    
    func seletedPhotosNumberInPhotoBrowser(photoBrowser: DXPhotoBrowser) -> Int {
        return selectedAssetsArray.count
    }
    
    func photoBrowser(photoBrowser: DXPhotoBrowser, currentPhotoAssetIsSeleted asset: PHAsset?) -> Bool {
        guard asset != nil else {
            return false
        }
        
        return selectedAssetsArray.contains(asset!)
    }
    
    func photoBrowser(photoBrowser: DXPhotoBrowser, seletedAsset asset: PHAsset?) -> Bool {
        guard asset != nil else {
            return false
        }
        let index = assetsArray.indexOf(asset!)
        guard index != nil else {
            return false
        }
        let success = addAsset(asset!)
        imageFlowCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: index!, inSection: 0)])
        return success
    }
    
    func photoBrowser(photoBrowser: DXPhotoBrowser, deseletedAsset asset: PHAsset?) {
        guard asset != nil else {
            return
        }
        
        let index = assetsArray.indexOf(asset!)
        guard index != nil else {
            return
        }
        deleteAsset(asset!)
        imageFlowCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: index!, inSection: 0)])
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
        displayImageInCell(cell, indexPath: indexPath)
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
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK:  Asset Caching
    
    private func resetCachedAssets() {
        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRectZero
    }
    
    private func updateCachedAssets() {
        let isViewVisible = self.isViewLoaded() && (self.view.window != nil)
        if isViewVisible == false {
            return
        }
        // The preheat window is twice the height of the visible rect.
        var preheatRect = self.imageFlowCollectionView.bounds
        preheatRect = CGRectInset(preheatRect, 0.0, -0.5 * CGRectGetHeight(preheatRect))
        /*
        Check if the collection view is showing an area that is significantly
        different to the last preheated area.
        */
        let delta = fabs(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect))
        if (delta > CGRectGetHeight(self.imageFlowCollectionView.bounds) / 3.0) {
            // Compute the assets to start caching and to stop caching.
            var addedIndexPaths = [NSIndexPath]()
            var removedIndexPaths = [NSIndexPath]()
            computeDifferenceBetweenRect(previousPreheatRect,
                newRect: preheatRect,
                removedHandler: {[unowned self] (removedRect) ->Void in
                    let indexPaths = self.imageFlowCollectionView.aapl_indexPathsForElementsInRect(removedRect)
                    if indexPaths != nil {
                        removedIndexPaths.appendContentsOf(indexPaths!)
                    }
                },
                addedHandler: {[unowned self] (addedRect) -> Void in
                    let indexPaths = self.imageFlowCollectionView.aapl_indexPathsForElementsInRect(addedRect)
                    if indexPaths != nil {
                      addedIndexPaths.appendContentsOf(indexPaths!)
                    }
            })
            
            let assetsToStartCaching = assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching = assetsAtIndexPaths(removedIndexPaths)
            // Update the assets the PHCachingImageManager is caching.
            let options = PHImageRequestOptions()
            options.resizeMode = PHImageRequestOptionsResizeMode.Exact
            let scale = UIScreen.mainScreen().scale
            let size = CGSizeMake(DXImageFlowConfig.kThumbSizeLength*scale, DXImageFlowConfig.kThumbSizeLength*scale);
            
            if assetsToStartCaching != nil && assetsToStartCaching?.count > 0 {
                self.imageManager?.startCachingImagesForAssets(assetsToStartCaching!, targetSize: size, contentMode: .AspectFill, options: options)
            }
            if assetsToStopCaching != nil && assetsToStopCaching?.count > 0 {
                 self.imageManager?.stopCachingImagesForAssets(assetsToStopCaching!, targetSize: size, contentMode: .AspectFill, options: options)
            }
            // Store the preheat rect to compare against in the future.
            self.previousPreheatRect = preheatRect;
        }

    }
    
    private func computeDifferenceBetweenRect(
        oldRect: CGRect,
        newRect: CGRect,
        removedHandler:(removedRect: CGRect)-> Void,
        addedHandler:(addedRect: CGRect)->Void) {
            if CGRectIntersectsRect(newRect, oldRect) {
                let oldMaxY = CGRectGetMaxY(oldRect)
                let oldMinY = CGRectGetMinY(oldRect)
                let newMaxY = CGRectGetMaxY(newRect)
                let newMinY = CGRectGetMinY(newRect)
                if newMaxY > oldMaxY {
                    let rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY))
                    addedHandler(addedRect: rectToAdd)
                }
                
                if oldMinY > newMinY {
                    let rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY))
                    addedHandler(addedRect: rectToAdd)
                }
                if newMaxY < oldMaxY {
                    let rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY))
                    removedHandler(removedRect: rectToRemove)
                }
                if oldMinY < newMinY {
                    let rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY))
                    removedHandler(removedRect: rectToRemove)
                }
            } else {
                addedHandler(addedRect: newRect)
                removedHandler(removedRect: oldRect)
            }
    }
    
    private func assetsAtIndexPaths(indexPaths: [NSIndexPath]) -> [PHAsset]? {
        if indexPaths.count == 0 {
            return nil;
        }
        var assets = [PHAsset]()
        for (_, results) in indexPaths.enumerate() {
            let asset = assetsArray[results.item]
            assets.append(asset)
        }
        return assets
    }

}
