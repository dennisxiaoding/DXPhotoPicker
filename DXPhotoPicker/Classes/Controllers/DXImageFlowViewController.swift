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
        static let kThumbSizeLength = (UIScreen.main.bounds.size.width-10)/4
    }
    
    private var currentAlbum: DXAlbum?
    private var albumIdentifier: String?
    private var assetsArray: [PHAsset]
    private var selectedAssetsArray: [PHAsset]
    private var isFullImage = false
    private var imageManager: PHCachingImageManager?
    private var previousPreheatRect: CGRect = CGRect.zero
    
    private lazy var imageFlowCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 2.0
        flowLayout.minimumInteritemSpacing = 2.0
        flowLayout.scrollDirection = .vertical;
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.backgroundColor = UIColor.white
        collectionView.register(DXAssetCell.self, forCellWithReuseIdentifier: DXImageFlowConfig.dxAssetCellReuseIdentifier)
        return collectionView;
    }()
    private lazy var sendButton: DXSendButton = {
        let button = DXSendButton(frame: CGRect.zero)
        button.addTarget(target: self, action: #selector(DXImageFlowViewController.sendImage))
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
            view.backgroundColor = UIColor.white
            self.createBarButtonItemAt(position: .left,
                                       normalImage:  UIImage(named: "back_normal"),
                                       highlightImage: UIImage(named: "back_highlight"),
                                       action: #selector(DXImageFlowViewController.backButtonAction))
            self.createBarButtonItemAt(position: .right,
                                       text: DXlocalized(string: "cancel", comment: "取消"),
                                       action: #selector(DXImageFlowViewController.cancelAction))
            
            let item1 = UIBarButtonItem(
                title: DXlocalized(string: "preview", comment: "预览"),
                style: .plain,
                target: self,
                action: #selector(DXImageFlowViewController.previewAction)
            )
            item1.tintColor = UIColor.black
            item1.isEnabled = false
            let item2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let item3 = UIBarButtonItem(customView: self.sendButton)
            let item4 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            item4.width = -10
            setToolbarItems([item1,item2,item3,item4], animated: false)
            self.view.addSubview(imageFlowCollectionView)
            let viewBindDic = ["imageFlowCollectionView":imageFlowCollectionView]
            let vflH = "H:|-0-[imageFlowCollectionView]-0-|"
            let vflV = "V:|-0-[imageFlowCollectionView]-0-|"
            let contraintsH = NSLayoutConstraint.constraints(withVisualFormat: vflH,
                                                             options: NSLayoutFormatOptions(rawValue: 0),
                                                             metrics: nil,
                                                             views: viewBindDic)
            let contraintsV = NSLayoutConstraint.constraints(withVisualFormat: vflV,
                                                             options: NSLayoutFormatOptions(rawValue: 0),
                                                             metrics: nil,
                                                             views: viewBindDic)
            self.view.addConstraints(contraintsH)
            self.view.addConstraints(contraintsV)
        }
        
        func setUpData() {
            if currentAlbum == nil && albumIdentifier != nil {
                currentAlbum = DXPickerHelper.fetchAlbum()
            }
            self.title = currentAlbum?.name
            
            DispatchQueue.global().async {
                self.assetsArray = DXPickerHelper.fetchImageAssets(inCollectionResults: self.currentAlbum!.results)
                DispatchQueue.main.async {
                    self.imageManager = PHCachingImageManager()
                    self.imageFlowCollectionView.reloadData()
                    let item = self.imageFlowCollectionView.numberOfItems(inSection: 0)
                    guard item != 0 else {
                        return
                    }
                    let lastItemIndex = IndexPath(item: item-1, section: 0)
                    self.imageFlowCollectionView.scrollToItem(at: lastItemIndex, at: .bottom, animated: false)
                }
            }
        }
        setupView()
        setUpData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        sendButton.badgeValue = "\(selectedAssetsArray.count)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
        super.viewWillDisappear(animated)
    }
    
    // MARK: button actons
    
    @objc private func sendImage() {
        
        let photoPicker = navigationController as? DXPhotoPickerController
        guard (photoPicker != nil ) else {
            return
        }
        DXPickerHelper.save(identifier: currentAlbum?.identifier)
        DXLog(currentAlbum?.identifier)
        photoPicker!.photoPickerDelegate?.photoPickerController?(photoPicker: photoPicker, sendImages: selectedAssetsArray, isFullImage: isFullImage)
    }
    
    @objc private func backButtonAction() {
        self.pop(animated: true)
    }
    
    @objc private func cancelAction() {
        let navController = navigationController as? DXPhotoPickerController
        navController?.photoPickerDelegate?.photoPickerDidCancel?(photoPicker: navController!)
    }
    
    @objc private func previewAction() {
        browserPhotoAsstes(assets: selectedAssetsArray, pageIndex: 0)
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
            toolbarItems!.first!.isEnabled = true
        }
        return true
    }
    
    @discardableResult
    private func deleteAsset(asset: PHAsset) -> Bool {
        if selectedAssetsArray.contains(asset) {
            let index = selectedAssetsArray.index(of: asset)
            guard index != nil else {
                return false
            }
            selectedAssetsArray.remove(at: index!)
            sendButton.badgeValue = "\(self.selectedAssetsArray.count)"
            if selectedAssetsArray.count <= 0 {
                toolbarItems!.first!.isEnabled = false
            }
            return true
        }
        return false
    }
    
    private func showTips() {
        let alertString = NSString(format: DXlocalized(string: "alertContent", comment: "") as NSString, NSNumber(value: DXPhotoPickerController.DXPhotoPickerConfig.maxSeletedNumber))
        let alert = UIAlertController(title: DXlocalized(string: "alertTitle", comment: ""), message: alertString as String, preferredStyle: .alert)
        let action = UIAlertAction(title: DXlocalized(string: "alertButton", comment: ""), style: .cancel) { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    private func displayImageInCell(cell: DXAssetCell, indexPath: NSIndexPath) {
        cell.fillWithAsset(asset: assetsArray[indexPath.row], isAssetSelected: selectedAssetsArray.contains(assetsArray[indexPath.row]))
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.exact
        let scale = UIScreen.main.scale
        let size = CGSize(width: DXImageFlowConfig.kThumbSizeLength*scale, height: DXImageFlowConfig.kThumbSizeLength*scale);
        imageManager?.requestImage(for: assetsArray[indexPath.row], targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { (image, obj) -> Void in
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
        })
        cell.selectItemBlock {[unowned self] (selected, asset) -> Bool in
            if selected == true {
                return self.addAsset(asset: asset)
            } else {
                self.deleteAsset(asset: asset)
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
        let index = assetsArray.index(of: asset!)
        guard index != nil else {
            return false
        }
        let success = addAsset(asset: asset!)
        imageFlowCollectionView.reloadItems(at: [IndexPath(item: index!, section: 0)])
        return success
    }
    
    func photoBrowser(photoBrowser: DXPhotoBrowser, deseletedAsset asset: PHAsset?) {
        guard asset != nil else {
            return
        }
        
        let index = assetsArray.index(of: asset!)
        guard index != nil else {
            return
        }
        deleteAsset(asset: asset!)
        imageFlowCollectionView.reloadItems(at: [IndexPath(item: index!, section: 0)])
    }
    
    func photoBrowser(photoBrowser: DXPhotoBrowser, seleteFullImage fullImage: Bool) {
        isFullImage = fullImage
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DXImageFlowConfig.dxAssetCellReuseIdentifier, for: indexPath) as! DXAssetCell
        displayImageInCell(cell: cell, indexPath: indexPath as NSIndexPath)
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: DXImageFlowConfig.kThumbSizeLength, height: DXImageFlowConfig.kThumbSizeLength)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(2, 2, 2, 2)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        browserPhotoAsstes(assets: assetsArray, pageIndex: indexPath.row)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK:  Asset Caching
    
    private func resetCachedAssets() {
        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }
    
    private func updateCachedAssets() {
        let isViewVisible = self.isViewLoaded && (self.view.window != nil)
        if isViewVisible == false {
            return
        }
        // The preheat window is twice the height of the visible rect.
        var preheatRect = self.imageFlowCollectionView.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
        /*
        Check if the collection view is showing an area that is significantly
        different to the last preheated area.
        */
        let delta = fabs(preheatRect.midY - self.previousPreheatRect.midY)
        
        if (delta > self.imageFlowCollectionView.bounds.height / 3.0) {
            // Compute the assets to start caching and to stop caching.
            var addedIndexPaths = [NSIndexPath]()
            var removedIndexPaths = [NSIndexPath]()
            computeDifferenceBetweenRect(oldRect: previousPreheatRect,
                newRect: preheatRect,
                removedHandler: {[unowned self] (removedRect) ->Void in
                    let indexPaths = self.imageFlowCollectionView.aapl_indexPathsForElementsInRect(rect: removedRect)
                    if indexPaths != nil {
                        removedIndexPaths.append(contentsOf: indexPaths!)
                    }
                },
                addedHandler: {[unowned self] (addedRect) -> Void in
                    let indexPaths = self.imageFlowCollectionView.aapl_indexPathsForElementsInRect(rect: addedRect)
                    if indexPaths != nil {
                      addedIndexPaths.append(contentsOf: indexPaths!)
                    }
            })
            
            let assetsToStartCaching = assetsAtIndexPaths(indexPaths: addedIndexPaths)
            let assetsToStopCaching = assetsAtIndexPaths(indexPaths: removedIndexPaths)
            // Update the assets the PHCachingImageManager is caching.
            let options = PHImageRequestOptions()
            options.resizeMode = PHImageRequestOptionsResizeMode.exact
            let scale = UIScreen.main.scale
            let size = CGSize(width: DXImageFlowConfig.kThumbSizeLength*scale, height: DXImageFlowConfig.kThumbSizeLength*scale);
            
            if assetsToStartCaching != nil && (assetsToStartCaching?.count)! > 0 {
                self.imageManager?.startCachingImages(for: assetsToStartCaching!, targetSize: size, contentMode: .aspectFill, options: options)
            }
            if assetsToStopCaching != nil && (assetsToStopCaching?.count)! > 0 {
                 self.imageManager?.stopCachingImages(for: assetsToStopCaching!, targetSize: size, contentMode: .aspectFill, options: options)
            }
            // Store the preheat rect to compare against in the future.
            self.previousPreheatRect = preheatRect;
        }

    }
    
    private func computeDifferenceBetweenRect(
        oldRect: CGRect,
        newRect: CGRect,
        removedHandler:(_ removedRect: CGRect)-> Void,
        addedHandler:(_ addedRect: CGRect)->Void) {
            if newRect.intersects(oldRect) {
                let oldMaxY = oldRect.maxY
                let oldMinY = oldRect.minY
                let newMaxY = newRect.maxY
                let newMinY = newRect.minY
                if newMaxY > oldMaxY {
                    let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                    addedHandler(rectToAdd)
                }
                
                if oldMinY > newMinY {
                    let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                    addedHandler(rectToAdd)
                }
                if newMaxY < oldMaxY {
                    let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height: (oldMaxY - newMaxY))
                    removedHandler(rectToRemove)
                }
                if oldMinY < newMinY {
                    let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height: (newMinY - oldMinY))
                    removedHandler(rectToRemove)
                }
            } else {
                addedHandler(newRect)
                removedHandler(oldRect)
            }
    }
    
    private func assetsAtIndexPaths(indexPaths: [NSIndexPath]) -> [PHAsset]? {
        if indexPaths.count == 0 {
            return nil;
        }
        var assets = [PHAsset]()
        for (_, results) in indexPaths.enumerated() {
            let asset = assetsArray[results.item]
            assets.append(asset)
        }
        return assets
    }

}
