//
//  WeekChartView.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 10/18/15.
//  Copyright © 2015 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import UIKit

class WeekChartView: UIView {
    
    var sleepData: [(date: NSDate, event: String)]?
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        if sleepData != nil {
            CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1)
            CGContextSetLineWidth(context, 1)
            CGContextMoveToPoint(context, 0, 0)
            for (date, _) in sleepData! {
                let point = CGPointForDate(date, offset: -0.5)
                CGContextAddLineToPoint(context, point.x, point.y)
            }
            CGContextStrokePath(context)
            CGContextBeginPath(context)
        }
        //print("redrawn")
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
        CGContextStrokePath(context)
    }
    
    func CGPointForDate(date: NSDate, offset: CGFloat) -> CGPoint {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        //print(dateFormatter.stringFromDate(date))
        dateFormatter.dateFormat = "e"
        let dateString = dateFormatter.stringFromDate(date)
        let dayNumber = Int(dateString)!
        let x = self.bounds.width * (CGFloat(dayNumber) - 0.5 + offset) / 7
        
        dateFormatter.dateFormat = "HH"
        let hour = Int(dateFormatter.stringFromDate(date))!
        dateFormatter.dateFormat = "mm"
        let minute = Int(dateFormatter.stringFromDate(date))!
        dateFormatter.dateFormat = "ss"
        let second = Int(dateFormatter.stringFromDate(date))!
        let y = (1 - (CGFloat(hour*60*60)+CGFloat(minute*60)+CGFloat(second))/24/60/60) * self.bounds.height
        //print("dow: \(dayNumber), hour: \(hour), minute: \(minute), second: \(second), x: \(x), y: \(y)")
        
        
        return CGPointMake(x, y)
    }
    
}