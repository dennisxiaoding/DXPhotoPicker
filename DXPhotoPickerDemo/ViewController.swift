//
//  ViewController.swift
//  DXPhotosPickerDemo
//
//  Created by Ding Xiao on 15/10/13.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
// MARK: ui actions
    @IBAction func addPhotos(sender: UIButton) {
        DXLog(sender)
        let picker = DXPhototPickerController()
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

