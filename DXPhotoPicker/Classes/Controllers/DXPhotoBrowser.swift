//
//  DXPhotoBroswer.swift
//  DXPhotosPickerDemo
//
//  Created by Ding Xiao on 15/10/14.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

protocol DXPhotoBroswerDelegate: NSObjectProtocol {
    
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
    private var previousNavBarStyle: UIBarStyle = .default
    private var previousStatusBarStyle: UIStatusBarStyle = .default
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

        let button = DXFullImageButton(frame: CGRect(x: 0, y: 0, width: self.view.dx_width/2, height: 28))
        button.addTarget(target: self, action: #selector(DXPhotoBrowser.fullImageButtonAction))
        button.selected = self.fullImage
        return button
    }()
    
    lazy var browserCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
       
        let collectionView = UICollectionView(frame:  CGRect(x: -10, y: 0, width: self.view.dx_width+20, height: self.view.dx_height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.black
        collectionView.register(DXBrowserCell.self, forCellWithReuseIdentifier: DXPhotoBrowserConfig.browserCellReuseIdntifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    lazy var toolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y:self.view.dx_height - 44, width:self.view.dx_width, height:44))
        toolbar.setBackgroundImage(nil, forToolbarPosition: .any, barMetrics: .default)
        toolbar.barStyle = .black
        toolbar.isTranslucent = true
        return toolbar
    }()
    
    lazy var checkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x:0, y:0, width:25, height:25)
        button.setBackgroundImage(UIImage(named: "photo_check_selected"), for: .selected)
        button.setBackgroundImage(UIImage(named: "photo_check_default"), for: .normal)
        button.addTarget(self, action: #selector(DXPhotoBrowser.checkButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var sendButton: DXSendButton = {
        let button = DXSendButton(frame: CGRect.zero)
        button.addTarget(target: self, action: #selector(DXPhotoBrowser.sendButtonAction))
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.previousStatusBarStyle = UIApplication.shared.statusBarStyle
        UIApplication.shared.setStatusBarStyle(.default, animated: animated)
        
        // Navigation bar appearance
        if (viewIsActive == false && navigationController?.viewControllers.first != self) {
            self.storePreviousNavBarAppearance()
        }
        self.setNavBarAppearance(animated: animated)
        if self.viewHasAppearedInitially == false {
            self.viewHasAppearedInitially = true
        }
        browserCollectionView.contentOffset = CGPoint(x:browserCollectionView.dx_width * CGFloat(currentIndex), y:0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (navigationController?.viewControllers.first != self && navigationController?.viewControllers.contains(self) == false) {
            viewIsActive = false
            restorePreviousNavBarAppearance(animated: animated)
        }
        navigationController?.navigationBar.layer.removeAllAnimations()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        setControlsHidden(hidden: false, animated: false)
        UIApplication.shared.setStatusBarStyle(previousStatusBarStyle, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewIsActive = true
    }
    
    // MARK: priviate
    
    private func restorePreviousNavBarAppearance(animated: Bool) {
        if didSavePreviousStateOfNavBar == true {
            navigationController?.setNavigationBarHidden(previousNavBarHidden, animated: animated)
            let navBar = navigationController!.navigationBar
            navBar.tintColor = previousNavBarBarTintColor
            navBar.isTranslucent = previousNavBarTranslucent
            navBar.barTintColor = previousNavBarBarTintColor
            navBar.barStyle = previousNavBarStyle
            navBar.setBackgroundImage(previousNavigationBarBackgroundImageDefault, for: .default)
            navBar.setBackgroundImage(previousNavigationBarBackgroundImageLandscapePhone, for: .compact)
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
        navBar.tintColor = UIColor.white
        navBar.isTranslucent = true
        navBar.barStyle = .blackTranslucent
        navBar.setBackgroundImage(nil, for: .default)
        navBar.setBackgroundImage(nil, for: .compact)
    }
    
    private func storePreviousNavBarAppearance() {
        didSavePreviousStateOfNavBar = true
        previousNavBarBarTintColor = navigationController?.navigationBar.barTintColor
        previousNavBarTranslucent = navigationController!.navigationBar.isTranslucent;
        previousNavBarTintColor = navigationController!.navigationBar.tintColor;
        previousNavBarHidden = navigationController!.isNavigationBarHidden;
        previousNavBarStyle = navigationController!.navigationBar.barStyle;
        previousNavigationBarBackgroundImageDefault = navigationController!.navigationBar.backgroundImage(for: .default)
        previousNavigationBarBackgroundImageLandscapePhone = navigationController!.navigationBar.backgroundImage(for: .compact)
    }
    
    private func setupViews() {
        
        func setupBarButtonItems() {
            let item1 = UIBarButtonItem(customView: fullImageButton)
            let item2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let item3 = UIBarButtonItem(customView: sendButton)
            let item4 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
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
        self.createBarButtonItemAt(position: .left, normalImage: UIImage(named: "back_normal"), highlightImage: UIImage(named: "back_highlight"), action: #selector(DXPhotoBrowser.backButtonAction))
    }
    
    private func updateNavigationBarAndToolBar() {
        guard photosDataSource != nil else {
            return
        }
        title = "\(currentIndex + 1)"+"/" + "\(photosDataSource!.count)"
        let asset = photosDataSource?[currentIndex]
        let selected = self.delegate?.photoBrowser(photoBrowser: self, currentPhotoAssetIsSeleted: asset)
        if selected == nil {
            checkButton.isSelected = false
        } else {
            checkButton.isSelected = selected!
        }

        fullImageButton.selected = fullImage
        if fullImage {
            let asset = photosDataSource![currentIndex]
            DXPickerHelper.fetchImageSize(asset: asset, imageSizeResultHandler: {[unowned self] (imageSize, sizeString) -> Void in
                self.fullImageButton.text = "(\(sizeString))"
                })
        }
    }
    
    private func updateSelestedNumber() {
        let number = self.delegate?.seletedPhotosNumberInPhotoBrowser(photoBrowser: self)
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
        self.pop(animated: true)
    }
    
    @objc private func sendButtonAction() {
        delegate?.sendImagesFromPhotoBrowser(photoBrowser: self, currentAsset: photosDataSource![currentIndex])
    }
    
    @objc private func fullImageButtonAction() {
        fullImageButton.selected = !fullImageButton.selected
        fullImage = fullImageButton.selected
        self.delegate?.photoBrowser(photoBrowser: self, seleteFullImage: fullImage)
        if fullImageButton.selected {
            let asset =  photosDataSource?[currentIndex]
            if delegate?.photoBrowser(photoBrowser: self, seletedAsset: asset) != nil {
                updateNavigationBarAndToolBar()
                updateSelestedNumber()
            }
        }
    }
    
    @objc private func checkButtonAction() {
        let asset =  photosDataSource?[currentIndex]
        if checkButton.isSelected {
            delegate?.photoBrowser(photoBrowser: self, deseletedAsset: asset)
            checkButton.isSelected = false
            updateSelestedNumber()
        } else {
            let selected = delegate?.photoBrowser(photoBrowser: self, seletedAsset: asset)
            if selected == nil {
                checkButton.isSelected = false
            } else {
                checkButton.isSelected = selected!
            }
            
            if checkButton.isSelected {
                updateSelestedNumber()
            }
        }
    }
    
    // MARK: ScrollerViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let deltaOffset = scrollView.contentOffset.x - browserCollectionView.dx_width * CGFloat(currentIndex)
        if (fabs(deltaOffset) >= browserCollectionView.dx_width/2 ) {
            fullImageButton.shouldAnimating(animated: true)
        } else {
            fullImageButton.shouldAnimating(animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= 0 {
            let page = scrollView.contentOffset.x / browserCollectionView.dx_width
            didScrollToPage(page: Int(page))
        }
        fullImageButton.shouldAnimating(animated: false)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.size.width+20, height: self.view.bounds.size.height);
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosDataSource == nil ? 0 : self.photosDataSource!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DXPhotoBrowserConfig.browserCellReuseIdntifier, for: indexPath) as! DXBrowserCell
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
        UIView.animate(withDuration: animationDuration, animations: {[unowned self] () -> Void in
            self.setNeedsStatusBarAppearanceUpdate()
            })
        let frame = CGRect(x:0, y:view.dx_height - 44, width:view.dx_width, height:44).integral
        if areControlsHidden() && hide == false && animated {
            toolBar.frame = frame.offsetBy(dx: 0, dy: animationOffSet)
        }
        UIView.animate(withDuration: animationDuration) {[unowned self] () -> Void in
            let alpha: CGFloat = hide ? 0 : 1
            self.navigationController?.navigationBar.alpha = alpha
            self.toolBar.frame = frame
            if hide {
                self.toolBar.frame = self.toolBar.frame.offsetBy(dx: 0, dy: animationOffSet)
            }
            self.toolBar.alpha = alpha
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    private func areControlsHidden() -> Bool {
        return toolBar.alpha == 0
    }
    
    private func hideControls() {
        setControlsHidden(hidden: true, animated: true)
    }
    
    @objc func toggleControls() {
        setControlsHidden(hidden: !areControlsHidden(), animated: true)
    }
}
