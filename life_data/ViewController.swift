//
//  ViewController.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 8/15/15.
//  Copyright (c) 2015 Taylor H. Gilbert. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var theTableView: UITableView!
    @IBOutlet var timeSlider: UISlider!
    @IBOutlet var timeLabel: UILabel!

	// BETO TODO: move to config file?
    let username = "taylorg"

	// BETO TODO: can we make these non optional?
    var dateToBeUsed: NSDate?
    var dates: [(proposedDate: NSDate?, dateProposedAt: NSDate, sliderValue: Float)] = []

	// BETO TODO: WTF is this, need typealiases
    // String (categoryName) -> String (dataTypeName) -> String (dataItemName) -> String (data item name)
    var categoryDictionary = [String: Dictionary<String, Dictionary<String, String>>]()
    
    // CategoryIndex -> categories (-1 is categoryName, numbers = dataTypes) -> dataTypes (-1 is dataTypeName, numbers = dataItems) -> dataItems (number is dataItemName)
	// BETO TODO: make this a struct or something, this is very hard to reason about
	typealias CategoryIndex = Int
	typealias DataTypeIndex = Int
	typealias DataItemIndex = Int
    var categoryByIndex = [CategoryIndex: Dictionary<DataTypeIndex, Dictionary<DataItemIndex, String>>]()

	// BETO TODO: can we make these non optional?
    var request: Request!
	var hostname: String?

    func getData() {
		let APIString: String
        let URLPath = "http://taylorg.no-ip.org/cgi-bin/database/API"
        let URL = NSURL(string: URLPath)!
        let awayString = try? String(contentsOfURL: URL, encoding: NSUTF8StringEncoding)
        //APIString = awayString!
        //println(awayString)
        if let realAwayString = awayString {
			APIString = realAwayString
			hostname = "taylorg.no-ip.org"
        }
        else {
			let URLPathHome = "http://192.168.1.110/cgi-bin/database/API"
			let URLHome = NSURL(string: URLPathHome)
			APIString = try! String(contentsOfURL: URLHome!, encoding: NSUTF8StringEncoding)
			//println(homeString)
			hostname = "192.168.1.110"
        }
        
        //println(APIString)
        
        //let path = "/Users/taylorg/Desktop/life_data/life_data/mysqlDynamic API.txt"
        //let rawText = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!

		// BETO TODO: gotta be a better way to interpret this data. Also should be in a class by itself to insulate this class from intimate knowledge of way data is structured
        let splitByLines = APIString.componentsSeparatedByString("\n")
		var categoryIndex: CategoryIndex = 0
		// BETO TODO: IUO usually are an anti-pattern, rethink this.
		// perhaps we do a bunch of nested while loops, so we say "find category, interpret data type, interpret data items, then done"
		var dataTypeIndex: DataTypeIndex!
		var dataItemIndex: Int!
		var categoryName: String!
		var dataTypeName: String!
		var dataItemName: String

		for line: String in splitByLines {
            if line.hasPrefix(">>>") {
                //println("category")

				// BETO TODO: oh god no, so many indices and NSString methods, gotta be a better way
                let removedArrows = line.substringFromIndex(line.startIndex.advancedBy(3))
                let splitByCommas = removedArrows.componentsSeparatedByString(",")
                categoryName = splitByCommas[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                let humanName = splitByCommas[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

				// BETO TODO: wtf this doesn't seem right
                categoryDictionary[categoryName] = ["descriptor": ["descriptor": humanName]]

				categoryIndex += 1

				// BETO TODO: need better sentinels?
                dataTypeIndex = -1
                dataItemIndex = -1
				categoryByIndex[categoryIndex] = [dataTypeIndex: [dataItemIndex: categoryName]]
            }
            else if line.hasPrefix(">>") {
                let removedArrows = line.substringFromIndex(line.startIndex.advancedBy(2))
                let splitByCommas = removedArrows.componentsSeparatedByString(",")
                let fullDataType = splitByCommas[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                let shortDataType = fullDataType.substringToIndex(fullDataType.startIndex.advancedBy(1))
                let shortName = splitByCommas[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                dataTypeName = shortName
                let humanName = splitByCommas[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                categoryDictionary[categoryName]![dataTypeName] = ["descriptor": humanName, "dataType": shortDataType]

				// BETO TODO: this is a bug, file a radar, should be able to +=
                dataTypeIndex = dataTypeIndex + 1
				// BETO TODO: need better sentinels?
                dataItemIndex = -1
				categoryByIndex[categoryIndex]![dataTypeIndex] = [dataItemIndex: shortName]

            }
            else if line.hasPrefix(">") {
                let removedArrows = line.substringFromIndex(line.startIndex.advancedBy(1))
                let splitByCommas = removedArrows.componentsSeparatedByString(",")
                let shortName = splitByCommas[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                dataItemName = shortName
                let humanName = splitByCommas[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                categoryDictionary[categoryName]![dataTypeName]![dataItemName] = humanName
                
                dataItemIndex = dataItemIndex + 1
                categoryByIndex[categoryIndex]![dataTypeIndex]![dataItemIndex] = shortName
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshLayout", name: UIApplicationDidBecomeActiveNotification, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshLayout()
    }
    
    func refreshLayout() {
        getData()
        timeSlider.setValue(1, animated: true)
        updateTimeLabelWithDate(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = theTableView.dequeueReusableCellWithIdentifier("BasicCell")! as UITableViewCell
		// BETO TODO: this might be the grossest line of code I've ever seen :) 7 '!' used 7 times
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
        theTableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let usernameString = username
        let currentDate: NSDate
        if dateToBeUsed == nil {
            currentDate = NSDate()
        }
        else {
            currentDate = dateToBeUsed!
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timeString = dateFormatter.stringFromDate(currentDate)
		// BETO TODO: NO NO NO NO NO OH GOOOODDDDDDD CTHULUUUUUUU
        let categoryString = categoryByIndex[indexPath.row]![-1]![-1]!
        let firstDataTypeName = categoryByIndex[indexPath.row]![0]![-1]!
        
        request = Request()
        request.categoryIndex = indexPath.row
        request.categoryDictionary = categoryDictionary
        request.categoryByIndex = categoryByIndex
        request.textBits.append("http://\(hostname)/cgi-bin/database/add?username=\(usernameString)&time=%22\(timeString)%22&category=\(categoryString)")
		// BETO TODO: CTHULUUUUUUUUUU
        for (dataType, _) in categoryDictionary[categoryByIndex[indexPath.row]![-1]![-1]!]! {
            if dataType != "descriptor" {
                request.dataTypeNames.append(dataType)
            }
        }
		// BETO TODO: CTHULUUUUUUUUUU
        let type = categoryDictionary[categoryString]![firstDataTypeName]!["dataType"]!
		// BETO TODO: use an enum here, this is gross
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
			// BETO TODO: could use a protocol and avoid casting to direct class type, all of these have request properties
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
        if timeSlider.value != 1 {
            let numberOfSecondsOff = NSTimeInterval(60*60*24*(1-timeSlider.value)*(1-timeSlider.value))
            updatedDate = now.dateByAddingTimeInterval(-numberOfSecondsOff)
        }
        let dateFormatter = NSDateFormatter()
        updateTimeLabelWithDate(updatedDate)
        dateFormatter.dateFormat = "ss.SSS"
        dates += [(proposedDate: updatedDate, dateProposedAt: now, sliderValue: timeSlider.value)]
    }
    
    @IBAction func slidingEnded() {
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM-d HH:mm:ss.SSS"
        let tolerance = 0.1
        while dates.count > 0 {
            let thisDate = dates.removeLast()
            if now.timeIntervalSinceDate(thisDate.dateProposedAt) > tolerance {
                dateToBeUsed = thisDate.proposedDate
                updateTimeLabelWithDate(thisDate.proposedDate)
                timeSlider.setValue(thisDate.sliderValue, animated: true)
                break
            }
        }
        dates.removeAll(keepCapacity: false)
    }
    
    func updateTimeLabelWithDate(date: NSDate?) {
        if date == nil {
        	timeLabel.text = "now"
            self.dateToBeUsed = nil
        }
        else {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM-d HH:mm"
            let timeString = dateFormatter.stringFromDate(date!)
            timeLabel.text = "\(timeString)"
        }
    }
    
    @IBAction func didTapDeleteButton() {
        let alertController = UIAlertController(title: "delete most recent data point", message: "This action cannot be undone.", preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "delete", style: UIAlertActionStyle.Destructive, handler: {action in
			// BETO TODO: this does nothing… intended?
            print("delete")
            let requestString = "http://\(self.hostname)/cgi-bin/database/deleteLast?username=\(self.username)"
            //println(requestString)
            let _ = try? NSString(contentsOfURL: NSURL(string: requestString)!, encoding: NSUTF8StringEncoding)
        })
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    class LabelCell: UITableViewCell {
        @IBOutlet var label: UILabel!
    }
}

