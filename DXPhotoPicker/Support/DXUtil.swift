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