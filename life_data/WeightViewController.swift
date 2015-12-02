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
    
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?
    @IBOutlet var maskView: UIView?
    @IBOutlet var errorStackView: UIStackView?
    
    var username: String?
    var category: String?
    var hostname: String?
    
    var dataPoints: [(date: NSDate, weight: Double)] = []
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.0)
        prepareStaticUI()
        kickOffNewRequest()
    }
    
    override func viewDidLayoutSubviews() {
        setLimits()
        fillInPoints()
        prepareStaticUI()
        super.viewDidLayoutSubviews()
    }
    
    func prepareStaticUI() {
        self.activityIndicatorView!.hidesWhenStopped = true
        //self.errorStackView!.hidden = true
        updatePixelLimits()
        updateLabels()
        redrawGraphView()
    }
    
    @IBAction func didTapRetry() {
        kickOffNewRequest()
    }
    
    func kickOffNewRequest() {
    
        self.startActivityIndicator()
    
        let requestString = "http://taylorg.no-ip.org/cgi-bin/database/read?username=\(username!)&category=\(category!)"
        
        NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(NSURLRequest(URL: NSURL(string: requestString)!)) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            
            if data != nil {
                //print("data != nil")
                self.requestSucceededWithData(String(data: data!, encoding: NSUTF8StringEncoding)!)
            }
            else {
                //print("data == nil")
                self.stopActivityIndicatorWithError()
            }
            
        }.resume()
    }
    
    func requestSucceededWithData(data: String) {
    
        let splitByBreak = data.componentsSeparatedByString("<br>")
        var skippedFirstLineYet = false
        for line in splitByBreak {
            if skippedFirstLineYet == false {
                skippedFirstLineYet = true
                continue
            }
            let splitByComma = line.componentsSeparatedByString(",")
            if splitByComma.count > 1 {
                if splitByComma[1] == " morning" {
                    let dateFormatter = NSDateFormatter();
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = dateFormatter.dateFromString(splitByComma[0] )
                    let numberString = (splitByComma[2] as NSString)
                    let weight = numberString.doubleValue
                    dataPoints += [(date: date!, weight: weight)]
            }
        }
        
        setLimits()
        fillInPoints()
        stopActivityIndicatorAndClear()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updateLabels()
            self.redrawGraphView()
        })
        
    }
        
    func startActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.startAnimating()
            self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.25)
            self.errorStackView!.hidden = true
            //print("started")
        })
    }
    
    func stopActivityIndicatorAndClear() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.0)
            //print("stop and clear")
        })
    }
    
    func stopActivityIndicatorWithError() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.errorStackView!.hidden = false
            //print("stop with error")
        })
    }

    
    func setLimits() {
        for (date, weight) in dataPoints {
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
            if date.timeIntervalSinceDate(maxDate!) > 0 {
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
        leftXLabel!.text = minDate != nil ? dateFormatter.stringFromDate(minDate!) : " "
        centerXLabel!.text = minDate != nil && maxDate != nil ? dateFormatter.stringFromDate(minDate!.dateByAddingTimeInterval(maxDate!.timeIntervalSinceDate(minDate!)/2)) : " "
        rightXLabel!.text = maxDate != nil ? dateFormatter.stringFromDate(maxDate!) : " "
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        upperYLabel!.text = maxWeight != nil ? numberFormatter.stringFromNumber(NSNumber(double: maxWeight!)) : " "
        centerYLabel!.text = minWeight != nil && maxWeight != nil ? numberFormatter.stringFromNumber(NSNumber(double: (maxWeight!-minWeight!)/2 + minWeight!)) : " "
        lowerYLabel!.text = minWeight != nil ? numberFormatter.stringFromNumber(NSNumber(double: minWeight!)) : " "
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
        for (date, weight) in dataPoints {
            drawingPoints += [CGPointMake(xValueForDate(date), yValueForWeight(weight))]
        }
    }
    
    func redrawGraphView() {
        self.graphView!.drawingPoints = drawingPoints
        self.graphView!.setNeedsDisplay()
    }
}