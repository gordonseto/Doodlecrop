//
//  DKGroupDataManager.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/12/16.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

@objc
protocol DKGroupDataManagerObserver {
	
	@objc optional func groupDidUpdate(_ groupId: String)
	@objc optional func groupDidRemove(_ groupId: String)
	@objc optional func group(_ groupId: String, didRemoveAssets assets: [DKAsset])
	@objc optional func group(_ groupId: String, didInsertAssets assets: [DKAsset])
}

open class DKGroupDataManager: DKBaseManager, PHPhotoLibraryChangeObserver {

	fileprivate var groups: [String : DKAssetGroup]?
	open var groupIds: [String]?
	
	open var assetGroupTypes: [PHAssetCollectionSubtype]?
	open var assetFetchOptions: PHFetchOptions?
	open var showsEmptyAlbums: Bool = true
	
	deinit {
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}
	
	open func invalidate() {
		self.groupIds?.removeAll()
		self.groupIds = nil
		self.groups?.removeAll()
		self.groups = nil
		
		PHPhotoLibrary.shared().unregisterChangeObserver(self)
	}
	
	open func fetchGroups(_ completeBlock: (_ groups: [String]?, _ error: NSError?) -> Void) {
		if let assetGroupTypes = self.assetGroupTypes {
			if self.groups != nil {
				completeBlock(self.groupIds, nil)
				return
			}
			
			var groups: [String : DKAssetGroup] = [:]
			var groupIds: [String] = []
			
			for (_, groupType) in assetGroupTypes.enumerated() {
				let fetchResult = PHAssetCollection.fetchAssetCollections(with: self.collectionTypeForSubtype(groupType),
				                                                                  subtype: groupType,
				                                                                  options: nil)
                fetchResult.enumerateObjects( { object, index, stop in
                    if let collection = object as? PHAssetCollection {
                        let assetGroup = DKAssetGroup()
                        assetGroup.groupId = collection.localIdentifier
                        self.updateGroup(assetGroup, collection: collection)
                        if self.showsEmptyAlbums || assetGroup.totalCount > 0 {
                            groups[assetGroup.groupId] = assetGroup
                            groupIds.append(assetGroup.groupId)
                        }
                    }
                })
			}
			self.groups = groups
			self.groupIds = groupIds
			
			PHPhotoLibrary.shared().register(self)
			completeBlock(groupIds, nil)
		}
	}
	
	open func fetchGroupWithGroupId(_ groupId: String) -> DKAssetGroup {
		return self.groups![groupId]!
	}
	
	open func fetchGroupThumbnailForGroup(_ groupId: String, size: CGSize, options: PHImageRequestOptions, completeBlock: (_ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void) {
		let group = self.fetchGroupWithGroupId(groupId)
		if group.fetchResult.count == 0 {
			completeBlock(nil, nil)
			return
		}
		
		let latestAsset = DKAsset(originalAsset:group.fetchResult.firstObject as! PHAsset)
		latestAsset.fetchImageWithSize(size, options: options, completeBlock: completeBlock)
	}
	
	open func fetchAssetWithGroup(_ group: DKAssetGroup, index: Int) -> DKAsset {
		let asset = DKAsset(originalAsset:group.fetchResult[index] as! PHAsset)
		return asset
	}
	
	// MARK: - Private methods
	
	fileprivate func collectionTypeForSubtype(_ subtype: PHAssetCollectionSubtype) -> PHAssetCollectionType {
		return subtype.rawValue < PHAssetCollectionSubtype.smartAlbumGeneric.rawValue ? .album : .smartAlbum
	}
	
	fileprivate func updateGroup(_ group: DKAssetGroup, collection: PHAssetCollection) {
		group.groupName = collection.localizedTitle
		self.updateGroup(group, fetchResult: PHAsset.fetchAssets(in: collection, options: self.assetFetchOptions) as! PHFetchResult<AnyObject>)
		group.originalCollection = collection
	}
	
	fileprivate func updateGroup(_ group: DKAssetGroup, fetchResult: PHFetchResult<AnyObject>) {
		group.fetchResult = fetchResult
		group.totalCount = group.fetchResult.count
	}
	
	// MARK: - PHPhotoLibraryChangeObserver methods
	
	open func photoLibraryDidChange(_ changeInstance: PHChange) {
		for group in self.groups!.values {
			if let changeDetails = changeInstance.changeDetails(for: group.originalCollection) {
				if changeDetails.objectWasDeleted {
					self.groups![group.groupId] = nil
					self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.groupDidRemove(_:)), object: group.groupId as AnyObject)
					continue
				}
				
				if let objectAfterChanges = changeDetails.objectAfterChanges as? PHAssetCollection {
					self.updateGroup(self.groups![group.groupId]!, collection: objectAfterChanges)
					self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.groupDidUpdate(_:)), object: group.groupId as AnyObject)
				}
			}
			
			if let changeDetails = changeInstance.changeDetails(for: group.fetchResult as! PHFetchResult<T>) {
				if let removedIndexes = changeDetails.removedIndexes {
					var removedAssets = [DKAsset]()
					(removedIndexes as NSIndexSet).enumerate({ index, stop in
						removedAssets.append(self.fetchAssetWithGroup(group, index: index))
					})
					self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.group(_:didRemoveAssets:)), object: group.groupId as AnyObject, objectTwo: removedAssets)
				}
				self.updateGroup(group, fetchResult: changeDetails.fetchResultAfterChanges)
				
				if changeDetails.insertedObjects.count > 0  {
					var insertedAssets = [DKAsset]()
					for insertedAsset in changeDetails.insertedObjects {
						insertedAssets.append(DKAsset(originalAsset: insertedAsset as! PHAsset))
					}
					self.notifyObserversWithSelector(#selector(DKGroupDataManagerObserver.group(_:didInsertAssets:)), object: group.groupId as AnyObject, objectTwo: insertedAssets)
				}
			}
		}
	}

}
