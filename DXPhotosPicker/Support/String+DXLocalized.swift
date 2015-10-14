//
//  String+DXLocalized.swift
//  DXPhotosPickerDemo
//
//  Created by Ding Xiao on 15/10/14.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import Foundation

extension String {
    static func dx_localizedStrin(key: String, comment: String) -> String {
        return NSLocalizedString(key, tableName: "DXPhotosPicker", bundle: NSBundle.mainBundle(), value: "", comment: comment)
    }
}