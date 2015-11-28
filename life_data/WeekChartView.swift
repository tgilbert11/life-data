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
    
    var processedData: [(date: NSDate, category: String, event: String)] = []
    var initializationComplete: Bool = false
    
    // sleep, snooze, drive
    // gradient: <0 for known end time, 0 for filled, >0 for known start time
    var rectangles: [(startDate: NSDate, endDate: NSDate, eventType: String, gradient: Int)] = []
    
    // drinks: alcohol, water, coffee, otherDrink
    var lines: [(date: NSDate, eventType: String)] = []
    
    let sleepColor = UIColor(red: 0.01, green: 0.2, blue: 0.01, alpha: 0.7).CGColor
    let snoozeColor = UIColor(red: 0.42, green: 0.05, blue: 0.0, alpha: 0.7).CGColor
    let driveColor = UIColor(red: 0.24, green: 0.24, blue: 0.35, alpha: 0.6).CGColor
    let gradientHeightInSeconds = 30*60
    
    let alcoholColor = UIColor(red: 0.8, green: 0, blue: 0, alpha: 1).CGColor
    let coffeeColor = UIColor(red: 0.54, green: 0.26, blue: 0, alpha: 1).CGColor
    let waterColor = UIColor(red: 0.07, green: 0.41, blue: 0.85, alpha: 1).CGColor
    let otherDrinkColor = UIColor(red: 0.07, green: 0.41, blue: 0.85, alpha: 1).CGColor
    let drinkLineWidth = CGFloat(1)
    let drinkOffset = CGFloat(0.3)
    
    //let mealColor = UIColor(red: 0.77, green: 0.69, blue: 0, alpha: 1).CGColor
    let mealColor = UIColor(red: 0.1, green: 0, blue: 0, alpha: 0.6).CGColor
    let mealLineWidth = CGFloat(4)
    let breakfastOffset = CGFloat(0.25)
    let brunchOffset = CGFloat(0.3)
    let lunchOffset = CGFloat(0.35)
    let snackOffset = CGFloat(0.15)
    let dinnerOffset = CGFloat(0.375)
    
    
    
    func createGraphicsObjects() {
        
        processedData.sortInPlace { $0.date.compare($1.date) == NSComparisonResult.OrderedAscending }
        
        let today = NSDate()
        let dateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .TimeZone], fromDate: today)
        let startOfToday = NSCalendar.currentCalendar().dateFromComponents(dateComponents)!
        let startOfWeek = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -6, toDate: startOfToday, options: [])!
        
        
        // Sleep
        //    states: unknown, sleeping, snoozing, awake
        //    events: wokeUp, wokeUpFromNap, wentToBed, tookANap, alarmWentOff
        var state = "unknown"
        var dateOfLastStateChange = startOfWeek
        for event in processedData {
            if event.category == "sleep" {
                switch event.event {
                case "wokeUp", "wokeUpFromNap":
                    switch state {
                    case "unknown": // woke up from unknown
                        rectangles += [(startDate: dateOfLastStateChange, endDate: event.date, eventType: "sleep", gradient: -1)]
                        state = "awake"
                        dateOfLastStateChange = event.date
                    case "sleeping": // woke up from sleeping
                        let indexOfMostRecentSleepRectangle = getIndexOfMostRecentRectangleOfEventType("sleep")
                        if indexOfMostRecentSleepRectangle != nil {
                            let mostRecentSleepRectangle = rectangles[indexOfMostRecentSleepRectangle!]
                            if mostRecentSleepRectangle.gradient > 0 {
                                rectangles.removeAtIndex(indexOfMostRecentSleepRectangle!)
                            }
                        }
                        rectangles += [(startDate: dateOfLastStateChange, endDate: event.date, eventType: "sleep", gradient: 0)]
                        state = "awake"
                        dateOfLastStateChange = event.date
                    case "snoozing": // woke up from snoozing
                        let indexOfMostRecentSnoozeRectangle = getIndexOfMostRecentRectangleOfEventType("snooze")
                        if indexOfMostRecentSnoozeRectangle != nil {
                            let mostRecentSnoozeRectangle = rectangles[indexOfMostRecentSnoozeRectangle!]
                            if mostRecentSnoozeRectangle.gradient > 0 {
                                rectangles.removeAtIndex(indexOfMostRecentSnoozeRectangle!)
                            }
                        }
                        rectangles += [(startDate: dateOfLastStateChange, endDate: event.date, eventType: "snooze", gradient: 0)]
                        state = "awake"
                        dateOfLastStateChange = event.date
                    case "awake": // woke up from awake
                        rectangles += [(startDate: dateOfLastStateChange, endDate: event.date, eventType: "sleep", gradient: -1)]
                        state = "awake"
                        dateOfLastStateChange = event.date
                    default:
                        break
                    }
                case "wentToBed", "tookANap": // EVENT
                    switch state {
                    case "unknown":
                        rectangles += [(startDate: event.date, endDate: event.date, eventType: "sleep", gradient: 1)]
                        state = "sleeping"
                        dateOfLastStateChange = event.date
                    case "sleeping":
                        rectangles += [(startDate: event.date, endDate: event.date, eventType: "sleep", gradient: 1)]
                        state = "sleeping"
                        dateOfLastStateChange = event.date
                    case "snoozing":
                        let indexOfMostRecentSnoozeRectangle = getIndexOfMostRecentRectangleOfEventType("snooze")
                        if indexOfMostRecentSnoozeRectangle != nil {
                            let mostRecentSnoozeRectangle = rectangles[indexOfMostRecentSnoozeRectangle!]
                            if mostRecentSnoozeRectangle.gradient > 0 {
                                rectangles.removeAtIndex(indexOfMostRecentSnoozeRectangle!)
                            }
                        }
                        rectangles += [(startDate: dateOfLastStateChange, endDate: event.date, eventType: "snooze", gradient: 0)]
                        state = "sleeping"
                        dateOfLastStateChange = event.date
                    case "awake":
                        rectangles += [(startDate: event.date, endDate: event.date, eventType: "sleep", gradient: 1)]
                        state = "sleeping"
                        dateOfLastStateChange = event.date
                    default:
                        break
                    }
                case "alarmWentOff":
                    switch state {
                    case "unknown":
                        rectangles += [(startDate: dateOfLastStateChange, endDate: event.date, eventType: "sleep", gradient: -1)]
                        rectangles += [(startDate: event.date, endDate: event.date, eventType: "snooze", gradient: 1)]
                        state = "sleeping"
                        dateOfLastStateChange = event.date
                    case "sleeping":
                        let indexOfMostRecentSleepRectangle = getIndexOfMostRecentRectangleOfEventType("sleep")
                        if indexOfMostRecentSleepRectangle != nil {
                            let mostRecentSleepRectangle = rectangles[indexOfMostRecentSleepRectangle!]
                            if mostRecentSleepRectangle.gradient > 0 {
                                rectangles.removeAtIndex(indexOfMostRecentSleepRectangle!)
                            }
                        }
                        rectangles += [(startDate: dateOfLastStateChange, endDate: event.date, eventType: "sleep", gradient: 0)]
                        rectangles += [(startDate: event.date, endDate: event.date, eventType: "snooze", gradient: 1)]
                        state = "snoozing"
                        dateOfLastStateChange = event.date
                    case "snoozing":
                        let indexOfMostRecentSnoozeRectangle = getIndexOfMostRecentRectangleOfEventType("snooze")
                        if indexOfMostRecentSnoozeRectangle != nil {
                            let mostRecentSnoozeRectangle = rectangles[indexOfMostRecentSnoozeRectangle!]
                            if mostRecentSnoozeRectangle.gradient > 0 {
                                rectangles.removeAtIndex(indexOfMostRecentSnoozeRectangle!)
                            }
                        }
                        rectangles += [(startDate: event.date, endDate: event.date, eventType: "snooze", gradient: 1)]
                        state = "snoozing"
                        dateOfLastStateChange = event.date
                    case "awake":
                        rectangles += [(startDate: event.date, endDate: event.date, eventType: "snooze", gradient: 1)]
                        state = "snoozing"
                        dateOfLastStateChange = event.date
                    default:
                        break
                    }
                default:
                    break
                }
            }
            
            for rectangle in rectangles {
                if rectangle.eventType == "sleep" || rectangle.eventType == "snooze" {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "eee, yyyy-MM-dd HH:mm:ss"
                    //print("event: \(rectangle.eventType), startTime: \(dateFormatter.stringFromDate(rectangle.startDate)), endTime: \(dateFormatter.stringFromDate(rectangle.endDate)), gradient: \(rectangle.gradient)")
                }
                //print("")
            }
        }
        
        
        // Driving Time
        //    states: unknown, driving, notDriving
        //    events: leftForWork, arrivedAtWork, leftForHome, arrivedAtHome
        state = "unknown"
        dateOfLastStateChange = startOfWeek
        for event in processedData {
        
            if event.category == "drivingTime" {
                switch event.event {
                case "leftForWork", "leftForHome":
                    switch state {
                    case "unknown":
                        rectangles += [(startDate: event.date, endDate: event.date, eventType: "drive", gradient: 1)]
                        state = "driving"
                        dateOfLastStateChange = event.date
                    case "driving":
                        rectangles += [(startDate: event.date, endDate: event.date, eventType: "drive", gradient: 1)]
                        state = "driving"
                        dateOfLastStateChange = event.date
                    case "notDriving":
                        rectangles += [(startDate: event.date, endDate: event.date, eventType: "drive", gradient: 1)]
                        state = "driving"
                        dateOfLastStateChange = event.date
                    default:
                        break
                    }
                case "arrivedAtWork", "arrivedAtHome":
                    switch state {
                    case "unknown":
                        rectangles += [(startDate: event.date, endDate: event.date, eventType: "drive", gradient: -1)]
                        state = "notDriving"
                        dateOfLastStateChange = event.date
                    case "driving":
                        let indexOfMostRecentSnoozeRectangle = getIndexOfMostRecentRectangleOfEventType("drive")
                        if indexOfMostRecentSnoozeRectangle != nil {
                            let mostRecentSnoozeRectangle = rectangles[indexOfMostRecentSnoozeRectangle!]
                            if mostRecentSnoozeRectangle.gradient > 0 {
                                rectangles.removeAtIndex(indexOfMostRecentSnoozeRectangle!)
                            }
                        }
                        rectangles += [(startDate: dateOfLastStateChange, endDate: event.date, eventType: "drive", gradient: 0)]
                        state = "notDriving"
                        dateOfLastStateChange = event.date
                    case "notDriving":
                        rectangles += [(startDate: event.date, endDate: event.date, eventType: "drive", gradient: -1)]
                        state = "notDriving"
                        dateOfLastStateChange = event.date
                    default:
                        break
                    }
                default:
                    break
                }
                
                for rectangle in rectangles {
                    if rectangle.eventType == "drive" {
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "eee, yyyy-MM-dd HH:mm:ss"
                        //print("event: \(rectangle.eventType), startTime: \(dateFormatter.stringFromDate(rectangle.startDate)), endTime: \(dateFormatter.stringFromDate(rectangle.endDate)), gradient: \(rectangle.gradient)")
                    }
                }
                //print("")
                
            }
        }
        
        
        // Meals
        //    events: breakfast, brunch, lunch, snack, dinner
        for event in processedData {
            if event.category == "meals" {
                lines += [(date: event.date, eventType: event.event)]
            }
        }
        
        
        // Drinks
        //    events: alcohol, water, coffee, otherDrink
        for event in processedData {
            if event.category == "drinks" {
                lines += [(date: event.date, eventType: event.event)]
            }
        }
    }
    
    func getIndexOfMostRecentRectangleOfEventType(eventType: String) -> Int? {
        var indexOfMostRecentRectangle: Int?
        var dateOfMostRecentRectangle: NSDate?
        for var index = 0; index < rectangles.count; index++ {
            let thisRectangle = rectangles[index]
            if thisRectangle.eventType == eventType {
                if dateOfMostRecentRectangle == nil {
                    indexOfMostRecentRectangle = index
                    dateOfMostRecentRectangle = thisRectangle.startDate
                }
                else {
                    if thisRectangle.startDate.compare(dateOfMostRecentRectangle!) == NSComparisonResult.OrderedDescending {
                        indexOfMostRecentRectangle = index
                        dateOfMostRecentRectangle = thisRectangle.startDate
                    }
                }
            }
        }
        return indexOfMostRecentRectangle
    }
    
    override func drawRect(rect: CGRect) {
        if !initializationComplete {
            createGraphicsObjects()
            initializationComplete = true
        }
        
        let context = UIGraphicsGetCurrentContext()
        
        
        CGContextSetRGBStrokeColor(context, 0.75, 0.75, 0.75, 1)
        CGContextSetLineWidth(context, 0.6)
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
        
        for rectangle in rectangles {
    
            var rectangleColor = UIColor.clearColor().CGColor
            switch rectangle.eventType {
            case "sleep":
                rectangleColor = sleepColor
            case "snooze":
                rectangleColor = snoozeColor
            case "drive":
                rectangleColor = driveColor
            default:
                break
            }
            
            if rectangle.gradient == 0 {
                CGContextSetFillColorWithColor(context, rectangleColor)
                let startingDateComponents = NSCalendar.currentCalendar().components([.Day], fromDate: rectangle.startDate)
                let endingDateComponents = NSCalendar.currentCalendar().components([.Day], fromDate: rectangle.endDate)
                if startingDateComponents.day == endingDateComponents.day {
                    let startingCGPoint = CGPointForDate(rectangle.startDate, offset: -0.5)
                    let endingCGPoint = CGPointForDate(rectangle.endDate, offset: 0.5)
                    let cgRect = CGRectMake(startingCGPoint.x, startingCGPoint.y, endingCGPoint.x - startingCGPoint.x, endingCGPoint.y - startingCGPoint.y)
                    CGContextFillRect(context, cgRect)
                }
                else {
                    let firstDayEndingDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .TimeZone], fromDate: rectangle.startDate)
                    let startOfFirstDay = NSCalendar.currentCalendar().dateFromComponents(firstDayEndingDateComponents)!
                    let startOfSecondDay = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: startOfFirstDay, options: [])!
                    let endOfFirstDay = NSCalendar.currentCalendar().dateByAddingUnit(.Second, value: -1, toDate: startOfSecondDay, options: [])!
                    
                    let firstDayStartingCGPoint = CGPointForDate(rectangle.startDate, offset: -0.5)
                    let firstDayEndingCGPoint = CGPointForDate(endOfFirstDay, offset: 0.5)
                    let secondDayStartingCGPoint = CGPointForDate(startOfSecondDay, offset: -0.5)
                    let secondDayEndingCGPoint = CGPointForDate(rectangle.endDate, offset: 0.5)
                    
                    let firstDayCGRect = CGRectMake(firstDayStartingCGPoint.x, firstDayStartingCGPoint.y, firstDayEndingCGPoint.x - firstDayStartingCGPoint.x, firstDayEndingCGPoint.y - firstDayStartingCGPoint.y)
                    let secondDayCGRect = CGRectMake(secondDayStartingCGPoint.x, secondDayStartingCGPoint.y, secondDayEndingCGPoint.x - secondDayStartingCGPoint.x, secondDayEndingCGPoint.y - secondDayStartingCGPoint.y)
                    
                    CGContextFillRect(context, firstDayCGRect)
                    CGContextFillRect(context, secondDayCGRect)
                }
            }
            else {
            	if rectangle.gradient > 0 { // known start time
                    let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [rectangleColor, rectangleColor, UIColor.clearColor().CGColor], [0, 0.3, 1])!
                    let gradientStartDate = rectangle.startDate
                    let gradientEndDate = NSCalendar.currentCalendar().dateByAddingUnit(.Second, value: gradientHeightInSeconds, toDate: gradientStartDate, options: [])!
                    let gradientStartDateComponents = NSCalendar.currentCalendar().components([.Day], fromDate: gradientStartDate)
                    let gradientEndDateComponents = NSCalendar.currentCalendar().components([.Day], fromDate: gradientEndDate)
                    if gradientStartDateComponents.day == gradientEndDateComponents.day { // gradient is in same day
                        let gradientStartingCGPoint = CGPointForDate(gradientStartDate, offset: -0.5)
                        let gradientEndingCGPoint = CGPointForDate(gradientEndDate, offset: 0.5)
                        let gradientCGRect = CGRectMake(gradientStartingCGPoint.x, gradientStartingCGPoint.y, gradientEndingCGPoint.x - gradientStartingCGPoint.x, gradientEndingCGPoint.y - gradientStartingCGPoint.y)
                        let clippingPath = UIBezierPath(rect: gradientCGRect)
                        CGContextSaveGState(context)
                        clippingPath.addClip()
                        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, gradientStartingCGPoint.y), CGPointMake(0, gradientEndingCGPoint.y), CGGradientDrawingOptions.DrawsBeforeStartLocation)
                        CGContextRestoreGState(context)
                    }
                    else { // gradient spans 2 days
                        let firstDayStartingDate = gradientStartDate
                        let firstDayComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .TimeZone], fromDate: firstDayStartingDate)
                        let startOfFirstDay = NSCalendar.currentCalendar().dateFromComponents(firstDayComponents)!
                        let startOfSecondDay = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: startOfFirstDay, options: [])!
                        let endOfFirstDay = NSCalendar.currentCalendar().dateByAddingUnit(.Second, value: -1, toDate: startOfSecondDay, options: [])!
                        let secondDayEndingDate = gradientEndDate
                        
                        let firstDayStartingCGPoint = CGPointForDate(firstDayStartingDate, offset: -0.5)
                        let firstDayEndingCGPoint = CGPointForDate(endOfFirstDay, offset: 0.5)
                        let secondDayStartingCGPoint = CGPointForDate(startOfSecondDay, offset: -0.5)
                        let secondDayEndingCGPoint = CGPointForDate(secondDayEndingDate, offset: 0.5)
                        let totalYCGPoints = firstDayStartingCGPoint.y - firstDayEndingCGPoint.y + secondDayStartingCGPoint.y - secondDayEndingCGPoint.y
                        
                        let firstDayGradientCGRect = CGRectMake(firstDayStartingCGPoint.x, firstDayStartingCGPoint.y - totalYCGPoints, firstDayEndingCGPoint.x - firstDayStartingCGPoint.x, totalYCGPoints)
                        let secondDayGradientCGRect = CGRectMake(secondDayStartingCGPoint.x, secondDayEndingCGPoint.y, secondDayEndingCGPoint.x - secondDayStartingCGPoint.x, totalYCGPoints)
                        
                        let firstDayClippingPathRect = CGRectMake(firstDayStartingCGPoint.x, firstDayStartingCGPoint.y, firstDayEndingCGPoint.x - firstDayStartingCGPoint.x, firstDayEndingCGPoint.y - firstDayStartingCGPoint.y)
                        let secondDayClippingPathRect = CGRectMake(secondDayStartingCGPoint.x, secondDayStartingCGPoint.y, secondDayEndingCGPoint.x - secondDayStartingCGPoint.x, secondDayEndingCGPoint.y - secondDayStartingCGPoint.y)
                        
                        let firstDayClippingPath = UIBezierPath(rect: firstDayClippingPathRect)
                        let secondDayClippingPath = UIBezierPath(rect: secondDayClippingPathRect)
                        
                        CGContextSaveGState(context)
                        firstDayClippingPath.addClip()
                        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, firstDayGradientCGRect.origin.y + totalYCGPoints), CGPointMake(0, firstDayGradientCGRect.origin.y), [])
                        CGContextRestoreGState(context)
                        
                        CGContextSaveGState(context)
                        secondDayClippingPath.addClip()
                        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, secondDayGradientCGRect.origin.y + totalYCGPoints), CGPointMake(0, secondDayGradientCGRect.origin.y), [])
                        CGContextRestoreGState(context)
                    }
                }
                else { // known end time
                    let gradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [rectangleColor, rectangleColor, UIColor.clearColor().CGColor], [1, 0.7, 0])!
                    let gradientEndDate = rectangle.endDate
                    let gradientStartDate = NSCalendar.currentCalendar().dateByAddingUnit(.Second, value: -gradientHeightInSeconds, toDate: gradientEndDate, options: [])!
                    let gradientStartDateComponents = NSCalendar.currentCalendar().components([.Day], fromDate: gradientStartDate)
                    let gradientEndDateComponents = NSCalendar.currentCalendar().components([.Day], fromDate: gradientEndDate)
                    if gradientStartDateComponents.day == gradientEndDateComponents.day { // gradient is in same day
                        let gradientStartingCGPoint = CGPointForDate(gradientStartDate, offset: -0.5)
                        let gradientEndingCGPoint = CGPointForDate(gradientEndDate, offset: 0.5)
                        let gradientCGRect = CGRectMake(gradientStartingCGPoint.x, gradientStartingCGPoint.y, gradientEndingCGPoint.x - gradientStartingCGPoint.x, gradientEndingCGPoint.y - gradientStartingCGPoint.y)
                        let clippingPath = UIBezierPath(rect: gradientCGRect)
                        CGContextSaveGState(context)
                        clippingPath.addClip()
                        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, gradientStartingCGPoint.y), CGPointMake(0, gradientEndingCGPoint.y), CGGradientDrawingOptions.DrawsBeforeStartLocation)
                        CGContextRestoreGState(context)
                    }
                    else { // gradient spans 2 days
                        let firstDayStartingDate = gradientStartDate
                        let firstDayComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .TimeZone], fromDate: firstDayStartingDate)
                        let startOfFirstDay = NSCalendar.currentCalendar().dateFromComponents(firstDayComponents)!
                        let startOfSecondDay = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: 1, toDate: startOfFirstDay, options: [])!
                        let endOfFirstDay = NSCalendar.currentCalendar().dateByAddingUnit(.Second, value: -1, toDate: startOfSecondDay, options: [])!
                        let secondDayEndingDate = gradientEndDate
                        
                        let firstDayStartingCGPoint = CGPointForDate(firstDayStartingDate, offset: -0.5)
                        let firstDayEndingCGPoint = CGPointForDate(endOfFirstDay, offset: 0.5)
                        let secondDayStartingCGPoint = CGPointForDate(startOfSecondDay, offset: -0.5)
                        let secondDayEndingCGPoint = CGPointForDate(secondDayEndingDate, offset: 0.5)
                        let totalYCGPoints = firstDayStartingCGPoint.y - firstDayEndingCGPoint.y + secondDayStartingCGPoint.y - secondDayEndingCGPoint.y
                        
                        let firstDayGradientCGRect = CGRectMake(firstDayStartingCGPoint.x, firstDayStartingCGPoint.y - totalYCGPoints, firstDayEndingCGPoint.x - firstDayStartingCGPoint.x, totalYCGPoints)
                        let secondDayGradientCGRect = CGRectMake(secondDayStartingCGPoint.x, secondDayEndingCGPoint.y, secondDayEndingCGPoint.x - secondDayStartingCGPoint.x, totalYCGPoints)
                        
                        let firstDayClippingPathRect = CGRectMake(firstDayStartingCGPoint.x, firstDayStartingCGPoint.y, firstDayEndingCGPoint.x - firstDayStartingCGPoint.x, firstDayEndingCGPoint.y - firstDayStartingCGPoint.y)
                        let secondDayClippingPathRect = CGRectMake(secondDayStartingCGPoint.x, secondDayStartingCGPoint.y, secondDayEndingCGPoint.x - secondDayStartingCGPoint.x, secondDayEndingCGPoint.y - secondDayStartingCGPoint.y)
                        
                        let firstDayClippingPath = UIBezierPath(rect: firstDayClippingPathRect)
                        let secondDayClippingPath = UIBezierPath(rect: secondDayClippingPathRect)
                        
                        CGContextSaveGState(context)
                        firstDayClippingPath.addClip()
                        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, firstDayGradientCGRect.origin.y + totalYCGPoints), CGPointMake(0, firstDayGradientCGRect.origin.y), [])
                        CGContextRestoreGState(context)
                        
                        CGContextSaveGState(context)
                        secondDayClippingPath.addClip()
                        CGContextDrawLinearGradient(context, gradient, CGPointMake(0, secondDayGradientCGRect.origin.y + totalYCGPoints), CGPointMake(0, secondDayGradientCGRect.origin.y), [])
                        CGContextRestoreGState(context)
                    }
                }
            }
        }
        
        for line in lines {
            switch line.eventType {
            case "alcohol", "water", "coffee", "otherDrink":
                let lineStartingCGPoint = CGPointForDate(line.date, offset: -drinkOffset)
                let lineEndingCGPoint = CGPointForDate(line.date, offset: drinkOffset)
                CGContextSetLineWidth(context, drinkLineWidth)
                CGContextSetLineCap(context, CGLineCap.Butt)
                switch line.eventType {
                case "alcohol":
                    CGContextSetStrokeColorWithColor(context, alcoholColor)
                case "water":
                    CGContextSetStrokeColorWithColor(context, waterColor)
                case "coffee":
                    CGContextSetStrokeColorWithColor(context, coffeeColor)
                case "otherDrink":
                    CGContextSetStrokeColorWithColor(context, otherDrinkColor)
                default:
                    break
                }
                CGContextMoveToPoint(context, lineStartingCGPoint.x, lineStartingCGPoint.y)
                CGContextAddLineToPoint(context, lineEndingCGPoint.x, lineEndingCGPoint.y)
                CGContextStrokePath(context)
            case "breakfast", "brunch", "lunch", "snack", "dinner":
                CGContextSetStrokeColorWithColor(context, mealColor)
                CGContextSetLineWidth(context, mealLineWidth)
                CGContextSetLineCap(context, CGLineCap.Round)
                switch line.eventType {
                case "breakfast":
                    let lineStartingCGPoint = CGPointForDate(line.date, offset: -breakfastOffset)
                    let lineEndingCGPoint = CGPointForDate(line.date, offset: breakfastOffset)
                    CGContextMoveToPoint(context, lineStartingCGPoint.x, lineStartingCGPoint.y)
                    CGContextAddLineToPoint(context, lineEndingCGPoint.x, lineEndingCGPoint.y)
                    CGContextStrokePath(context)
                case "brunch":
                    let lineStartingCGPoint = CGPointForDate(line.date, offset: -brunchOffset)
                    let lineEndingCGPoint = CGPointForDate(line.date, offset: brunchOffset)
                    CGContextMoveToPoint(context, lineStartingCGPoint.x, lineStartingCGPoint.y)
                    CGContextAddLineToPoint(context, lineEndingCGPoint.x, lineEndingCGPoint.y)
                    CGContextStrokePath(context)
                case "lunch":
                    let lineStartingCGPoint = CGPointForDate(line.date, offset: -lunchOffset)
                    let lineEndingCGPoint = CGPointForDate(line.date, offset: lunchOffset)
                    CGContextMoveToPoint(context, lineStartingCGPoint.x, lineStartingCGPoint.y)
                    CGContextAddLineToPoint(context, lineEndingCGPoint.x, lineEndingCGPoint.y)
                    CGContextStrokePath(context)
                case "snack":
                    let lineStartingCGPoint = CGPointForDate(line.date, offset: -snackOffset)
                    let lineEndingCGPoint = CGPointForDate(line.date, offset: snackOffset)
                    CGContextMoveToPoint(context, lineStartingCGPoint.x, lineStartingCGPoint.y)
                    CGContextAddLineToPoint(context, lineEndingCGPoint.x, lineEndingCGPoint.y)
                    CGContextStrokePath(context)
                case "dinner":
                    let lineStartingCGPoint = CGPointForDate(line.date, offset: -dinnerOffset)
                    let lineEndingCGPoint = CGPointForDate(line.date, offset: dinnerOffset)
                    CGContextMoveToPoint(context, lineStartingCGPoint.x, lineStartingCGPoint.y)
                    CGContextAddLineToPoint(context, lineEndingCGPoint.x, lineEndingCGPoint.y)
                    CGContextStrokePath(context)
                default:
                    break
                }
            default:
                break
            }
        }
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