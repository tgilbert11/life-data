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
        self.weekChartView!.processedData.removeAll()
        self.data.removeAll()
        startActivityIndicator()
    
    
        let date = NSDate()
        let eightDaysAgo = date.dateByAddingTimeInterval(-7*24*60*60)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let fromTime = dateFormatter.stringFromDate(eightDaysAgo)
        //print(fromTime)
        
        let urlString = "http://\(hostname!)/cgi-bin/database/readFromTime?username=\(username!)&fromTime=%22\(fromTime)%22"
        let URL = NSURL(string: urlString)
        let urlRequest = NSURLRequest(URL: URL!)
        let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        urlSession.dataTaskWithRequest(urlRequest, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) in
            print("complete")
            
            if data != nil {
                let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
                let splitByBreak = responseString!.componentsSeparatedByString("<br>")
                for line in splitByBreak {
                    //print(line)
                    //print(line.characters.count)
                    if line.characters.count > 0 {
                        self.data += [line]
                    }
                    else {
                        //print("skipped one in data read")
                    }
                }
                self.weekChartView!.processedData += self.createProcessedDataFromRaw()
                self.stopActivityIndicatorAndClear()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.weekChartView!.setNeedsDisplay()
                })
            }
            else {
                print("data was nil")
                self.stopActivityIndicatorWithError()
            }
        }).resume()
        
//        
//        //print(urlString)
//        let requestString = try? NSString(contentsOfURL: NSURL(string: urlString)!, encoding: NSUTF8StringEncoding)
//        //print(requestString!)
//        let splitByBreak = requestString!.componentsSeparatedByString("<br>")
//        for line in splitByBreak {
//            //print(line)
//            //print(line.characters.count)
//            if line.characters.count > 0 {
//                data += [line]
//            }
//            else {
//                //print("skipped one in data read")
//            }
//        }
        //data += splitByBreak
        
//        let URLPath = "http://taylorg.no-ip.org/cgi-bin/database/API"
//        let URL = NSURL(string: URLPath)
//        let urlRequest = NSURLRequest(URL: URL!)
//        let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//        urlSession.dataTaskWithRequest(urlRequest, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) in
//            //print("complete")
//        
//            if data != nil {
//                let dataString = String(data: data!, encoding:NSUTF8StringEncoding)!
//                //print(dataString)
//                self.APIString = dataString
//                self.hostname = "taylorg.no-ip.org"
//                self.parseData()
//                self.stopActivityIndicatorAndClear()
//                //print("categoryDictionary.count: \(self.categoryDictionary.count)")
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.theTableView!.reloadData()
//                })
//            }
//            else {
//                //print("data was nil")
//                self.stopActivityIndicatorWithError()
//            }
//            
//        }).resume()


//        self.weekChartView!.processedData += createProcessedDataFromRaw()
        //printData()
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
        //print("activity indicator started")
    }
    
    func stopActivityIndicatorAndClear() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.0)
        })
        //print("activity indicator stopped and cleared")
    }
    
    func stopActivityIndicatorWithError() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.errorStackView!.hidden = false
        })
        //print("activity indicator stopped with error")
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