//
//  SelectionViewController.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 8/15/15.
//  Copyright (c) 2015 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import UIKit

class SelectionViewController: UITableViewController {

	// BETO TODO: can these be non-optional?
    var request: Request!
    var categoryName: String?
    var dataTypeName: String?
    @IBOutlet var titleNavigationItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		// BETO TODO: CTHULUUUUUUUUUU
        categoryName = request.categoryByIndex[request.categoryIndex]![-1]![-1]!
        dataTypeName = request.categoryByIndex[request.categoryIndex]![request!.filledOutSoFar]![-1]!
        titleNavigationItem.title = request!.categoryDictionary[categoryName!]![dataTypeName!]!["descriptor"]!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		// BETO TODO: CTHULUUUUUUUUUU
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCell", forIndexPath: indexPath)
        let cellShortName = request.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![indexPath.row]!
        let cellText = request.categoryDictionary[categoryName!]![dataTypeName!]![cellShortName]!
        cell.textLabel!.text = cellText
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// BETO TODO: CTHULUUUUUUUUUU
        let theseKeys = request!.categoryDictionary[categoryName!]![dataTypeName!]!.keys
        return theseKeys.count-2
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let addedData = request.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![indexPath.row]!
        let newString = "&\(dataTypeName!)=\(addedData)"
        //println(newString)
        request.textBits.append(newString)
        request.filledOutSoFar += 1
        
        if request.filledOutSoFar == request.dataTypeNames.count {
            
            var requestURL = ""
            for item in request.textBits {
                requestURL += item
            }
            //println(requestURL)
            let URL = NSURL(string: requestURL)!
            let response = try? String(contentsOfURL: URL, encoding: NSUTF8StringEncoding)
            //println(response!)
			guard response == "command recognized" else {assert(false)}
			self.navigationController!.popToRootViewControllerAnimated(true)
        }
        else {
			// BETO TODO: CTHULUUUUUUUUUU
            let nextDataTypeName = request.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![-1]!
            let type = request!.categoryDictionary[categoryName!]![nextDataTypeName]!["dataType"]!
			// BETO TODO: enum again
            if type == "s" {
                self.performSegueWithIdentifier("showSelectionViewController", sender: self)
            }
            else if type == "n" {
                self.performSegueWithIdentifier("showNumericViewController", sender: self)
            }
            else if  type == "t" {
                self.performSegueWithIdentifier("showTextViewController", sender: self)
            }
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
    
    override func viewWillDisappear(animated: Bool) {
        if self.isMovingFromParentViewController() {
            request.filledOutSoFar -= 1
            request.textBits.removeLast()
        }
    }
}
