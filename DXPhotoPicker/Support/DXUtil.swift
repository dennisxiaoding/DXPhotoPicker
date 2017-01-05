//
//  DXUtil.swift
//  DXPhotosPickerDemo
//
//  Created by Ding Xiao on 15/10/15.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import Foundation

public func DXLog<T>(_ message: T, file: String = #file, method: String = #function,line: Int = #line) {
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[line:\(line)], \(method): \(message)")
    #endif
}

public func DXlocalized(string: String, comment: String) -> String {
    return NSLocalizedString(string, tableName: "DXPhotoPicker", bundle: Bundle.main, value: "", comment: comment)
}


extension Float {
    func format(_ f: String) -> String {
        return NSString(format: "%0.1f", self) as String
    }
}
