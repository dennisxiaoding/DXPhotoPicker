//
//  ViewController.swift
//  DXPhotosPickerDemo
//
//  Created by Ding Xiao on 15/10/13.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DXPhototPickerControllerDelegate {
// MARK: ui actions
    @IBAction func addPhotos(sender: UIButton) {
        DXLog(sender)
        let picker = DXPhototPickerController()
        picker.photoPickerDelegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: DXPhototPickerControllerDelegate
    func photoPickerDidCancel(photoPicker: DXPhototPickerController) {
        photoPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func photoPickerController(photosPicker: DXPhototPickerController?, sendImages: [AnyObject]?, isFullImage: Bool) {
        DXLog("\(__FUNCTION__)")
    }
}

