//
//  ImageFetcher.swift
//  ImagePicker
//
//  Created by 杨 on 2020/4/1.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit
import Photos
import Localizable

public class ImageFetcher: NSObject {
    public enum Folder : String {
        case all
        /// 相册
        case cameralRoll
        /// 视频
        case videos
        /// 音频
        case audios
        /// 最近添加
        case recentlyAdd
        /// 收藏
        case favourites
        
        /// An album created in the Photos app.
        case albumRegular
        /// 同步事件
        @available(iOS 8, *)
        case syncedEvent
        /// 人脸
        @available(iOS 8, *)
        case faces
        /// An album synced to the device from iPhoto.
        @available(iOS 8, *)
        case syncedAlbum
        /// 导入项目
        @available(iOS 8, *)
        case imported
        // PHAssetCollectionTypeAlbum shared subtypes
        @available(iOS 8, *)
        case photoStream
        @available(iOS 8, *)
        case cloudShared
        // PHAssetCollectionTypeSmartAlbum subtypes
        /// A smart album of no more specific subtype.
        @available(iOS 8, *)
        case albumGeneric
        /// 全景
        @available(iOS 8, *)
        case panoramas
        /// 延时摄影
        @available(iOS 8, *)
        case timelapses
        /// 隐藏
        @available(iOS 8, *)
        case allHidden
        /// 连拍
        @available(iOS 8, *)
        case bursts
        /// 慢动作
        @available(iOS 8, *)
        case slomoVideos
        /// 自拍
        @available(iOS 9, *)
        case selfPortraits
        /// 屏幕截图
        @available(iOS 9, *)
        case screenshots
        /// 景深(人像)
        @available(iOS 10.2, *)
        case depthEffect
        /// 实况照片
        @available(iOS 10.3, *)
        case livePhotos
        /// 动图
        @available(iOS 11, *)
        case animated
        /// 长曝光
        @available(iOS 11, *)
        case longExposures
        /// 无法上传
        @available(iOS 13, *)
        case unableToUpload
        
        var mediaType : PHAssetMediaType? {
            switch self {
            case .videos:
                return .video
            case .audios:
                return .audio
            case .cameralRoll:
                return .image
            default:
                return nil
            }
        }
        
        var subType : PHAssetCollectionSubtype? {
            switch self {
            case .all:
                return nil
            case .cameralRoll:
                return .smartAlbumUserLibrary
            case .recentlyAdd:
                return .smartAlbumRecentlyAdded
            case .favourites:
                return .smartAlbumFavorites
            case .videos:
                return .smartAlbumVideos
            case .audios:
                return nil
            case .albumRegular:
                return .albumRegular
            case .syncedEvent:
                return .albumSyncedEvent
            case .faces:
                return .albumSyncedFaces
            case .syncedAlbum:
                return .albumSyncedAlbum
            case .imported:
                return .albumImported
            case .photoStream:
                return .albumMyPhotoStream
            case .cloudShared:
                return .albumCloudShared
            case .albumGeneric:
                return .smartAlbumGeneric
            case .panoramas:
                return .smartAlbumPanoramas
            case .timelapses:
                return .smartAlbumTimelapses
            case .allHidden:
                return .smartAlbumAllHidden
            case .bursts:
                return .smartAlbumBursts
            case .slomoVideos:
                return .smartAlbumSlomoVideos
            case .selfPortraits:
                return .smartAlbumSelfPortraits
            case .screenshots:
                return .smartAlbumScreenshots
            case .depthEffect:
                return .smartAlbumDepthEffect
            case .livePhotos:
                return .smartAlbumLivePhotos
            case .animated:
                return .smartAlbumAnimated
            case .longExposures:
                return .smartAlbumLongExposures
            case .unableToUpload:
                return .smartAlbumUnableToUpload
            }
        }
    }
    
    lazy var fetchOptions: PHFetchOptions = {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return options
    }()
    
    public func fetchAll(with options: PHFetchOptions?) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(with: options)
    }
    
    public func fetchAssets(with mediaType: PHAssetMediaType, options: PHFetchOptions?) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(with: mediaType, options: options)
    }
    
    public func fetchAssets(in collection : PHAssetCollection,options: PHFetchOptions?) -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(in: collection, options: options)
    }
    
    public func fetchTopLevelUserCollections(with options: PHFetchOptions?) -> PHFetchResult<PHCollection> {
        return PHAssetCollection.fetchTopLevelUserCollections(with: options)
    }
    
    public func fetchAssetCollections(with type: PHAssetCollectionType, subtype: PHAssetCollectionSubtype, options: PHFetchOptions?) -> PHFetchResult<PHAssetCollection> {
        return PHAssetCollection.fetchAssetCollections(with: type, subtype: subtype, options: options)
    }
    
    public func fetchAssets(in folder : Folder,with options : PHFetchOptions?) -> PHFetchResult<PHAsset>? {
        switch folder {
        case .all:
            return fetchAll(with: options)
        case .cameralRoll,.videos,.audios:
            return fetchMediaType(in: folder, options: options)
        default:
            return fetchSubType(in: folder, options: options)
        }
    }
    
    public func fetchMediaType(in folder : Folder,options : PHFetchOptions?) -> PHFetchResult<PHAsset>? {
        if let mediaType = folder.mediaType {
            return fetchAssets(with: mediaType, options: options)
        } else {
            return nil
        }
    }
    
    public func fetchSubType(in folder : Folder,options : PHFetchOptions?) -> PHFetchResult<PHAsset>? {
        if let subType = folder.subType {
            let collection = fetchAssetCollections(with: .smartAlbum, subtype: subType, options: options)
            var result : [PHFetchResult<PHAsset>] = []
            collection.enumerateObjects { (col, index, _) in
                result.append(self.fetchAssets(in: col, options: options))
            }
            return result.first
        }
        return nil
    }

}

extension ImageFetcher.Folder : Localizable {
    public var key: String {
        return ImagePickerConstants.localizedPrefix + self.rawValue
    }

    public var value: String {
        return self.rawValue
    }
}
