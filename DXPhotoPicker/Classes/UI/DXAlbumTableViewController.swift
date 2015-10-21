//
//  DXAlbumTableViewController.swift
//  DXPhotoPickerDemo
//
//  Created by DingXiao on 15/10/16.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

class DXAlbumTableViewController: UITableViewController {

    let dxalbumTableViewCellReuseIdentifier = "dxalbumTableViewCellReuseIdentifier"
    
    var assetsCollection: [DXAlbum]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        assetsCollection = DXPickerManager.sharedManager.fetchAlbumList()
        tableView.registerClass(DXAlbumCell.self, forCellReuseIdentifier: dxalbumTableViewCellReuseIdentifier)
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.assetsCollection != nil else {
            return 0
        }
        return self.assetsCollection!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier(dxalbumTableViewCellReuseIdentifier, forIndexPath: indexPath) as! DXAlbumCell
        let album = self.assetsCollection![indexPath.row]
        cell.titleLabel.text = album.name
        cell.countLabel.text = "(\(album.count))"
        DXPickerManager.fetchImageWithAsset(album.results!.firstObject as? PHAsset, targetSize: CGSizeMake(60, 60)) { (image) -> Void in
            cell.posterImageView.image = image
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
}
