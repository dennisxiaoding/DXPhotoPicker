//
//  DXSelectedImageViewController.swift
//  DXPhotoPickerDemo
//
//  Created by Ding Xiao on 15/11/4.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "DXSelectedImageCell"

class DXSelectedImageViewController: UICollectionViewController {

    var selectedImages: [PHAsset]?
    var isFullImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.interactivePopGestureRecognizer?.enabled = true
        createBarButtonItemAtPosition(.Left, normalImage: UIImage(named: "back_normal"), highlightImage: UIImage(named: "back_highlight"), action: Selector("back"))
    }
    
    @objc private func back() {
        navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard selectedImages != nil else {
            return 0
        }
        return selectedImages!.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DXSelectedImageCell
        DXPickerManager.fetchImageWithAsset(selectedImages![indexPath.row], targetSize: CGSizeMake(150, 150)) { (image) -> Void in
            cell.selectedImageView.image = image
        }
        
        if isFullImage {
            DXPickerManager.fetchImageSize(selectedImages![indexPath.row]) { (imageSize, sizeString) -> Void in
                cell.infoLabel.text = "imageSize: " + sizeString
            }
        } else {
                cell.infoLabel.text = "not full image"
        }
        return cell
    }
}
