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
    }
    
    @objc private func back() {
        self.pop(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard selectedImages != nil else {
            return 0
        }
        return selectedImages!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! DXSelectedImageCell
        DXPickerHelper.fetchImage(viaAsset: selectedImages![indexPath.row], targetSize: CGSize(width:150, height: 150)) { (image) -> Void in
            cell.selectedImageView.image = image
        }
        
        if isFullImage {
            DXPickerHelper.fetchImageSize(asset: selectedImages![indexPath.row]) { (imageSize, sizeString) -> Void in
                cell.infoLabel.text = "imageSize: " + sizeString
            }
        } else {
            cell.infoLabel.text = "not full image"
        }
        return cell
    }    
}

