//
//  GraphView.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 8/22/15.
//  Copyright (c) 2015 Taylor H. Gilbert. All rights reserved.
//

import UIKit

class GraphView: UIView {

    var drawingPoints: [CGPoint]?
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        //println("here")
        let context = UIGraphicsGetCurrentContext()
        CGContextSetRGBStrokeColor(context, 0.75, 0.75, 0.75, 1)
        CGContextSetLineWidth(context, 1)
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, 0, self.bounds.height)
        CGContextAddLineToPoint(context, self.bounds.width, self.bounds.height)
        CGContextStrokePath(context)
        CGContextSetLineWidth(context, 2)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineJoin(context, CGLineJoin.Round)
        CGContextBeginPath(context)
        var firstPointSet = false
        for point in drawingPoints! {
            if !firstPointSet {
                CGContextMoveToPoint(context, point.x, point.y)
                firstPointSet = true
            }
            else {
                CGContextAddLineToPoint(context, point.x, point.y)
            }
            //println("drawingPoint x: \(point.x), y: \(point.y)")
        }
        CGContextStrokePath(context)
    }
}
