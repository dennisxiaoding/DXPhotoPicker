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
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: dxalbumTableViewCellReuseIdentifier)
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.assetsCollection != nil else {
            return 0
        }
        return self.assetsCollection!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier(dxalbumTableViewCellReuseIdentifier, forIndexPath: indexPath)
        let album = self.assetsCollection![indexPath.row]
        cell.textLabel?.text = album.name! + "(\(album.count))"
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64;
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
}
