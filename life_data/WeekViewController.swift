//
//  WeekViewController.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 10/6/15.
//  Copyright © 2015 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import UIKit

class WeekViewController: UIViewController {

    var username: String?
    var hostname: String?
    var data: [String] = []
    @IBOutlet var weekChartView: WeekChartView?
    @IBOutlet var maskView: UIView?
    @IBOutlet var errorStackView: UIStackView?
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        prepareStaticUI()
        kickOffNewRequest()
    }
    
    func prepareStaticUI() {
        self.activityIndicatorView!.hidesWhenStopped = true
        self.errorStackView!.hidden = true
        self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.0)
    }
    
    func kickOffNewRequest() {
    
        self.clearDynamicData()
        startActivityIndicator()
    
        let date = NSDate()
        let eightDaysAgo = date.dateByAddingTimeInterval(-7*24*60*60)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let fromTime = dateFormatter.stringFromDate(eightDaysAgo)
        let URLString = "http://taylorg.no-ip.org/cgi-bin/database/readFromTime?username=\(username!)&fromTime=%22\(fromTime)%22"
        
        NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(NSURLRequest(URL: NSURL(string: URLString)!), completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) in

            if data != nil {
                self.dataRequestCompletedWithData(String(data: data!, encoding: NSUTF8StringEncoding)!)
                self.stopActivityIndicatorAndClear()
            }
            else {
                self.stopActivityIndicatorWithError()
            }
            
        }).resume()
        
    }
    
    func dataRequestCompletedWithData(response: String) {
        let splitByBreak = response.componentsSeparatedByString("<br>")
        for line in splitByBreak {
            if line.characters.count > 0 {
                self.data += [line]
            }
            else {
                //print("skipped one in data read")
            }
        }
        self.weekChartView!.processedData += self.createProcessedDataFromRaw()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.weekChartView!.setNeedsDisplay()
        })
    }
    
    func clearDynamicData() {
        self.weekChartView!.processedData.removeAll()
        self.data.removeAll()
    }
    
    @IBAction func didTapRetry() {
        kickOffNewRequest()
    }
        
    func startActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.startAnimating()
            self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.25)
            self.errorStackView!.hidden = true
        })
    }
    
    func stopActivityIndicatorAndClear() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.0)
        })
    }
    
    func stopActivityIndicatorWithError() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.errorStackView!.hidden = false
        })
    }
    
    func createProcessedDataFromRaw() -> [(date: NSDate, category: String, event: String)] {
        var processedData: [(date: NSDate, category: String, event: String)] = []
        for line in data {
            let splitBySemicolon = line.componentsSeparatedByString(";")
            let category = splitBySemicolon[1].componentsSeparatedByString("category:")[1]
            if category == "sleep" || category == "drivingTime" || category == "drinks" || category == "meals" {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.dateFromString(splitBySemicolon[0].componentsSeparatedByString("time:")[1])!
                let today = NSDate()
                dateFormatter.dateFormat = "e"
                let todaysDOW = dateFormatter.stringFromDate(today)
                let testDOW = dateFormatter.stringFromDate(date)
                if !(todaysDOW == testDOW && today.timeIntervalSinceDate(date)>3*24*60*60) {
                    if category == "sleep" {
                        processedData += [(date: date, category: category, event: splitBySemicolon[2].componentsSeparatedByString("event:")[1])]
                    }
                    if category == "drivingTime" {
                        processedData += [(date: date, category: category, event: splitBySemicolon[2].componentsSeparatedByString("tripType:")[1])]
                    }
                    if category == "drinks" {
                        processedData += [(date: date, category: category, event: splitBySemicolon[2].componentsSeparatedByString("drinkType:")[1])]
                    }
                    if category == "meals" {
                        processedData += [(date: date, category: category, event: splitBySemicolon[2].componentsSeparatedByString("mealType:")[1])]
                    }
                }
            }
        }
        return processedData
    }

    func printData() {
        var returnString = ""
        for line in data {
            let splitBySemicolon = line.componentsSeparatedByString(";")
            var firstLine = true
            for item in splitBySemicolon {
                if firstLine {
                    returnString += "\(item)\n"
                    firstLine = false
                }
                else {
                    returnString += "          \(item)\n"
                }
            }
        }
        print(returnString)
    }
    
}