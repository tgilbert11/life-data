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
    
    let username = "dev"
    
    var dateToBeUsed: NSDate?
    var dates: [(proposedDate: NSDate?, dateProposedAt: NSDate, sliderValue: Float)] = []
    
    // String (categoryName) -> String (dataTypeName) -> String (dataItemName) -> String (data item name)
    var categoryDictionary = [String: Dictionary<String, Dictionary<String, String>>]()
    
    // Int -> categories (-1 is categoryName, numbers = dataTypes) -> dataTypes (-1 is dataTypeName, numbers = dataItems) -> dataItems (number is dataItemName)
    var categoryByIndex = [Int: Dictionary<Int, Dictionary<Int, String>>]()
    
    var APIString: String?
    var request: Request?

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "kickOffNewRequest", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        prepareStaticUI()
        kickOffNewRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func prepareStaticUI() {
        self.activityIndicatorView!.hidesWhenStopped = true
        self.errorStackView!.hidden = true
        self.maskView!.hidden = true
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
            
            for line in splitByLines {
                if line.substringToIndex(line.startIndex.advancedBy(3)) == ">>>" {
                    let removedArrows = line.substringFromIndex(line.startIndex.advancedBy(3))
                    let splitByCommas = removedArrows.componentsSeparatedByString(",")
                    let shortName = splitByCommas[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    categoryName = shortName
                    let humanName = splitByCommas[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    categoryDictionary[categoryName] = [String: Dictionary<String,String>]()
                    categoryDictionary[categoryName]!["descriptor"] = [String: String]()
                    categoryDictionary[categoryName]!["descriptor"]!["descriptor"] = humanName
                    
                    categoryIndex++
                    dataTypeIndex = -1
                    dataItemIndex = -1
                    categoryByIndex[categoryIndex] = [Int: Dictionary<Int, String>]()
                    categoryByIndex[categoryIndex]![-1] = [Int: String]()
                    categoryByIndex[categoryIndex]![-1]![-1] = categoryName
                }
                else if line.substringToIndex(line.startIndex.advancedBy(2)) == ">>" {
                    let removedArrows = line.substringFromIndex(line.startIndex.advancedBy(2))
                    let splitByCommas = removedArrows.componentsSeparatedByString(",")
                    let fullDataType = splitByCommas[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    let shortDataType = fullDataType.substringToIndex(fullDataType.startIndex.advancedBy(1))
                    let shortName = splitByCommas[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    dataTypeName = shortName
                    let humanName = splitByCommas[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    categoryDictionary[categoryName]![dataTypeName] = [String: String]()
                    categoryDictionary[categoryName]![dataTypeName]!["descriptor"] = humanName
                    categoryDictionary[categoryName]![dataTypeName]!["dataType"] = shortDataType
                    
                    dataTypeIndex++
                    dataItemIndex = -1
                    categoryByIndex[categoryIndex]![dataTypeIndex] = [Int: String]()
                    categoryByIndex[categoryIndex]![dataTypeIndex]![-1] = shortName
                }
                else if line.substringToIndex(line.startIndex.advancedBy(1)) == ">" {
                    let removedArrows = line.substringFromIndex(line.startIndex.advancedBy(1))
                    let splitByCommas = removedArrows.componentsSeparatedByString(",")
                    let shortName = splitByCommas[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    dataItemName = shortName
                    let humanName = splitByCommas[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    categoryDictionary[categoryName]![dataTypeName]![dataItemName] = humanName
                    dataItemIndex++
                    categoryByIndex[categoryIndex]![dataTypeIndex]![dataItemIndex] = shortName
                }
            }
        }
    }

    
    func kickOffNewRequest() {
    
        clearDynamicData()
        startActivityIndicator()
        
        let failedClosure = {() in
            dispatch_async(dispatch_get_main_queue(), { () in
                self.stopActivityIndicatorWithError()
            })
        }
        let succeededClosure = {(result: String) in
            dispatch_async(dispatch_get_main_queue(), { () in
                self.APIRequestSucceededWithAPIString(result)
                self.stopActivityIndicatorAndClear()
            })
        }
        MyNetworkHandler.submitRequest("/cgi-bin/database/API", failed: failedClosure, succeeded: succeededClosure)

    }
    
    @IBAction func didClickRetry() {
        kickOffNewRequest()
    }
    
    func APIRequestSucceededWithAPIString(apiString: String) {
        self.APIString = apiString
        self.parseData()
        self.stopActivityIndicatorAndClear()
        self.theTableView!.reloadData()
    }
    
    func startActivityIndicator() {
        self.activityIndicatorView!.startAnimating()
        self.maskView!.hidden = false
        self.errorStackView!.hidden = true
    }
    
    func stopActivityIndicatorAndClear() {
        self.activityIndicatorView!.stopAnimating()
        self.maskView!.hidden = true
    }
    
    func stopActivityIndicatorWithError() {
        self.activityIndicatorView!.stopAnimating()
        self.errorStackView!.hidden = false
    }
    
    func clearDynamicData() {
        self.APIString = nil
        self.categoryDictionary.removeAll()
        self.theTableView!.reloadData()
        self.updateTimeLabelWithDate(nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = theTableView!.dequeueReusableCellWithIdentifier("BasicCell")! as UITableViewCell
        cell.textLabel!.text = categoryDictionary[ categoryByIndex[indexPath.row]![-1]![-1]!]!["descriptor"]!["descriptor"]!
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryDictionary.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
        let categoryString = categoryByIndex[indexPath.row]![-1]![-1]!
        let firstDataTypeName = categoryByIndex[indexPath.row]![0]![-1]!
        
        request = Request()
        request!.categoryIndex = indexPath.row
        request!.categoryDictionary = categoryDictionary
        request!.categoryByIndex = categoryByIndex
        request!.textBits.append("/cgi-bin/database/add?username=\(usernameString)&time=%22\(timeString)%22&category=\(categoryString)")
        for (dataType, _) in categoryDictionary[categoryByIndex[indexPath.row]![-1]![-1]!]! {
            if dataType != "descriptor" {
                request!.dataTypeNames.append(dataType)
            }
        }
        let type = categoryDictionary[categoryString]![firstDataTypeName]!["dataType"]!
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
            //print("did selection segue viewController")
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
    }
    
    @IBAction func slidingEnded() {
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

            let requestString = "/cgi-bin/database/deleteLast?username=\(self.username)"
            let failedClosure = {() in
                
            }
            let succeededClosure = {(result: String) in
                
            }
            MyNetworkHandler.submitRequest(requestString, failed: failedClosure, succeeded: succeededClosure)

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

