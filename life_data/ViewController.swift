//
//  ViewController.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 8/15/15.
//  Copyright (c) 2015 Taylor H. Gilbert. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    @IBOutlet var theTableView: UITableView?
    // String (categoryName) -> String (dataTypeName) -> String (dataItemName) -> String (data item name)
    var categoryDictionary = [String: Dictionary<String, Dictionary<String, String>>]()
    
    // Int -> categories (-1 is categoryName, numbers = dataTypes) -> dataTypes (-1 is dataTypeName, numbers = dataItems) -> dataItems (number is dataItemName)
    var categoryByIndex = [Int: Dictionary<Int, Dictionary<Int, String>>]()
    
    var request: Request?
    var hostname = ""
    
    func getData() {
        var categoryName = ""
        var dataTypeName = ""
        var dataItemName = ""
        var categoryIndex = -1
        var dataTypeIndex = -1
        var dataItemIndex = -1
        
        var APIString = ""
        let URLPath = "http://taylorg.no-ip.org/cgi-bin/database/API"
        let URL = NSURL(string: URLPath)
        let awayString = String(contentsOfURL: URL!, encoding: NSUTF8StringEncoding, error: nil)
        //println(awayString)
        if awayString == nil {
            let URLPathHome = "http://192.168.1.110/cgi-bin/database/API"
            let URLHome = NSURL(string: URLPathHome)
            let homeString = String(contentsOfURL: URLHome!, encoding: NSUTF8StringEncoding, error: nil)
            //println(homeString)
            APIString = homeString!
            hostname = "192.168.1.110"
        }
        else {
            APIString = awayString!
            hostname = "taylorg.no-ip.org"
        }
        
        println(APIString)
        
        //let path = "/Users/taylorg/Desktop/life_data/life_data/mysqlDynamic API.txt"
        //let rawText = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
        let splitByLines = APIString.componentsSeparatedByString("\n")
        for line in splitByLines {
            if line.substringToIndex(advance(line.startIndex, 3)) == ">>>" {
                //println("category")
                let removedArrows = line.substringFromIndex(advance(line.startIndex, 3))
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
            else if line.substringToIndex(advance(line.startIndex, 2)) == ">>" {
                //println("dataType")
                let removedArrows = line.substringFromIndex(advance(line.startIndex, 2))
                let splitByCommas = removedArrows.componentsSeparatedByString(",")
                let fullDataType = splitByCommas[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                let shortDataType = fullDataType.substringToIndex(advance(fullDataType.startIndex, 1))
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
            else if line.substringToIndex(advance(line.startIndex, 1)) == ">" {
                //println("dataItem")
                let removedArrows = line.substringFromIndex(advance(line.startIndex, 1))
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = theTableView!.dequeueReusableCellWithIdentifier("BasicCell") as! UITableViewCell
        cell.textLabel!.text = categoryDictionary[ categoryByIndex[indexPath.row]![-1]![-1]!]!["descriptor"]!["descriptor"]!
        //cell.detailTextLabel = UILabel()
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryDictionary.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        //println(categoryByIndex[indexPath.row]![-1]![-1]!)
        
        let usernameString = "morganm"
        let currentDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timeString = dateFormatter.stringFromDate(currentDate)
        //println(timeString)
        let categoryString = categoryByIndex[indexPath.row]![-1]![-1]!
        let firstDataTypeName = categoryByIndex[indexPath.row]![0]![-1]!
        
        request = Request()
        request!.categoryIndex = indexPath.row
        request!.categoryDictionary = categoryDictionary
        request!.categoryByIndex = categoryByIndex
        request!.textBits.append("http://\(hostname)/cgi-bin/database/add?username=\(usernameString)&time=%22\(timeString)%22&category=\(categoryString)")
        for (dataType, dataTypeDictionary) in categoryDictionary[categoryByIndex[indexPath.row]![-1]![-1]!]! {
            if dataType != "descriptor" {
                //println("  \(dataType)")
                request!.dataTypeNames.append(dataType)
            }
        }
        println(request!.textBits[0])
        var type = categoryDictionary[categoryString]![firstDataTypeName]!["dataType"]!
        println(type)
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
            let selectionViewController = segue.destinationViewController as! NumericViewController
            selectionViewController.request = self.request
        }
        if segue.identifier! == "showTextViewController" {
            let selectionViewController = segue.destinationViewController as! TextViewController
            selectionViewController.request = self.request
        }
    }

    class LabelCell: UITableViewCell {
        @IBOutlet var label: UILabel?
    }
}

