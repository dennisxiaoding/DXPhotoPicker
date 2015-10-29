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
        self.title = DXlocalizedString("albumTitle", comment: "photos")
        self.createBarButtonItemAtPosition(.Right,
            text: DXlocalizedString("cancel", comment: "取消"),
            action: Selector("cancelAction")
        )
        self.clearsSelectionOnViewWillAppear = true
        self.assetsCollection = DXPickerManager.sharedManager.fetchAlbumList()
        self.tableView.registerClass(DXAlbumCell.self, forCellReuseIdentifier: dxalbumTableViewCellReuseIdentifier)
        self.tableView.tableFooterView = UIView()
    }
    
    // MARK: UIActions
    
    @objc private func cancelAction() {
        let photoPicker = navigationController as! DXPhototPickerController
        if (photoPicker.photoPickerDelegate != nil && photoPicker.photoPickerDelegate!.respondsToSelector(Selector("photoPickerDidCancel:"))) {
            photoPicker.photoPickerDelegate!.photoPickerDidCancel!(photoPicker)
        }
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard assetsCollection != nil else {
            return 0
        }
        return assetsCollection!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCellWithIdentifier(dxalbumTableViewCellReuseIdentifier, forIndexPath: indexPath) as! DXAlbumCell
        let album = assetsCollection![indexPath.row]
        cell.titleLabel.text = album.name
        cell.countLabel.text = "(\(album.count))"
        DXPickerManager.fetchImageWithAsset(album.results!.lastObject as? PHAsset, targetSize: CGSizeMake(60, 60)) { (image) -> Void in
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
    
    // MARK: - Table view data delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let album = assetsCollection![indexPath.row]
        let photosListViewController = DXImageFlowViewController(album: album)
        navigationController?.pushViewController(photosListViewController, animated: true)
    }
}
