//
//  UIPageViewControllerExtensions.swift
//  Doodlecrop
//
//  Created by Gordon Seto on 2017-04-08.
//  Copyright © 2017 Gordon Seto. All rights reserved.
//

import Foundation
import UIKit

extension UIPageViewController {
    
    func safeSetViewController(_ viewController: UIViewController, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: ((Bool)->())?){
        if !animated {
            setViewControllers([viewController], direction: direction, animated: false, completion: { (completed) in
                completion?(completed)
            })
        } else {
            setViewControllers([viewController], direction: direction, animated: true, completion: { (completed) in
                if completed {
                    DispatchQueue.main.async(execute: {
                        self.setViewControllers([viewController], direction: direction, animated: false, completion: { (completed) in
                            completion?(completed)
                        })
                    })
                } else {
                    completion?(completed)
                }
            })
        }
    }
    
}
