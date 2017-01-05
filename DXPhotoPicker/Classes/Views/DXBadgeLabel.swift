//
//  DXBadgeLabel.swift
//  DXPhotoPickerDemo
//
//  Created by DingXiao on 15/10/16.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

class DXBadgeLabel: UIView {

    var title: String?
    
    private lazy var backgroundView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor(hexColor: "#1FB823")
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var badgeLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        return label
    }()
}
