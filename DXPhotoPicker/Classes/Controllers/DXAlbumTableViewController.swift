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
        self.tableView.register(DXAlbumCell.self, forCellReuseIdentifier: dxalbumTableViewCellReuseIdentifier)

        self.tableView.tableFooterView = UIView()
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: dxalbumTableViewCellReuseIdentifier, for: indexPath) as! DXAlbumCell
        let album = assetsCollection![indexPath.row]
        cell.titleLabel.text = album.name
        cell.countLabel.text = "(\(album.count))"
        DXPickerHelper.fetchImage(viaAsset: album.results!.lastObject as? PHAsset, targetSize: CGSize(width:60, height:60)) { (image) -> Void in
            cell.posterImageView.image = image
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    // MARK: - Table view data delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = assetsCollection![indexPath.row]
        let photosListViewController = DXImageFlowViewController(album: album)
        navigationController?.pushViewController(photosListViewController, animated: true)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
   
}
