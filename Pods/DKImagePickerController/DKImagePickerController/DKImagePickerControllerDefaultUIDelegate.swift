//
//  DKImagePickerControllerDefaultUIDelegate.swift
//  DKImagePickerControllerDemo
//
//  Created by ZhangAo on 16/3/7.
//  Copyright © 2016年 ZhangAo. All rights reserved.
//

import UIKit

@objc
public class DKImagePickerControllerDefaultUIDelegate: NSObject, DKImagePickerControllerUIDelegate {
	
	public weak var imagePickerController: DKImagePickerController!
	
	public lazy var doneButton: UIButton = {
		return self.createDoneButton()
	}()
	
	public func createDoneButton() -> UIButton {
		let button = UIButton(type: UIButtonType.Custom)
		button.setTitleColor(UINavigationBar.appearance().tintColor ?? self.imagePickerController.navigationBar.tintColor, forState: UIControlState.Normal)
		button.addTarget(self.imagePickerController, action: #selector(DKImagePickerController.done), forControlEvents: UIControlEvents.TouchUpInside)
		self.updateDoneButtonTitle(button)
		
		return button
	}
	
	// Delegate methods...
	
	public func prepareLayout(_ imagePickerController: DKImagePickerController, vc: UIViewController) {
		self.imagePickerController = imagePickerController
		vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneButton)
	}
	
	public func imagePickerControllerCreateCamera(imagePickerController: DKImagePickerController,
	                                              didCancel: @escaping (() -> Void),
	                                              didFinishCapturingImage: @escaping ((_ image: UIImage) -> Void),
	                                              didFinishCapturingVideo: ((_ videoURL: NSURL) -> Void)) -> UIViewController {
		
		let camera = DKCamera()
		
		camera.didCancel = { () -> Void in
			didCancel()
		}
		
		camera.didFinishCapturingImage = { (image) in
			didFinishCapturingImage(image)
		}
		
		self.checkCameraPermission(camera: camera)
	
		return camera
	}
	
	public func layoutForImagePickerController(_ imagePickerController: DKImagePickerController) -> UICollectionViewLayout.Type {
		return DKAssetGroupGridLayout.self
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController,
	                                  showsCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel,
		                                                      target: imagePickerController,
		                                                      action: #selector(DKImagePickerController.dismiss))
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController,
	                                  hidesCancelButtonForVC vc: UIViewController) {
		vc.navigationItem.leftBarButtonItem = nil
	}
	
	public func imagePickerController(imagePickerController: DKImagePickerController, didSelectAsset: DKAsset) {
		self.updateDoneButtonTitle(button: self.doneButton)
	}
    
    public func imagePickerController(imagePickerController: DKImagePickerController, didSelectAssets: [DKAsset]) {
        self.updateDoneButtonTitle(button: self.doneButton)
    }
	
	public func imagePickerController(imagePickerController: DKImagePickerController, didDeselectAsset: DKAsset) {
		self.updateDoneButtonTitle(button: self.doneButton)
	}
    
    public func imagePickerController(imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset]) {
        self.updateDoneButtonTitle(button: self.doneButton)
    }
	
	public func imagePickerControllerDidReachMaxLimit(_ imagePickerController: DKImagePickerController) {
        let alert = UIAlertController(title: DKImageLocalizedStringWithKey("maxLimitReached")
            , message:String(format: DKImageLocalizedStringWithKey("maxLimitReachedMessage"), imagePickerController.maxSelectableCount)
            , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: DKImageLocalizedStringWithKey("ok"), style: .cancel) { _ in })
        imagePickerController.present(alert, animated: true){}
	}
	
	public func imagePickerControllerFooterView(_ imagePickerController: DKImagePickerController) -> UIView? {
		return nil
	}
    
    public func imagePickerControllerCameraImage() -> UIImage {
        return DKImageResource.cameraImage()
    }
    
    public func imagePickerControllerCheckedNumberColor() -> UIColor {
        return UIColor.white
    }
    
    public func imagePickerControllerCheckedNumberFont() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 14)
    }
    
    public func imagePickerControllerCheckedImageTintColor() -> UIColor? {
        return nil
    }
    
    public func imagePickerControllerCollectionViewBackgroundColor() -> UIColor {
        return UIColor.white
    }
	
	// Internal
	
	public func checkCameraPermission(camera: DKCamera) {
		func cameraDenied() {
            DispatchQueue.main.async {
                let permissionView = DKPermissionView.permissionView(.camera)
                camera.cameraOverlayView = permissionView
            }
		}
		
		func setup() {
			camera.cameraOverlayView = nil
		}
		
		DKCamera.checkCameraPermission { granted in
			granted ? setup() : cameraDenied()
		}
	}
	
	public func updateDoneButtonTitle(button: UIButton) {
		if self.imagePickerController.selectedAssets.count > 0 {
			button.setTitle(String(format: DKImageLocalizedStringWithKey("select"), self.imagePickerController.selectedAssets.count), for: UIControlState.normal)
		} else {
			button.setTitle(DKImageLocalizedStringWithKey("done"), for: UIControlState.normal)
		}
		
		button.sizeToFit()
	}
	
}
