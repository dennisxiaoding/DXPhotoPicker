//
//  ViewController.swift
//  DXPhotosPickerDemo
//
//  Created by Ding Xiao on 15/10/13.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, DXPhotoPickerControllerDelegate {
// MARK: ui actions
    @IBAction func addPhotos(sender: UIButton) {
        let picker = DXPhotoPickerController()
        picker.photoPickerDelegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func aboutAction(sender: UIButton) {
        UIApplication.shared.openURL(URL(string: "http://weibo.com/GreatDingXiao")!)
    }
    // MARK: DXPhototPickerControllerDelegate
    func photoPickerDidCancel(photoPicker: DXPhotoPickerController) {
        photoPicker.dismiss(animated: true, completion: nil)
    }
    
    func photoPickerController(photoPicker photosPicker: DXPhotoPickerController?, sendImages: [PHAsset]?, isFullImage: Bool) {
        photosPicker?.dismiss(animated: true, completion: nil)
        let vc = storyboard?.instantiateViewController(withIdentifier: "DXSelectedImageViewController") as! DXSelectedImageViewController
        vc.selectedImages = sendImages
        vc.isFullImage = isFullImage
        navigationController?.pushViewController(vc, animated: true)
    }
}

