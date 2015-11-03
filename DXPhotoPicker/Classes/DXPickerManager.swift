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

class DXPickerManager: NSObject {
    
    private static let sharedInstance = DXPickerManager()
    private var photoLibrary: PHPhotoLibrary
    
    class var sharedManager: DXPickerManager {
        return sharedInstance
    }
    
    override init() {
        photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
        super.init()
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
            userAlbumsOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
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
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
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
                    autoreleasepool {
                        let ab = DXAlbum()
                        ab.count = count
                        ab.results = assetResults
                        ab.name = album.localizedTitle
                        ab.startDate = album.startDate
                        list.append(ab)
                    }
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

    /**
     Fetch the image with the default mode AspectFill 
     'call the method fetchImageWithAsset: targetSize: contentMode: imageResultHandler: 
     'the mode is AspectFill
     
     - parameter asset:              the asset you want to be requested
     - parameter targetSize:         the size customed
     - parameter imageResultHandler: image result
       @image the parameter image in block is the requested image
     
     - returns: PHImageRequestID  so that you can cancel the request if needed
     */
    class func fetchImageWithAsset(asset: PHAsset?, targetSize: CGSize, imageResultHandler: (image: UIImage?)->Void) -> PHImageRequestID? {
        guard asset != nil else {
            return nil
        }
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.Exact
        let scale = UIScreen.mainScreen().scale
        let size = CGSizeMake(targetSize.width*scale, targetSize.height*scale);
        return PHImageManager.defaultManager().requestImageForAsset(asset!,
            targetSize: size,
            contentMode: .AspectFill,
            options: options) {
                (result, info) -> Void in
                imageResultHandler(image: result)
        }
    }
    
    class func fetchImageWithAsset(asset: PHAsset?, targetSize: CGSize, needHighQuality: Bool,imageResultHandler: (image: UIImage?)->Void) -> PHImageRequestID? {
        guard asset != nil else {
            return nil
        }
        let options = PHImageRequestOptions()
        if needHighQuality {
            options.deliveryMode = .HighQualityFormat
        } else {
            options.resizeMode = .Exact
        }
        
        let scale = UIScreen.mainScreen().scale
        let size = CGSizeMake(targetSize.width*scale, targetSize.height*scale);
        return PHImageManager.defaultManager().requestImageForAsset(asset!,
            targetSize: size,
            contentMode: .AspectFit,
            options: options) {
                (result, info) -> Void in
                imageResultHandler(image: result)
        }
    }
    
    class func fetchImageSize(
        asset: PHAsset?,
        imageSizeResultHandler: ((imageSize: Float, sizeString: String) -> Void)) {
        guard asset != nil else {
            return
        }
        PHImageManager.defaultManager().requestImageDataForAsset(asset!,
            options: nil,
            resultHandler: {(data, string, orientation, obj) -> Void in
            var string = "0M"
            var imageSize: Float = 0.0
            guard data != nil else {
                imageSizeResultHandler(imageSize: imageSize, sizeString: string)
                return
            }
            imageSize = Float(data!.length)
            if imageSize > 1024*1024 {
                let size: Float = imageSize/(1024*1024)
                string = "\(size.format("0.1"))" + "M"
                imageSizeResultHandler(imageSize: imageSize, sizeString: string)
            } else {
                let size: Float = imageSize/1024
                string = "\(size.format("0.1"))" + "K"
                imageSizeResultHandler(imageSize: imageSize, sizeString: string)
            }
        })
    }
    
    func fetchImageAssetsViaCollectionResults(results: PHFetchResult?) -> [PHAsset]{
        var resutsArray : Array<PHAsset> = []
        guard results != nil else {
            return resutsArray
        }
        results?.enumerateObjectsUsingBlock({ (asset, index, isStop) -> Void in
            resutsArray.append(asset as! PHAsset)
        })
        return resutsArray
    }
}
