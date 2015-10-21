//
//  DXPhotoBroswer.swift
//  DXPhotosPickerDemo
//
//  Created by Ding Xiao on 15/10/14.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

let kDXBrowserCellReuseIdntifier = "DXBrowserCell"

class DXPhotoBroswer: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var statusBarShouldBeHidden = false
    var didSavePreviousStateOfNavBar = false
    var viewIsActive = false
    var viewHasAppearedInitially = false
    // Appearance
    var previousNavBarHidden = false
    var previousNavBarTranslucent = false
    var previousNavBarStyle: UIBarStyle = .Default
    var previousStatusBarStyle: UIStatusBarStyle = .Default
    var previousNavBarTintColor: UIColor?
    var previousNavBarBarTintColor: UIColor?
    var previousViewControllerBackButton: UIBarButtonItem?
    var previousNavigationBarBackgroundImageDefault: UIImage?
    var previousNavigationBarBackgroundImageLandscapePhone: UIImage?
    
    var photosDataSource: Array<AnyObject>?
    
    required init(photosArray: Array<AnyObject>?, currentIndex: Int, isFullImage: Bool) {
        self.init()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: convenience
    
    private func setupViews() {
        
    }
    
    // MARK: ui actions
    
    func checkButtonAction() {
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosDataSource == nil ? 0 : self.photosDataSource!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kDXBrowserCellReuseIdntifier, forIndexPath: indexPath) as! DXBrowserCell
        // TODO: setup cell
        return cell
    }

    
    // MARK: lazyload

    lazy var browserCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        var collectionView = UICollectionView(frame: CGRectZero)
        collectionView.backgroundColor = UIColor.blackColor()
        collectionView .registerClass(DXBrowserCell.self, forCellWithReuseIdentifier: kDXBrowserCellReuseIdntifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.pagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    lazy var toolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRectZero)
        toolbar.setBackgroundImage(nil, forToolbarPosition: .Any, barMetrics: .Default)
        toolbar.setBackgroundImage(nil, forToolbarPosition: .Any, barMetrics: .DefaultPrompt)
        toolbar.barStyle = .Black
        toolbar.translucent = true
        return toolbar
        }()
    
    lazy var checkButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 25, 25)
        button.setBackgroundImage(UIImage(named: "photo_check_selected"), forState: .Selected)
        button.setBackgroundImage(UIImage(named: "photo_check_default"), forState: .Normal)
        button.addTarget(self, action: Selector("checkButtonAction"), forControlEvents: .TouchUpInside)
        return button
        }()
}
