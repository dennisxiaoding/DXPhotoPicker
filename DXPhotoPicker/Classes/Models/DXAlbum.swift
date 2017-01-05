//
//  DXAlbum.swift
//  DXPhotoPickerDemo
//
//  Created by Ding Xiao on 15/10/21.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

 /*
    @note use this model to store the album's 'result, 'count, 'name, 'startDate 
    to avoid request and reserve too much times.
 */

class DXAlbum: NSObject {
    var results: PHFetchResult<AnyObject>?
    var count = 0
    var name: String?
    var startDate: Date?
    var identifier: String?
}
