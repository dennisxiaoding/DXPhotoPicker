//
//  DXPickerManager.swift
//  DXPhotoPickerDemo
//
//  Created by Ding Xiao on 15/10/19.
//  Copyright © 2015年 Dennis. All rights reserved.
//

import UIKit
import Photos

private let kDXPickerManagerDefaultAlbumIdentifier = "com.dennis.kDXPhotoPickerStoredGroup"

class DXPickerHelper: NSObject {
    
    class func save(identifier: String?) {
        guard identifier != nil else {
            return
        }
        UserDefaults.standard.set(identifier!, forKey: kDXPickerManagerDefaultAlbumIdentifier)
        UserDefaults.standard.synchronize()
    }
    
    class func fetchAlbumIdentifier() -> String? {
        let string = UserDefaults.standard.object(forKey: kDXPickerManagerDefaultAlbumIdentifier) as? String
        return string
    }
    
    class func fetchAlbum() -> DXAlbum {
        let album = DXAlbum()
        let identifier = fetchAlbumIdentifier()
        guard identifier != nil else {
            return album
        }
        let options = PHFetchOptions()
        options.predicate = NSPredicate(
            format: "mediaType = %d", PHAssetMediaType.image.rawValue
        )
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [identifier!], options: nil)
        if result.count <= 0 {
            return album
        }
    
        let collection = result.firstObject
        let requestResult = PHAsset.fetchAssets(in: collection!, options: options) as? PHFetchResult<AnyObject>
        album.name = collection?.localizedTitle
        album.results = requestResult
        if let count = requestResult?.count {
            album.count = count
        }
        album.startDate = collection?.startDate
        album.identifier = collection?.localIdentifier
        return album
    }
    
    class func fetchAlbumList() -> [DXAlbum]? {
        
        func fetchAlbums() -> [PHFetchResult<PHAssetCollection>]? {
            let userAlbumsOptions = PHFetchOptions()
            userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
            userAlbumsOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
            var albums = [PHFetchResult<PHAssetCollection>]()
            albums.append(
                PHAssetCollection.fetchAssetCollections(
                    with: PHAssetCollectionType.smartAlbum,
                    subtype: PHAssetCollectionSubtype.albumRegular,
                    options: nil)
            )
            albums.append(
                PHAssetCollection.fetchAssetCollections(
                    with: PHAssetCollectionType.album,
                    subtype: PHAssetCollectionSubtype.any,
                    options: userAlbumsOptions)
            )
            return albums
        }
        
        let results = fetchAlbums()
        var list: [DXAlbum] = []
        guard results != nil else {
            return nil
        }
        let options = PHFetchOptions()
        options.predicate = NSPredicate(
            format: "mediaType = %d", PHAssetMediaType.image.rawValue
        )
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        for (_, result) in results!.enumerated() {
            result.enumerateObjects({ (collection, index, isStop) -> Void in
                let album = collection
                let assetResults = PHAsset.fetchAssets(in: album, options: options)
                var count = 0
                switch album.assetCollectionType {
                case .album:
                    count = assetResults.count
                case .smartAlbum:
                    count = assetResults.count
                case .moment:
                    count = 0
                }
                if count > 0 {
                    autoreleasepool {
                        let ab = DXAlbum()
                        ab.count = count
                        ab.results = assetResults as? PHFetchResult<AnyObject>
                        ab.name = album.localizedTitle
                        ab.startDate = album.startDate
                        ab.identifier = album.localIdentifier
                        list.append(ab)
                    }
                }
            })
        }
        return list
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
    @discardableResult
    class func fetchImage(viaAsset asset: PHAsset?, targetSize: CGSize, imageResultHandler: @escaping (_ image: UIImage?)->Void) -> PHImageRequestID? {
        guard asset != nil else {
            return nil
        }
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.exact
        let scale = UIScreen.main.scale
        let size = CGSize(width: targetSize.width * scale, height: targetSize.height * scale)
        return PHCachingImageManager.default().requestImage(for: asset!,
            targetSize: size,
            contentMode: .aspectFill,
            options: options) {
                (result, info) -> Void in
                imageResultHandler(result)
        }
    }
    @discardableResult
    class func fetchImage(viaAsset asset: PHAsset?, targetSize: CGSize, needHighQuality: Bool,imageResultHandler: @escaping (_ image: UIImage?)->Void) -> PHImageRequestID? {
        guard asset != nil else {
            return nil
        }
        let options = PHImageRequestOptions()
        if needHighQuality {
            options.deliveryMode = .highQualityFormat
        } else {
            options.resizeMode = .exact
        }
        
        let scale = UIScreen.main.scale
        let size = CGSize(width: targetSize.width*scale, height: targetSize.height*scale);
        return PHImageManager.default().requestImage(for: asset!,
            targetSize: size,
            contentMode: .aspectFit,
            options: options) {
                (result, info) -> Void in
                imageResultHandler(result)
        }
    }
    
    class func fetchImageSize(
        asset: PHAsset?,
        imageSizeResultHandler: @escaping ((_ imageSize: Float, _ sizeString: String) -> Void)) {
            guard asset != nil else {
                return
            }
            PHImageManager.default().requestImageData(for: asset!,
                options: nil,
                resultHandler: {(data, string, orientation, obj) -> Void in
                    var string = "0M"
                    var imageSize: Float = 0.0
                    guard data != nil else {
                        imageSizeResultHandler(imageSize, string)
                        return
                    }
                    imageSize = Float(data!.count)
                    if imageSize > 1024*1024 {
                        let size: Float = imageSize/(1024*1024)
                        string = "\(size.format("0.1"))" + "M"
                        imageSizeResultHandler(imageSize, string)
                    } else {
                        let size: Float = imageSize/1024
                        string = "\(size.format("0.1"))" + "K"
                        imageSizeResultHandler(imageSize, string)
                    }
            })
    }
    
    class func fetchImageAssets(inCollectionResults results: PHFetchResult<AnyObject>?) -> [PHAsset]{
        var resutsArray : Array<PHAsset> = []
        guard results != nil else {
            return resutsArray
        }
        results?.enumerateObjects({ (asset, index, isStop) -> Void in
            resutsArray.append(asset as! PHAsset)
        })
        return resutsArray
    }
}
