//
//  WeightViewController.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 8/22/15.
//  Copyright (c) 2015 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import UIKit

class WeightViewController: UIViewController {

    @IBOutlet var upperYLabel: UILabel?
    @IBOutlet var centerYLabel: UILabel?
    @IBOutlet var lowerYLabel: UILabel?
    @IBOutlet var leftXLabel: UILabel?
    @IBOutlet var centerXLabel: UILabel?
    @IBOutlet var rightXLabel: UILabel?
    @IBOutlet var graphView: GraphView?
    
    var username: String?
    var category: String?
    var hostname: String?
    
    var morningDataPoints: [(date: NSDate, weight: Double)] = []
    var minDate: NSDate?
    var maxDate: NSDate?
    var minWeight: Double?
    var maxWeight: Double?
    
    var maxXPixel: CGFloat?
    var minXPixel: CGFloat?
    var maxYPixel: CGFloat?
    var minYPixel: CGFloat?
    
    var drawingPoints: [CGPoint] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getWeightData()
        setLimits()
        updateLabels()
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "needsDisplay", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        configureView()
        super.viewDidLayoutSubviews()
    }
    
//    func needsDisplay() {
//        graphView!.setNeedsDisplay()
//    }
    
    func configureView() {
        updatePixelLimits()
        fillInPoints()
        redrawGraphView()
    }
    
    func getWeightData() {
        let requestString = "http://\(hostname!)/cgi-bin/database/read?username=\(username!)&category=\(category!)"
        //println(requestString)
        let returnString = try? NSString(contentsOfURL: NSURL(string: requestString)!, encoding: NSUTF8StringEncoding)
        //println(returnString!)
        let splitByBreak = returnString!.componentsSeparatedByString("<br>")
        var skippedFirstLineYet = false
        for line in splitByBreak {
            if skippedFirstLineYet == false {
                skippedFirstLineYet = true
                continue
            }
            let splitByComma = line.componentsSeparatedByString(",")
            if splitByComma.count > 1 {
                if splitByComma[1] == " morning" {
                    //println("line: \(line)")
                    let dateFormatter = NSDateFormatter();
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = dateFormatter.dateFromString(splitByComma[0] )
                    //println("date: \(date!)")
                    let numberString = (splitByComma[2] as NSString)
                    let weight = numberString.doubleValue
                    morningDataPoints += [(date: date!, weight: weight)]
                }
            }
        }
        //println(morningDataPoints.count)
    }
    
    func setLimits() {
        for (date, weight) in morningDataPoints {
            if maxDate == nil {
                maxDate = date
            }
            if minDate == nil {
                minDate = date
            }
            if maxWeight == nil {
                maxWeight = weight
            }
            if minWeight == nil {
                minWeight = weight
            }
            if date.timeIntervalSinceDate(maxDate!) > 0{
                maxDate = date
            }
            if date.timeIntervalSinceDate(minDate!) < 0 {
                minDate = date
            }
            if weight > maxWeight! {
                maxWeight = weight
            }
            if weight < minWeight! {
                minWeight = weight
            }
        }
    }
    
    func updateLabels() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        leftXLabel!.text = dateFormatter.stringFromDate(minDate!)
        centerXLabel!.text = dateFormatter.stringFromDate(minDate!.dateByAddingTimeInterval(maxDate!.timeIntervalSinceDate(minDate!)/2))
        rightXLabel!.text = dateFormatter.stringFromDate(maxDate!)
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        upperYLabel!.text = numberFormatter.stringFromNumber(NSNumber(double: maxWeight!))
        centerYLabel!.text = numberFormatter.stringFromNumber(NSNumber(double: (maxWeight!-minWeight!)/2 + minWeight!))
        lowerYLabel!.text = numberFormatter.stringFromNumber(NSNumber(double: minWeight!))
    }
    
    func updatePixelLimits() {
        maxYPixel = upperYLabel!.frame.height/2
        minYPixel = graphView!.frame.height - lowerYLabel!.frame.height/2
        minXPixel = leftXLabel!.frame.width/2
        maxXPixel = graphView!.frame.width - rightXLabel!.frame.width/2
        //println("minX: \(minXPixel!), maxX: \(maxXPixel!), minY: \(minYPixel!), maxY: \(maxYPixel!)")
    }
    
    func xValueForDate(date: NSDate) -> CGFloat {
        let totalTimeInterval = maxDate!.timeIntervalSinceDate(minDate!)
        let thisTimeInterval = date.timeIntervalSinceDate(minDate!)
        let percent = CGFloat(thisTimeInterval/totalTimeInterval)
        return (maxXPixel!-minXPixel!) * percent + minXPixel!
    }
    
    func yValueForWeight(weight: Double) -> CGFloat {
        let totalWeightInterval = maxWeight! - minWeight!
        let thisWeightInterval = weight - minWeight!
        let percent = CGFloat(thisWeightInterval/totalWeightInterval)
        return (maxYPixel!-minYPixel!) * percent + minYPixel!
    }
    
    func fillInPoints() {
        drawingPoints.removeAll(keepCapacity: false)
        for (date, weight) in morningDataPoints {
            drawingPoints += [CGPointMake(xValueForDate(date), yValueForWeight(weight))]
            //println("weight: \(weight), x: \(drawingPoints.last!.x), y: \(drawingPoints.last!.y)")
        }
    }
    
    func redrawGraphView() {
        //println("view.width: \(CGRectGetWidth(graphView!.bounds)), view.height: \(CGRectGetHeight(graphView!.bounds))")
        graphView!.drawingPoints = drawingPoints
        print("redrawGraphView")
        //graphView!.setNeedsDisplay()
    }
}