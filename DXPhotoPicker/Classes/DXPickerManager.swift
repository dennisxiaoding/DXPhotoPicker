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
    
    private var photoLibrary: PHPhotoLibrary 
    
    class var sharedManager: DXPickerManager {
        return sharedInstance
    }
    
    init() {
        photoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
    }
    
    var mediaType: DXPhototPickerMediaType = DXPhototPickerMediaType.Unknow

    lazy var defultAlbum: String? = {
        let string = NSUserDefaults.standardUserDefaults().objectForKey(kDXPickerManagerDefaultAlbumName) as? String
        return string
    }()
    
    
    func fetchAlbums() -> [PHAssetCollection]? {
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0 and mediaType = \(fetchTypeViaMediaType(self.mediaType))")
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: userAlbumsOptions)
        var albums: [PHAssetCollection] = []
        
        userAlbums.enumerateObjectsUsingBlock { (collection, idx, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            albums.append(collection as! PHAssetCollection)
        }
        
        return albums
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
    
    func fetchImageWithAssetCollection(collection: PHAssetCollection, targetSize: CGSize, imageResultHandler: (image: UIImage?)->Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0 and mediaType = \(fetchTypeViaMediaType(self.mediaType))")
        let fetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: fetchOptions)
        let asset = fetchResult.firstObject as? PHAsset
        let options = PHImageRequestOptions()
        options.resizeMode = PHImageRequestOptionsResizeMode.Exact
        let scale = UIScreen.mainScreen().scale
        let size = CGSizeMake(targetSize.width*scale, targetSize.height*scale);
        PHImageManager.defaultManager().requestImageForAsset(asset!, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: options) { (result, info) -> Void in
            imageResultHandler(image: result)
        }

    }
    
}
