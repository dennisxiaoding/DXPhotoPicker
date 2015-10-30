//
//  DXUtil.swift
//  DXPhotosPickerDemo
//
//  Created by Ding Xiao on 15/10/15.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import Foundation

public func DXLog<T>(message: T, file: String = __FILE__, method: String = __FUNCTION__,line: Int = __LINE__) {
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[line:\(line)], \(method): \(message)")
    #endif
}

public func DXlocalizedString(key: String, comment: String) -> String {
    return NSLocalizedString(key, tableName: "DXPhotoPicker", bundle: NSBundle.mainBundle(), value: "", comment: comment)
}


extension Float {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}