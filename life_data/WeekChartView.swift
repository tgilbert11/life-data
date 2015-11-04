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
        
        CGContextSetRGBStrokeColor(context, 0.75, 0.75, 0.75, 1)
        CGContextSetLineWidth(context, 1)
        for i in 0...8 {
            CGContextMoveToPoint(context, 0, self.bounds.height*(CGFloat(i)+0.5)/9)
            CGContextAddLineToPoint(context, self.bounds.width, self.bounds.height*(CGFloat(i)+0.5)/9)
            CGContextStrokePath(context)
        }
        CGContextSetRGBStrokeColor(context, 0.85, 0.85, 0.85, 1)
        CGContextSetLineWidth(context, 0.3)
        for i in 0...23 {
            if i%3 != 0 {
                CGContextMoveToPoint(context, 0, self.bounds.height*0.5/9 + self.bounds.height*CGFloat(i)/27)
                CGContextAddLineToPoint(context, self.bounds.width, self.bounds.height*0.5/9 + self.bounds.height*CGFloat(i)/27)
                CGContextStrokePath(context)
            }
        }
        
        if sleepData != nil {
            let sleepColor = UIColor(red: 0.01, green: 0.2, blue: 0.01, alpha: 0.8).CGColor
            let snoozeColor = UIColor(red: 0.52, green: 0.06, blue: 0.0, alpha: 0.8).CGColor
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "eee, yyyy-MM-dd HH:mm:ss"
            //            for (date, event) in sleepData! {
            //                print("date: \(dateFormatter.stringFromDate(date)), event: \(event)")
            //            }
            //            print("")
            sleepData!.sortInPlace { $0.date.compare($1.date) == NSComparisonResult.OrderedAscending }
            for (date, event) in sleepData! {
                print("date: \(dateFormatter.stringFromDate(date)), event: \(event)")
            }
            
            dateFormatter.dateFormat = "e"
            
            var state = "unknown"
            var lastDay: Int?
            var leftEdge: CGFloat?
            var width: CGFloat?
            var startingY: CGFloat?
            var previousY: CGFloat?
            var height: CGFloat?
            for (date, event) in sleepData! {
                if lastDay == nil {
                    lastDay = Int(dateFormatter.stringFromDate(date))!
                    var point = CGPointForDate(date, offset: -0.5)
                    leftEdge = point.x
                    startingY = point.y
                    previousY = self.bounds.height*8/9+self.bounds.height*0.5/9
                    point = CGPointForDate(date, offset: 0.5)
                    width = point.x - leftEdge!
                    height = previousY! - startingY!
                }
                let currentDay = Int(dateFormatter.stringFromDate(date))!
                if currentDay != lastDay {
                    lastDay = currentDay
                    var point = CGPointForDate(date, offset: -0.5)
                    if state == "asleep" {
                        CGContextSetFillColorWithColor(context, sleepColor)
                        CGContextFillRect(context, CGRectMake(leftEdge!, self.bounds.height*0.5/9, width!, startingY!-self.bounds.height*0.5/9))
                    }
                    else if state == "snoozing" {
                        CGContextSetFillColorWithColor(context, snoozeColor)
                        CGContextFillRect(context, CGRectMake(leftEdge!, self.bounds.height*0.5/9, width!, startingY!))
                    }
                    leftEdge = point.x
                    point = CGPointForDate(date, offset: 0.5)
                    width = point.x - leftEdge!
                    previousY = self.bounds.height*8/9+self.bounds.height*0.5/9
                    state = "unknown"
                }
                let point = CGPointForDate(date, offset: 0)
                startingY = point.y
                height = previousY! - startingY!
                
                
                if event == "alarmWentOff" {
                    if state == "unknown" || state == "asleep" {
                        CGContextSetFillColorWithColor(context, sleepColor)
                        CGContextFillRect(context, CGRectMake(leftEdge!, startingY!, width!, height!))
                        previousY = startingY!
                        state = "snoozing"
                    }
                }
                else if event == "wokeUp" {
                    if state == "unknown" || state == "asleep" {
                        CGContextSetFillColorWithColor(context, sleepColor)
                        CGContextFillRect(context, CGRectMake(leftEdge!, startingY!, width!, height!))
                        previousY = startingY!
                        state = "awake"
                    }
                    else if state == "snoozing" {
                        CGContextSetFillColorWithColor(context, snoozeColor)
                        CGContextFillRect(context, CGRectMake(leftEdge!, startingY!, width!, height!))
                        previousY = startingY!
                        state = "awake"
                    }
                }
                else if event == "wentToBed" {
                    if state == "unknown" || state == "awake" {
                        previousY = startingY!
                        state = "asleep"
                    }
                }
            }

            
//            CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1)
//            CGContextSetLineWidth(context, 1)
//            CGContextMoveToPoint(context, 0, 0)
//            for (date, _) in sleepData! {
//                let point = CGPointForDate(date, offset: -0.5)
//                CGContextAddLineToPoint(context, point.x, point.y)
//            }
//            CGContextStrokePath(context)
//            CGContextBeginPath(context)
        }
        //print("redrawn")
    }
    
    func CGPointForDate(date: NSDate, offset: CGFloat) -> CGPoint {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //print(dateFormatter.stringFromDate(date))
        dateFormatter.dateFormat = "e"
        let dateString = dateFormatter.stringFromDate(date)
        let dayNumber = Int(dateString)!
        let x = self.bounds.width * (CGFloat(dayNumber) - 0.5 + offset*0.95) / 7
        
        dateFormatter.dateFormat = "HH"
        let hour = Int(dateFormatter.stringFromDate(date))!
        dateFormatter.dateFormat = "mm"
        let minute = Int(dateFormatter.stringFromDate(date))!
        dateFormatter.dateFormat = "ss"
        let second = Int(dateFormatter.stringFromDate(date))!
        let y = (1 - (CGFloat(hour*60*60)+CGFloat(minute*60)+CGFloat(second))/24/60/60) * self.bounds.height*8/9+self.bounds.height*0.5/9
        //print("dow: \(dayNumber), hour: \(hour), minute: \(minute), second: \(second), x: \(x), y: \(y)")
        
        
        return CGPointMake(x, y)
    }
    
}