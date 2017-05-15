//
//  DKAssetGroup.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 15/12/13.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

// Group Model
open class DKAssetGroup : NSObject {
	open var groupId: String!
	open var groupName: String!
	open var totalCount: Int!
	
	open var originalCollection: PHAssetCollection!
	open var fetchResult: PHFetchResult<AnyObject>!
}
