//
//  DXPhotoBroswer.swift
//  DXPhotosPickerDemo
//
//  Created by Ding Xiao on 15/10/14.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

@objc protocol DXPhotoBroswerDelegate: NSObjectProtocol {
    
    func sendImagesFromPhotoBrowser(photoBrowser: DXPhotoBrowser, currentAsset: PHAsset?)
    func seletedPhotosNumberInPhotoBrowser(photoBrowser: DXPhotoBrowser) -> Int
    func photoBrowser(photoBrowser: DXPhotoBrowser, currentPhotoAssetIsSeleted asset: PHAsset?) -> Bool
    func photoBrowser(photoBrowser: DXPhotoBrowser, seletedAsset asset: PHAsset?) -> Bool
    func photoBrowser(photoBrowser: DXPhotoBrowser, deseletedAsset asset: PHAsset?)
    func photoBrowser(photoBrowser: DXPhotoBrowser, seleteFullImage fullImage: Bool)
}

class DXPhotoBrowser: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    struct DXPhotoBrowserConfig {
        static let browserCellReuseIdntifier = "DXBrowserCell"
    }
    
    // MARK: peoperties
    private var statusBarShouldBeHidden = false
    private var didSavePreviousStateOfNavBar = false
    private var viewIsActive = false
    private var viewHasAppearedInitially = false
    private var previousNavBarHidden = false
    private var previousNavBarTranslucent = false
    private var previousNavBarStyle: UIBarStyle = .Default
    private var previousStatusBarStyle: UIStatusBarStyle = .Default
    private var previousNavBarTintColor: UIColor?
    private var previousNavBarBarTintColor: UIColor?
    private var previousViewControllerBackButton: UIBarButtonItem?
    private var previousNavigationBarBackgroundImageDefault: UIImage?
    private var previousNavigationBarBackgroundImageLandscapePhone: UIImage?
    
    private var photosDataSource: Array<PHAsset>?
    private var currentIndex = 0
    private var fullImage = false
    private var requestID: PHImageRequestID?
    
    lazy var fullImageButton: DXFullImageButton = {
        let button = DXFullImageButton(frame: CGRectMake(0, 0, self.view.dx_width/2,28))
        button.addTarget(self, action: #selector(DXPhotoBrowser.fullImageButtonAction))
        button.selected = self.fullImage
        return button
    }()
    
    lazy var browserCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        let collectionView = UICollectionView(frame: CGRectMake(-10, 0, self.view.dx_width+20, self.view.dx_height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.blackColor()
        collectionView .registerClass(DXBrowserCell.self, forCellWithReuseIdentifier: DXPhotoBrowserConfig.browserCellReuseIdntifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.pagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    lazy var toolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRectMake(0, self.view.dx_height - 44, self.view.dx_width, 44))
        toolbar.setBackgroundImage(nil, forToolbarPosition: .Any, barMetrics: .Default)
        toolbar.barStyle = .Black
        toolbar.translucent = true
        return toolbar
    }()
    
    lazy var checkButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 25, 25)
        button.setBackgroundImage(UIImage(named: "photo_check_selected"), forState: .Selected)
        button.setBackgroundImage(UIImage(named: "photo_check_default"), forState: .Normal)
        button.addTarget(self, action: #selector(DXPhotoBrowser.checkButtonAction), forControlEvents: .TouchUpInside)
        return button
    }()
    
    lazy var sendButton: DXSendButton = {
        let button = DXSendButton(frame: CGRectZero)
        button.addTarget(self, action: #selector(DXPhotoBrowser.sendButtonAction))
        return button
    }()
    
    weak var delegate: DXPhotoBroswerDelegate?
    
    // MARK: life time
    required init(photosArray: Array<AnyObject>?, currentIndex: Int, isFullImage: Bool) {
        self.init()
        self.currentIndex = currentIndex
        fullImage = isFullImage
        photosDataSource = photosArray as? Array<PHAsset>
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateNavigationBarAndToolBar()
        updateSelestedNumber()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        previousStatusBarStyle = UIApplication.sharedApplication().statusBarStyle
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: animated)
        // Navigation bar appearance
        if (viewIsActive == false && navigationController?.viewControllers.first != self) {
            storePreviousNavBarAppearance()
        }
        setNavBarAppearance(animated)
        if viewHasAppearedInitially == false {
            viewHasAppearedInitially = true
        }
        browserCollectionView.contentOffset = CGPointMake(browserCollectionView.dx_width * CGFloat(currentIndex), 0)
    }
    
    override func viewWillDisappear(animated: Bool) {
        if (navigationController?.viewControllers.first != self && navigationController?.viewControllers.contains(self) == false) {
            viewIsActive = false
            restorePreviousNavBarAppearance(animated)
        }
        navigationController?.navigationBar.layer.removeAllAnimations()
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        setControlsHidden(false, animated: false)
        UIApplication.sharedApplication().setStatusBarStyle(previousStatusBarStyle, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewIsActive = true
    }
    
    // MARK: priviate
    
    private func restorePreviousNavBarAppearance(animated: Bool) {
        if didSavePreviousStateOfNavBar == true {
            navigationController?.setNavigationBarHidden(previousNavBarHidden, animated: animated)
            let navBar = navigationController!.navigationBar
            navBar.tintColor = previousNavBarBarTintColor
            navBar.translucent = previousNavBarTranslucent
            navBar.barTintColor = previousNavBarBarTintColor
            navBar.barStyle = previousNavBarStyle
            navBar.setBackgroundImage(previousNavigationBarBackgroundImageDefault, forBarMetrics: .Default)
            navBar.setBackgroundImage(previousNavigationBarBackgroundImageLandscapePhone, forBarMetrics: .Compact)
            if previousViewControllerBackButton != nil {
                let previousViewController = navigationController!.topViewController
                previousViewController?.navigationItem.backBarButtonItem = previousViewControllerBackButton
                previousViewControllerBackButton = nil
            }
        }
    }
    
    private func setNavBarAppearance(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        let navBar = navigationController!.navigationBar
        navBar.tintColor = UIColor.whiteColor()
        navBar.translucent = true
        navBar.barStyle = .BlackTranslucent
        navBar.setBackgroundImage(nil, forBarMetrics: .Default)
        navBar.setBackgroundImage(nil, forBarMetrics: .Compact)
    }
    
    private func storePreviousNavBarAppearance() {
        didSavePreviousStateOfNavBar = true
        previousNavBarBarTintColor = navigationController?.navigationBar.barTintColor
        previousNavBarTranslucent = navigationController!.navigationBar.translucent;
        previousNavBarTintColor = navigationController!.navigationBar.tintColor;
        previousNavBarHidden = navigationController!.navigationBarHidden;
        previousNavBarStyle = navigationController!.navigationBar.barStyle;
        previousNavigationBarBackgroundImageDefault = navigationController!.navigationBar.backgroundImageForBarMetrics(.Default)
        previousNavigationBarBackgroundImageLandscapePhone = navigationController!.navigationBar.backgroundImageForBarMetrics(.Compact)
    }
    
    private func setupViews() {
        
        func setupBarButtonItems() {
            let item1 = UIBarButtonItem(customView: fullImageButton)
            let item2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            let item3 = UIBarButtonItem(customView: sendButton)
            let item4 = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
            item4.width = -10
            toolBar.items = [item1,item2,item3,item4]
        }
        
        automaticallyAdjustsScrollViewInsets = false
        view.clipsToBounds = true
        view.addSubview(browserCollectionView)
        view.addSubview(toolBar)
        setupBarButtonItems()
        let rigthBarItem = UIBarButtonItem(customView: checkButton)
        navigationItem.rightBarButtonItem = rigthBarItem
        createBarButtonItemAtPosition(.Left, normalImage: UIImage(named: "back_normal"), highlightImage: UIImage(named: "back_highlight"), action: #selector(DXPhotoBrowser.backButtonAction))
    }
    
    private func updateNavigationBarAndToolBar() {
        guard photosDataSource != nil else {
            return
        }
        title = "\(currentIndex + 1)"+"/" + "\(photosDataSource!.count)"
        let selected = self.delegate?.photoBrowser(self, currentPhotoAssetIsSeleted: photosDataSource?[currentIndex])
        if selected == nil {
            checkButton.selected = false
        } else {
            checkButton.selected = selected!
        }

        fullImageButton.selected = fullImage
        if fullImage {
            let asset = photosDataSource![currentIndex]
            DXPickerHelper.fetchImageSize(asset, imageSizeResultHandler: {[unowned self] (imageSize, sizeString) -> Void in
                self.fullImageButton.text = "(\(sizeString))"
                })
        }
    }
    
    private func updateSelestedNumber() {
        let number = self.delegate?.seletedPhotosNumberInPhotoBrowser(self)
        if (number != nil) {
            self.sendButton.badgeValue = "\(number!)"
        }
        
    }
    
    private func didScrollToPage(page: Int) {
        currentIndex = page
        updateNavigationBarAndToolBar()
    }
    
    // MARK: ui actions
    
    @objc private func backButtonAction() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @objc private func sendButtonAction() {
        delegate?.sendImagesFromPhotoBrowser(self, currentAsset: photosDataSource![currentIndex])
    }
    
    @objc private func fullImageButtonAction() {
        fullImageButton.selected = !fullImageButton.selected
        fullImage = fullImageButton.selected
        self.delegate?.photoBrowser(self, seleteFullImage: fullImage)
        if fullImageButton.selected {
            if ((delegate?.photoBrowser(self, seletedAsset: photosDataSource?[currentIndex])) != nil){
                updateNavigationBarAndToolBar()
            }
        }
    }
    
    @objc private func checkButtonAction() {
        if checkButton.selected {
            delegate?.photoBrowser(self, deseletedAsset: photosDataSource?[currentIndex])
            checkButton.selected = false
            updateSelestedNumber()
        } else {
            let selected = delegate?.photoBrowser(self, seletedAsset: photosDataSource?[currentIndex])
            if selected == nil {
                checkButton.selected = false
            } else {
                checkButton.selected = selected!
            }
            
            if checkButton.selected {
                updateSelestedNumber()
            }
        }
    }
    
    // MARK: ScrollerViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let deltaOffset = scrollView.contentOffset.x - browserCollectionView.dx_width * CGFloat(currentIndex)
        if (fabs(deltaOffset) >= browserCollectionView.dx_width/2 ) {
            fullImageButton.shouldAnimating(true)
        } else {
            fullImageButton.shouldAnimating(false)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= 0 {
            let page = scrollView.contentOffset.x / browserCollectionView.dx_width
            didScrollToPage(Int(page))
        }
        fullImageButton.shouldAnimating(false)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.view.bounds.size.width+20, self.view.bounds.size.height);
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosDataSource == nil ? 0 : self.photosDataSource!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DXPhotoBrowserConfig.browserCellReuseIdntifier, forIndexPath: indexPath) as! DXBrowserCell
        cell.asset = photosDataSource![indexPath.row]
        cell.photoBrowser = self
        return cell
    }
    
    // MARK: control hide
    
    private func setControlsHidden(hidden: Bool, animated: Bool) {
        var hide = hidden
        if (photosDataSource == nil || photosDataSource!.count == 0) {
            hide = false
        }
        let animationOffSet: CGFloat = 20
        let animationDuration = (animated ? 0.35 : 0)
        statusBarShouldBeHidden = hide
        UIView.animateWithDuration(animationDuration, animations: {[unowned self] () -> Void in
            self.setNeedsStatusBarAppearanceUpdate()
            })
        let frame = CGRectIntegral(CGRectMake(0, view.dx_height - 44, view.dx_width, 44))
        if areControlsHidden() && hide == false && animated {
            toolBar.frame = CGRectOffset(frame, 0, animationOffSet)
        }
        UIView.animateWithDuration(animationDuration) {[unowned self] () -> Void in
            let alpha: CGFloat = hide ? 0 : 1
            self.navigationController?.navigationBar.alpha = alpha
            self.toolBar.frame = frame
            if hide {
                self.toolBar.frame = CGRectOffset(self.toolBar.frame, 0, animationOffSet)
            }
            self.toolBar.alpha = alpha
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return statusBarShouldBeHidden
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
    
    private func areControlsHidden() -> Bool {
        return toolBar.alpha == 0
    }
    
    private func hideControls() {
        setControlsHidden(true, animated: true)
    }
    
    @objc func toggleControls() {
        setControlsHidden(!areControlsHidden(), animated: true)
    }
}
