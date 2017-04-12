//
//  CustomBackground.swift
//  CapGemini_Weather
//
//  Created by Aubert Charles on 08/02/2017.
//  Copyright © 2017 Charles. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

class BackgroundView: UIView {
    
    //# MARK: - Variables
    @IBInspectable var lightColor: UIColor = UIColor.orange
    @IBInspectable var darkColor: UIColor = UIColor.yellow
    @IBInspectable var patternSize:CGFloat = 200
    //# MARK: - END of variables

    
    
    
    
    
    
    
    
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let drawSize = CGSize(width: patternSize, height: patternSize)
        
        context?.setFillColor(darkColor.cgColor)
        context?.fill(rect)
        UIGraphicsBeginImageContextWithOptions(drawSize, true, 0.0)
        let drawingContext = UIGraphicsGetCurrentContext()
        darkColor.setFill()
        drawingContext?.fill(CGRect(x: 0, y: 0, width: drawSize.width, height: drawSize.height))
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x:drawSize.width/2,
                                      y:0))
        trianglePath.addLine(to: CGPoint(x:0,
                                         y:drawSize.height/2))
        trianglePath.addLine(to: CGPoint(x:drawSize.width,
                                         y:drawSize.height/2))
        trianglePath.move(to: CGPoint(x: 0,
                                      y: drawSize.height/2))
        trianglePath.addLine(to: CGPoint(x: drawSize.width/2,
                                         y: drawSize.height))
        trianglePath.addLine(to: CGPoint(x: 0,
                                         y: drawSize.height))
        trianglePath.move(to: CGPoint(x: drawSize.width,
                                      y: drawSize.height/2))
        trianglePath.addLine(to: CGPoint(x:drawSize.width/2,
                                         y:drawSize.height))
        trianglePath.addLine(to: CGPoint(x: drawSize.width,
                                         y: drawSize.height))
        lightColor.setFill()
        trianglePath.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIColor(patternImage: image!).setFill()
        context?.fill(rect)
    }
}
