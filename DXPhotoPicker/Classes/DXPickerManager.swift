//
//  DXPickerManager.swift
//  DXPhotoPickerDemo
//
//  Created by Ding Xiao on 15/10/19.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

let kDXPickerManagerDefaultAlbumName = "com.dennis.kDXPhotoPickerStoredGroup"

class DXPickerManager {
    
    private static let sharedInstance = DXPickerManager()
    
    var photoLibrary: PHPhotoLibrary 
    
    class var sharedManager: DXPickerManager {
        return sharedInstance
    }
    
    init() {
        photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    }
    
    var mediaType: DXPhototPickerMediaType = DXPhototPickerMediaType.Image

    lazy var defultAlbum: String? = {
        let string = NSUserDefaults.standardUserDefaults().objectForKey(kDXPickerManagerDefaultAlbumName) as? String
        return string
    }()
    
    func fetchAlbumList() -> [DXAlbum] {
        
        func fetchAlbums() -> [PHFetchResult]? {
            let userAlbumsOptions = PHFetchOptions()
            userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
            userAlbumsOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            var albums: [PHFetchResult] = []
            albums.append(
                PHAssetCollection.fetchAssetCollectionsWithType(
                    PHAssetCollectionType.SmartAlbum,
                    subtype: PHAssetCollectionSubtype.AlbumRegular,
                    options: nil)
            )
            albums.append(
                PHAssetCollection.fetchAssetCollectionsWithType(
                    PHAssetCollectionType.Album,
                    subtype: PHAssetCollectionSubtype.Any,
                    options: userAlbumsOptions)
            )
            return albums
        }

        let results = fetchAlbums()
        var list: [DXAlbum] = []
        guard results != nil else {
            return list
        }
        let options = PHFetchOptions()
        options.predicate = NSPredicate(
            format: "mediaType = %d", self.fetchTypeViaMediaType(self.mediaType).rawValue
        )
        for (_, result) in results!.enumerate() {
            result.enumerateObjectsUsingBlock({ (collection, index, isStop) -> Void in
                let album = collection as! PHAssetCollection
                let assetResults = PHAsset.fetchAssetsInAssetCollection(album, options: options)
                var count = 0
                switch album.assetCollectionType {
                case .Album:
                    count = assetResults.count
                case .SmartAlbum:
                    count = assetResults.count
                case .Moment:
                    count = 0
                }
                if count > 0 {
                    let ab = DXAlbum()
                    ab.count = count
                    ab.results = assetResults
                    ab.name = album.localizedTitle
                    ab.startDate = album.startDate
                    list.append(ab)
                }
            })
        }
        return list
    }
    
    private func fetchTypeViaMediaType(meidaType: DXPhototPickerMediaType) -> PHAssetMediaType {
        var type: PHAssetMediaType = PHAssetMediaType.Unknown
        switch (meidaType) {
        case .Unknow:
            type = .Unknown
        case .Image:
            type = .Image
        case .Video:
            type = .Video
        case .All: break
        }
        return type
    }
    
    class func fetchImageWithAsset(asset: PHAsset?, targetSize: CGSize, imageResultHandler: (image: UIImage?)->Void) {
        guard asset != nil else {
            return
        }
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.Exact
        let scale = UIScreen.mainScreen().scale
        let size = CGSizeMake(targetSize.width*scale, targetSize.height*scale);
        PHCachingImageManager.defaultManager()
        PHImageManager.defaultManager().requestImageForAsset(asset!,
            targetSize: size,
            contentMode: PHImageContentMode.AspectFill,
            options: options) {
                (result, info) -> Void in
                imageResultHandler(image: result)
        }
    }
    
}
