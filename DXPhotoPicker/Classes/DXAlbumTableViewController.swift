//
//  DXAlbumTableViewController.swift
//  DXPhotoPickerDemo
//
//  Created by DingXiao on 15/10/16.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

private class DXAlbumTableViewController: UITableViewController {

    let dxalbumTableViewCellReuseIdentifier = "dxalbumTableViewCellReuseIdentifier"
    
    let assetsCollection: [PHAssetCollection]?  = DXPickerManager.sharedManager.fetchAlbums()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.clearsSelectionOnViewWillAppear = false

        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.assetsCollection != nil else {
            return 0
        }
        return self.assetsCollection!.count
    }
    
    private override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier(dxalbumTableViewCellReuseIdentifier, forIndexPath: indexPath)
        let collection = self.assetsCollection![indexPath.row]
        cell.textLabel?.text = collection.localizedTitle
        DXPickerManager.sharedManager.fetchImageWithAssetCollection(collection, targetSize: CGSizeMake(60, 60)) {(image) -> Void in
            cell.imageView?.image = image
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64;
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
}
