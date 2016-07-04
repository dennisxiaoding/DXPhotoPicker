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
        title = DXlocalizedString("albumTitle", comment: "photos")
        createBarButtonItemAtPosition(.Right,
            text: DXlocalizedString("cancel", comment: "取消"),
            action: #selector(DXAlbumTableViewController.cancelAction)
        )
        assetsCollection = DXPickerHelper.fetchAlbumList()
        tableView.registerClass(DXAlbumCell.self, forCellReuseIdentifier: dxalbumTableViewCellReuseIdentifier)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: public
    
    func reloadTableView() {
        assetsCollection = DXPickerHelper.fetchAlbumList()
        tableView.reloadData()
    }
    
    func showUnAuthorizedTipsView() {
        tableView.backgroundView = DXUnAuthorizedTipsView(frame: tableView.bounds)
    }
    
    // MARK: UIActions
    
    @objc private func cancelAction() {
        let photoPicker = navigationController as! DXPhotoPickerController
        photoPicker.photoPickerDelegate?.photoPickerDidCancel?(photoPicker)
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
        DXPickerHelper.fetchImageWithAsset(album.results!.lastObject as? PHAsset, targetSize: CGSizeMake(60, 60)) { (image) -> Void in
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
