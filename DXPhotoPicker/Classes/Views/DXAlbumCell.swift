//
//  DXAlbumCell.swift
//  DXPhotoPickerDemo
//
//  Created by DingXiao on 15/10/21.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit

class DXAlbumCell: UITableViewCell {
    
    lazy var posterImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "assets_placeholder_picture")
        )
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        var label = UILabel(frame: CGRectZero)
        label.backgroundColor = UIColor.whiteColor()
        label.textColor = UIColor.darkTextColor()
        label.textAlignment = NSTextAlignment.Left
        label.font = UIFont.boldSystemFontOfSize(16.0)
        return label
    }()
    lazy var countLabel: UILabel = {
        var label = UILabel(frame: CGRectZero)
        label.backgroundColor = UIColor.whiteColor()
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Left
        label.font = UIFont.systemFontOfSize(14.0)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        
        self.separatorInset = UIEdgeInsetsMake(0,60,0,0)
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let viewBindingsDict = [
            "posterImageView":posterImageView,
            "titleLabel": titleLabel,
            "countLabel": countLabel
        ]
        let mertic = [
            "imageLength": 60
        ]
        
        let vflH = "H:|-0-[posterImageView(imageLength)]-10-[titleLabel(10@750)]-5-[countLabel]-0-|"
        let imageVFLV = "V:|-0-[posterImageView(imageLength)]"
        let contstraintsH: Array = NSLayoutConstraint.constraintsWithVisualFormat(vflH,
            options: NSLayoutFormatOptions.AlignAllCenterY,
            metrics: mertic,
            views: viewBindingsDict)
        let imageContstraintsV: Array =  NSLayoutConstraint.constraintsWithVisualFormat(imageVFLV,
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: mertic,
            views: viewBindingsDict)
        let titleLabelHeightConstraint = NSLayoutConstraint(
            item: titleLabel,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: 40
        )
        let countLabelHeightConstraint = NSLayoutConstraint(
            item: countLabel,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: titleLabel,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1,
            constant: 0
        )
        contentView.addConstraints(contstraintsH)
        contentView.addConstraints(imageContstraintsV)
        contentView.addConstraints([titleLabelHeightConstraint, countLabelHeightConstraint])
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
