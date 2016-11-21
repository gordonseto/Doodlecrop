DKCamera
=======================

 [![Build Status](https://secure.travis-ci.org/zhangao0086/DKCamera.svg)](http://travis-ci.org/zhangao0086/DKCamera) [![Version Status](http://img.shields.io/cocoapods/v/DKCamera.png)][docsLink] [![license MIT](http://img.shields.io/badge/license-MIT-orange.png)][mitLink]
<img width="50%" height="50%" src="https://raw.githubusercontent.com/zhangao0086/DKCamera/develop/Screenshot1.png" />
---

---
## Description
A light weight & simple & easy camera for iOS by Swift. It uses `CoreMotion` framework to detect device orientation, so the screen-orientation lock will be ignored(*Perfect orientation handling*). And it has two other purposes:

* Can be presenting or pushing or Integrating.
* Suppressing the warning **"Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates."**(It seems a bug in iOS 8).

## Requirements
* iOS 7.1+
* ARC

## Installation
#### iOS 8 and newer
DKCamera is available on CocoaPods. Simply add the following line to your podfile:

```ruby
# For latest release in cocoapods
pod 'DKCamera'
```

#### iOS 7.x
To use Swift libraries on apps that support iOS 7, you must manually copy the files into your application project.
[CocoaPods only supports Swift on OS X 10.9 and newer, and iOS 8 and newer.](https://github.com/CocoaPods/blog.cocoapods.org/commit/6933ae5ccfc1e0b39dd23f4ec67d7a083975836d)

## Easy to use

```swift
let camera = DKCamera()

camera.didCancel = { () in
	print("didCancel")

	self.dismissViewControllerAnimated(true, completion: nil)
}

camera.didFinishCapturingImage = {(image: UIImage) in
	print("didFinishCapturingImage")
	print(image)

	self.dismissViewControllerAnimated(true, completion: nil)
}
self.presentViewController(camera, animated: true, completion: nil)

````

### You also can use these APIs:

```swift
public var cameraOverlayView: UIView?

/// The flashModel will to be remembered to next use.
public var flashMode:AVCaptureFlashMode = .Auto

public class func isAvailable() -> Bool

/// Determines whether or not the rotation is enabled.
public var allowsRotate = false
```

> If you are going to add a full-screen view as `cameraOverlayView`, maybe you should use the `DKCameraPassthroughView` or its subclass that have overriden the `hitTest` method in order to the event passes through to the expected view.
```swift
//  DKCamera.swift
public class DKCameraPassthroughView: UIView {
	public override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
		let hitTestingView = super.hitTest(point, withEvent: event)
		return hitTestingView == self ? nil : hitTestingView
	}
}
```

## License
DKCamera is released under the MIT license. See LICENSE for details.

[docsLink]:http://cocoadocs.org/docsets/DKCamera
[mitLink]:http://opensource.org/licenses/MIT
