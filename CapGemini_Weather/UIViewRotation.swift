//
//  UIViewRotation.swift
//  CapGemini_Weather
//
//  Created by Aubert Charles on 23/03/2017.
//  Copyright © 2017 Charles. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func rotate360Degrees(_ duration: CFTimeInterval = 1.0, completionDelegate: CAAnimationDelegate? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2.0)
        rotateAnimation.duration = duration
        
        if let delegate: CAAnimationDelegate = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
