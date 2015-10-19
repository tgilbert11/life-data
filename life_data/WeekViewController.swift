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

    override func viewDidLoad() {
        super.viewDidLoad()
        let date = NSDate()
        let eightDaysAgo = date.dateByAddingTimeInterval(-7*24*60*60)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let fromTime = dateFormatter.stringFromDate(eightDaysAgo)
        //print(fromTime)
        getDataFromTime(fromTime)
        addSleepData()
        //printData()
    }
    
    func getDataFromTime(fromTime: String) {
        let urlString = "http://\(hostname!)/cgi-bin/database/readFromTime?username=\(username!)&fromTime=%22\(fromTime)%22"
        //print(urlString)
        let requestString = try? NSString(contentsOfURL: NSURL(string: urlString)!, encoding: NSUTF8StringEncoding)
        //print(requestString!)
        let splitByBreak = requestString!.componentsSeparatedByString("<br>")
        for line in splitByBreak {
            //print(line)
            //print(line.characters.count)
            if line.characters.count > 0 {
                data += [line]
            }
            else {
                //print("skipped one in data read")
            }
        }
        //data += splitByBreak
    }

    func addSleepData() {
        var sleepData: [(date: NSDate, event: String)] = []
        for line in data {
            //print(line)
            let splitBySemicolon = line.componentsSeparatedByString(";")
            let category = splitBySemicolon[1].componentsSeparatedByString("category: ")[1]
            //print(category)
            if category == "sleep" {
                //print("yes")
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.dateFromString(splitBySemicolon[0].componentsSeparatedByString("time: ")[1])!
                //print(date)
                sleepData += [(date, splitBySemicolon[2].componentsSeparatedByString("event: ")[1])]
            }
        }
        //for (date, event) in sleepData {
        //    print("date: \(date), event: \(event)")
        //}
        self.weekChartView!.sleepData = sleepData
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
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//    }
    
}