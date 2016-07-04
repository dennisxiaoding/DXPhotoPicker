//
//  DXUtil.swift
//  DXPhotosPickerDemo
//
//  Created by Ding Xiao on 15/10/15.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import Foundation

public func DXLog<T>(message: T, file: String = #file, method: String = #function,line: Int = #line) {
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[line:\(line)], \(method): \(message)")
    #endif
}

public func DXlocalizedString(key: String, comment: String) -> String {
    return NSLocalizedString(key, tableName: "DXPhotoPicker", bundle: NSBundle.mainBundle(), value: "", comment: comment)
}


extension Float {
    func format(f: String) -> String {
        return NSString(format: "%0.1f", self) as String
    }
}