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
        title = DXlocalized(string: "albumTitle", comment: "photos")
        createBarButtonItemAt(position: .right,
                              text: DXlocalized(string: "cancel", comment: "取消"),
            action: #selector(DXAlbumTableViewController.cancelAction)
        )
        assetsCollection = DXPickerHelper.fetchAlbumList()
        tableView.register(DXAlbumCell.self, forCellReuseIdentifier: dxalbumTableViewCellReuseIdentifier)
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
        photoPicker.photoPickerDelegate?.photoPickerDidCancel?(photoPicker: photoPicker)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard assetsCollection != nil else {
            return 0
        }
        return assetsCollection!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: dxalbumTableViewCellReuseIdentifier, for: indexPath as IndexPath) as! DXAlbumCell
        let album = assetsCollection![indexPath.row]
        cell.titleLabel.text = album.name
        cell.countLabel.text = "(\(album.count))"
        DXPickerHelper.fetchImage(viaAsset: album.results!.lastObject as? PHAsset, targetSize: CGSize(width:60, height:60)) { (image) -> Void in
            cell.posterImageView.image = image
        }
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - Table view data delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let album = assetsCollection![indexPath.row]
        let photosListViewController = DXImageFlowViewController(album: album)
        navigationController?.pushViewController(photosListViewController, animated: true)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}
