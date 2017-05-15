//
//  DKImageManager.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/11/29.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

open class DKBaseManager: NSObject {

	fileprivate let observers = NSHashTable<AnyObject>.weakObjects()
	
	open func addObserver(_ object: AnyObject) {
		self.observers.add(object)
	}
	
	open func removeObserver(_ object: AnyObject) {
		self.observers.remove(object)
	}
	
	open func notifyObserversWithSelector(_ selector: Selector, object: AnyObject?) {
		self.notifyObserversWithSelector(selector, object: object, objectTwo: nil)
	}
	
	open func notifyObserversWithSelector(_ selector: Selector, object: AnyObject?, objectTwo: AnyObject?) {
		if self.observers.count > 0 {
			DispatchQueue.main.async(execute: { () -> Void in
				for observer in self.observers.objectEnumerator() {
					if (observer as AnyObject).responds(to: selector) {
						(observer as AnyObject).perform(selector, with: object, with: objectTwo)
					}
				}
			})
		}
	}

}

public func getImageManager() -> DKImageManager {
	return DKImageManager.sharedInstance
}

open class DKImageManager: DKBaseManager {
	
	open class func checkPhotoPermission(_ handler: @escaping (_ granted: Bool) -> Void) {
		func hasPhotoPermission() -> Bool {
			return PHPhotoLibrary.authorizationStatus() == .authorized
		}
		
		func needsToRequestPhotoPermission() -> Bool {
			return PHPhotoLibrary.authorizationStatus() == .notDetermined
		}
		
		hasPhotoPermission() ? handler(true) : (needsToRequestPhotoPermission() ?
			PHPhotoLibrary.requestAuthorization({ status in
				DispatchQueue.main.async(execute: { () in
					hasPhotoPermission() ? handler(true) : handler(false)
				})
			}) : handler(false))
	}
	
	static let sharedInstance = DKImageManager()
	
	fileprivate let manager = PHCachingImageManager.default()
	
	fileprivate lazy var defaultImageRequestOptions: PHImageRequestOptions = {
		let options = PHImageRequestOptions()
		options.deliveryMode = .highQualityFormat
		options.resizeMode = .exact
		
		return options
	}()
	
	fileprivate lazy var defaultVideoRequestOptions: PHVideoRequestOptions = {
		let options = PHVideoRequestOptions()
		options.deliveryMode = .mediumQualityFormat
		
		return options
	}()
	
	open var autoDownloadWhenAssetIsInCloud = true
	
	open let groupDataManager = DKGroupDataManager()
	
	open func invalidate() {
		self.groupDataManager.invalidate()
	}
	
	open func fetchImageForAsset(_ asset: DKAsset, size: CGSize, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		self.fetchImageForAsset(asset, size: size, options: nil, completeBlock: completeBlock)
	}
	
	open func fetchImageForAsset(_ asset: DKAsset, size: CGSize, contentMode: PHImageContentMode, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
			self.fetchImageForAsset(asset, size: size, options: nil, contentMode: contentMode, completeBlock: completeBlock)
	}

	open func fetchImageForAsset(_ asset: DKAsset, size: CGSize, options: PHImageRequestOptions?, completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		self.fetchImageForAsset(asset, size: size, options: options, contentMode: .aspectFill, completeBlock: completeBlock)
	}
	
	open func fetchImageForAsset(_ asset: DKAsset, size: CGSize, options: PHImageRequestOptions?, contentMode: PHImageContentMode,
	                               completeBlock: @escaping (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		let options = (options ?? self.defaultImageRequestOptions).copy() as! PHImageRequestOptions
		self.manager.requestImage(for: asset.originalAsset!,
		                                  targetSize: size,
		                                  contentMode: contentMode,
		                                  options: options,
		                                  resultHandler: { image, info in
											if let isInCloud = (info?[PHImageResultIsInCloudKey] as AnyObject).boolValue, image == nil && isInCloud && self.autoDownloadWhenAssetIsInCloud {
//												var requestCloudOptions = (options ?? self.defaultImageRequestOptions).copy() as! PHImageRequestOptions
//												requestCloudOptions.networkAccessAllowed = true
												options.isNetworkAccessAllowed = true
												self.fetchImageForAsset(asset, size: size, options: options, contentMode: contentMode, completeBlock: completeBlock)
											} else {
												completeBlock(image, info)
											}
		})
	}
	
	open func fetchImageDataForAsset(_ asset: DKAsset, options: PHImageRequestOptions?, completeBlock: @escaping (_ data: Data?, _ info: [AnyHashable: Any]?) -> Void) {
		self.manager.requestImageData(for: asset.originalAsset!,
		                                      options: options ?? self.defaultImageRequestOptions) { (data, dataUTI, orientation, info) in
												if let isInCloud = (info?[PHImageResultIsInCloudKey] as AnyObject).boolValue, data == nil && isInCloud && self.autoDownloadWhenAssetIsInCloud {
													let requestCloudOptions = (options ?? self.defaultImageRequestOptions).copy() as! PHImageRequestOptions
													requestCloudOptions.isNetworkAccessAllowed = true
													self.fetchImageDataForAsset(asset, options: requestCloudOptions, completeBlock: completeBlock)
												} else {
													completeBlock(data, info)
												}
		}
	}
	
	open func fetchAVAsset(_ asset: DKAsset, completeBlock: @escaping (_ avAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
		self.fetchAVAsset(asset, options: nil, completeBlock: completeBlock)
	}
	
	open func fetchAVAsset(_ asset: DKAsset, options: PHVideoRequestOptions?, completeBlock: @escaping (_ avAsset: AVAsset?, _ info: [AnyHashable: Any]?) -> Void) {
		self.manager.requestAVAsset(forVideo: asset.originalAsset!,
			options: options ?? self.defaultVideoRequestOptions) { avAsset, audioMix, info in
				if let isInCloud = (info?[PHImageResultIsInCloudKey] as AnyObject).boolValue, avAsset == nil && isInCloud && self.autoDownloadWhenAssetIsInCloud {
					let requestCloudOptions = (options ?? self.defaultVideoRequestOptions).copy() as! PHVideoRequestOptions
					requestCloudOptions.isNetworkAccessAllowed = true
					self.fetchAVAsset(asset, options: requestCloudOptions, completeBlock: completeBlock)
				} else {
					completeBlock(avAsset, info)
				}
		}
	}
	
}
