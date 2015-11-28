//
//  ViewController.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 8/15/15.
//  Copyright (c) 2015 Taylor H. Gilbert. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var theTableView: UITableView?
    @IBOutlet var timeSlider: UISlider?
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?
    @IBOutlet var maskView: UIView?
    @IBOutlet var errorStackView: UIStackView?
    
    let username = "taylorg"
    
    var dateToBeUsed: NSDate?
    var dates: [(proposedDate: NSDate?, dateProposedAt: NSDate, sliderValue: Float)] = []
    
    // String (categoryName) -> String (dataTypeName) -> String (dataItemName) -> String (data item name)
    var categoryDictionary = [String: Dictionary<String, Dictionary<String, String>>]()
    
    // Int -> categories (-1 is categoryName, numbers = dataTypes) -> dataTypes (-1 is dataTypeName, numbers = dataItems) -> dataItems (number is dataItemName)
    var categoryByIndex = [Int: Dictionary<Int, Dictionary<Int, String>>]()
    
    var APIString: String?
    var request: Request?
    var hostname = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "kickOffNewRequest", name: UIApplicationDidBecomeActiveNotification, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        prepareStaticUI()
        kickOffNewRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareStaticUI() {
        self.activityIndicatorView!.hidesWhenStopped = true
        self.errorStackView!.hidden = true
        self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.0)
        timeSlider!.setValue(1, animated: true)
        updateTimeLabelWithDate(nil)
    }
    
    func parseData() {
        var categoryName = ""
        var dataTypeName = ""
        var dataItemName = ""
        var categoryIndex = -1
        var dataTypeIndex = -1
        var dataItemIndex = -1
        
        if APIString != nil {
            let splitByLines = APIString!.componentsSeparatedByString("\n")
            //let splitByLines: [String] = []
            
            
            for line in splitByLines {
                if line.substringToIndex(line.startIndex.advancedBy(3)) == ">>>" {
                    //println("category")
                    let removedArrows = line.substringFromIndex(line.startIndex.advancedBy(3))
                    let splitByCommas = removedArrows.componentsSeparatedByString(",")
                    let shortName = splitByCommas[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    categoryName = shortName
                    let humanName = splitByCommas[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    //println("\(shortName) \(humanName)")
                    categoryDictionary[categoryName] = [String: Dictionary<String,String>]()
                    categoryDictionary[categoryName]!["descriptor"] = [String: String]()
                    categoryDictionary[categoryName]!["descriptor"]!["descriptor"] = humanName
                    
                    categoryIndex++
                    dataTypeIndex = -1
                    dataItemIndex = -1
                    categoryByIndex[categoryIndex] = [Int: Dictionary<Int, String>]()
                    categoryByIndex[categoryIndex]![-1] = [Int: String]()
                    categoryByIndex[categoryIndex]![-1]![-1] = categoryName
                    
                    //let retrievedName = categoryDictionary[categoryName]!["descriptor"]!["descriptor"]!
                    //println("\(retrievedName)")
                }
                else if line.substringToIndex(line.startIndex.advancedBy(2)) == ">>" {
                    //println("dataType")
                    let removedArrows = line.substringFromIndex(line.startIndex.advancedBy(2))
                    let splitByCommas = removedArrows.componentsSeparatedByString(",")
                    let fullDataType = splitByCommas[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    let shortDataType = fullDataType.substringToIndex(fullDataType.startIndex.advancedBy(1))
                    let shortName = splitByCommas[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    dataTypeName = shortName
                    let humanName = splitByCommas[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    //println("\(shortName) \(humanName)")
                    categoryDictionary[categoryName]![dataTypeName] = [String: String]()
                    categoryDictionary[categoryName]![dataTypeName]!["descriptor"] = humanName
                    categoryDictionary[categoryName]![dataTypeName]!["dataType"] = shortDataType
                    
                    dataTypeIndex++
                    dataItemIndex = -1
                    categoryByIndex[categoryIndex]![dataTypeIndex] = [Int: String]()
                    categoryByIndex[categoryIndex]![dataTypeIndex]![-1] = shortName
                    
                    //let retrievedName = categoryDictionary[categoryName]![dataTypeName]!["descriptor"]!
                    //let retrievedType = categoryDictionary[categoryName]![dataTypeName]!["dataType"]!
                    //println("    \(retrievedName), \(retrievedType)")
                    
                }
                else if line.substringToIndex(line.startIndex.advancedBy(1)) == ">" {
                    //println("dataItem")
                    let removedArrows = line.substringFromIndex(line.startIndex.advancedBy(1))
                    let splitByCommas = removedArrows.componentsSeparatedByString(",")
                    let shortName = splitByCommas[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    dataItemName = shortName
                    let humanName = splitByCommas[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    //println("\(shortName) \(humanName)")
                    categoryDictionary[categoryName]![dataTypeName]![dataItemName] = humanName
                    
                    dataItemIndex++
                    categoryByIndex[categoryIndex]![dataTypeIndex]![dataItemIndex] = shortName
                    //let retrievedName = categoryDictionary[categoryName]![dataTypeName]![dataItemName]!
                    //println("        \(retrievedName)")
                }
            }
        }
    }

    
    func kickOffNewRequest() {
    
        clearTableView()
        startActivityIndicator()
        
        let URLPath = "http://taylorg.no-ip.org/cgi-bin/database/API"
        let URL = NSURL(string: URLPath)
        let urlRequest = NSURLRequest(URL: URL!)
        let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        urlSession.dataTaskWithRequest(urlRequest, completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) in
            print("complete")
        
            if data != nil {
                let dataString = String(data: data!, encoding:NSUTF8StringEncoding)!
                print(dataString)
                self.APIString = dataString
                self.hostname = "taylorg.no-ip.org"
                self.parseData()
                self.stopActivityIndicatorAndClear()
                //print("categoryDictionary.count: \(self.categoryDictionary.count)")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.theTableView!.reloadData()
                })
            }
            else {
                print("data was nil")
                self.stopActivityIndicatorWithError()
            }
            
        }).resume()
        
        
//        let awayString = try? String(contentsOfURL: URL!, encoding: NSUTF8StringEncoding)
//        //APIString = awayString!
//        //println(awayString)
//        if awayString == nil {
//            let URLPathHome = "http://192.168.1.110/cgi-bin/database/API"
//            let URLHome = NSURL(string: URLPathHome)
//            let homeString = try? String(contentsOfURL: URLHome!, encoding: NSUTF8StringEncoding)
//            //println(homeString)
//            APIString = homeString!
//            hostname = "192.168.1.110"
//        }
//        else {
//            APIString = awayString!
//            hostname = "taylorg.no-ip.org"
//        }
        
        //println(APIString)
        
        //let path = "/Users/taylorg/Desktop/life_data/life_data/mysqlDynamic API.txt"
        //let rawText = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
    }
    
    @IBAction func didClickRetry() {
        kickOffNewRequest()
    }
    
    func startActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.startAnimating()
            self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.25)
            self.errorStackView!.hidden = true
        })
        print("activity indicator started")
    }
    
    func stopActivityIndicatorAndClear() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.0)
        })
        print("activity indicator stopped and cleared")
    }
    
    func stopActivityIndicatorWithError() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.errorStackView!.hidden = false
        })
        print("activity indicator stopped with error")
    }
    
    func clearTableView() {
        self.APIString = nil
        self.categoryDictionary.removeAll()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.theTableView!.reloadData()
        })
    }



    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = theTableView!.dequeueReusableCellWithIdentifier("BasicCell")! as UITableViewCell
        cell.textLabel!.text = categoryDictionary[ categoryByIndex[indexPath.row]![-1]![-1]!]!["descriptor"]!["descriptor"]!
        //cell.detailTextLabel = UILabel()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryDictionary.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //let cell = tableView.cellForRowAtIndexPath(indexPath)
        //println(categoryByIndex[indexPath.row]![-1]![-1]!)
        theTableView!.deselectRowAtIndexPath(indexPath, animated: true)
        
        let usernameString = username
        var currentDate: NSDate?
        if dateToBeUsed == nil {
            currentDate = NSDate()
        }
        else {
            currentDate = dateToBeUsed!
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timeString = dateFormatter.stringFromDate(currentDate!)
        //println(timeString)
        let categoryString = categoryByIndex[indexPath.row]![-1]![-1]!
        let firstDataTypeName = categoryByIndex[indexPath.row]![0]![-1]!
        
        request = Request()
        request!.categoryIndex = indexPath.row
        request!.categoryDictionary = categoryDictionary
        request!.categoryByIndex = categoryByIndex
        request!.textBits.append("http://\(hostname)/cgi-bin/database/add?username=\(usernameString)&time=%22\(timeString)%22&category=\(categoryString)")
        for (dataType, _/*dataTypeDictionary*/) in categoryDictionary[categoryByIndex[indexPath.row]![-1]![-1]!]! {
            if dataType != "descriptor" {
                //println("  \(dataType)")
                request!.dataTypeNames.append(dataType)
            }
        }
        //println(request!.textBits[0])
        let type = categoryDictionary[categoryString]![firstDataTypeName]!["dataType"]!
        //println(type)
        if type == "s" {
            self.performSegueWithIdentifier("showSelectionViewController", sender: self)
        }
        else if type == "n" {
            self.performSegueWithIdentifier("showNumericViewController", sender: self)
        }
        else if type == "t" {
            self.performSegueWithIdentifier("showTextViewController", sender: self)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "showSelectionViewController" {
            let selectionViewController = segue.destinationViewController as! SelectionViewController
            selectionViewController.request = self.request
        }
        if segue.identifier! == "showNumericViewController" {
            let numericViewController = segue.destinationViewController as! NumericViewController
            numericViewController.request = self.request
        }
        if segue.identifier! == "showTextViewController" {
            let textViewController = segue.destinationViewController as! TextViewController
            textViewController.request = self.request
        }
        if segue.identifier! == "showReadDataViewController" {
            let readDataViewController = segue.destinationViewController as! ReadDataViewController
            readDataViewController.username = username
            readDataViewController.hostname = hostname
        }
    }
    
    @IBAction func didSlideSlider() {
    
        let now = NSDate()
        var updatedDate: NSDate?
        if timeSlider!.value != 1 {
            let numberOfSecondsOff = NSTimeInterval(60*60*24*(1-timeSlider!.value)*(1-timeSlider!.value))
            updatedDate = now.dateByAddingTimeInterval(-numberOfSecondsOff)
        }
        let dateFormatter = NSDateFormatter()
        updateTimeLabelWithDate(updatedDate)
        dateFormatter.dateFormat = "ss.SSS"
        dates += [(proposedDate: updatedDate, dateProposedAt: now, sliderValue: timeSlider!.value)]
//        println(dates.count)
//        println("now: \(dateFormatter.stringFromDate(now))")
//        if updatedDate == nil {
//            println("pro: now")
//        }
//        else {
//            println("pro: \(dateFormatter.stringFromDate(updatedDate!))")
//        }
        
    }
    
    @IBAction func slidingEnded() {
//        println("sliding ended!")
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM-d HH:mm:ss.SSS"
        let tolerance = 0.1
        while dates.count>0 {
            let thisDate: (proposedDate: NSDate?, dateProposedAt: NSDate, sliderValue: Float) = dates.removeLast()
            if now.timeIntervalSinceDate(thisDate.dateProposedAt) > tolerance {
                dateToBeUsed = thisDate.proposedDate
                updateTimeLabelWithDate(thisDate.proposedDate)
                timeSlider!.setValue(thisDate.sliderValue, animated: true)
//                if thisDate.proposedDate == nil {
//                    println("submittedDate: (nil)")
//                }
//                else {
//                    println("submitted date: \(dateFormatter.stringFromDate(thisDate.proposedDate!))")
//                }
                break
            }
        }
        dates.removeAll(keepCapacity: false)
    }
    
    func updateTimeLabelWithDate(date: NSDate?) {
        if date == nil {
        	timeLabel!.text = "now"
            self.dateToBeUsed = nil
        }
        else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM-d HH:mm"
            let timeString = dateFormatter.stringFromDate(date!)
            timeLabel!.text = "\(timeString)"
        }
    }
    
    @IBAction func didTapDeleteButton() {
        let alertController = UIAlertController(title: "delete most recent data point", message: "This action cannot be undone.", preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "delete", style: UIAlertActionStyle.Destructive, handler: {action in
            print("delete")
            let requestString = "http://\(self.hostname)/cgi-bin/database/deleteLast?username=\(self.username)"
            //println(requestString)
            let _ = try? NSString(contentsOfURL: NSURL(string: requestString)!, encoding: NSUTF8StringEncoding)
            
//            if !(response != nil) {
//                print("nil response")
//            }
//            else {
//                if response! != "command recognized" {
//                    print("failed to delete")
//                }
//                else {
//                    print("delete appears to have succeeded")
//                }
//            }
        })
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    class LabelCell: UITableViewCell {
        @IBOutlet var label: UILabel?
    }
}

