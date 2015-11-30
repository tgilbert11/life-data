//
//  SelectionViewController.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 8/15/15.
//  Copyright (c) 2015 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import UIKit

class SelectionViewController: UIViewController {
    
    var request: Request?
    var categoryName: String?
    var dataTypeName: String?
    @IBOutlet var titleNavigationItem: UINavigationItem?
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?
    @IBOutlet var maskView: UIView?
    @IBOutlet var errorStackView: UIStackView?
    @IBOutlet var theTableView: UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        prepareStaticUI()
        let indexPath = self.theTableView!.indexPathForSelectedRow
        if indexPath != nil {
            self.theTableView!.deselectRowAtIndexPath(indexPath!, animated: true)
        }
    }
    
    func prepareStaticUI() {
        categoryName = request!.categoryByIndex[request!.categoryIndex]![-1]![-1]!
        dataTypeName = request!.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![-1]!
        titleNavigationItem!.title = request!.categoryDictionary[categoryName!]![dataTypeName!]!["descriptor"]!
        self.maskView!.hidden = true
        self.activityIndicatorView!.hidesWhenStopped = true
    }
    
    @IBAction func didTapRetry() {
        self.kickOffNewRequest()
    }
            
    func startActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.startAnimating()
            self.maskView!.hidden = false
            self.errorStackView!.hidden = true
            print("started")
        })
    }
    
    func stopActivityIndicatorAndClear() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.maskView!.hidden = true
            self.removeATextBit()
            print("stop and clear")
        })
    }
    
    func stopActivityIndicatorWithError() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.errorStackView!.hidden = false
            print("stop with error")
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("basicCell", forIndexPath: indexPath) 
        let cellShortName = request!.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![indexPath.row]!
        let cellText = request!.categoryDictionary[categoryName!]![dataTypeName!]![cellShortName]!
        cell.textLabel!.text = cellText
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let theseKeys = request!.categoryDictionary[categoryName!]![dataTypeName!]!.keys
        return theseKeys.count-2
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let addedData = request!.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![indexPath.row]!
        let newString = "&\(dataTypeName!)=\(addedData)"
        //println(newString)
        request!.textBits.append(newString)
        request!.filledOutSoFar++
        
        if request!.filledOutSoFar == request!.dataTypeNames.count {
            self.kickOffNewRequest()
        }
        else {
            //println("eff this, another one?")
            let nextDataTypeName = request!.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![-1]!
            let type = request!.categoryDictionary[categoryName!]![nextDataTypeName]!["dataType"]!
            //println(type)
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
    
    func kickOffNewRequest() {
            var requestURL = ""
            for item in request!.textBits {
                requestURL += item
            }
            print("URL: \(requestURL)")
            print("at kickOffNewRequest, textBits.count: \(request!.textBits.count)")
            
            self.startActivityIndicator()
            
            NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(NSURLRequest(URL: NSURL(string: requestURL)!), completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if data != nil {
                    if String(data: data!, encoding: NSUTF8StringEncoding) == "command recognized" {
                        self.stopActivityIndicatorAndClear()
                        self.returnToRootViewController()
                    }
                    else {
                        self.stopActivityIndicatorWithError()
                    }
                }
                else {
                    self.stopActivityIndicatorWithError()
                }
                
            }).resume()

    }
    
    func returnToRootViewController() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationController!.popToRootViewControllerAnimated(true)
            print("popped to root view controller")
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "showSelectionViewController" {
            print("did selection segue SelectionViewController, textBits.count: \(request!.textBits.count)")
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
    
    func removeATextBit() {
        request!.filledOutSoFar--
        request!.textBits.removeLast()
        print("a text bit removed")
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.isMovingFromParentViewController() {
            print("moving from")
            self.stopActivityIndicatorAndClear()
            self.removeATextBit()
            print("textBits.count: \(request!.textBits.count)")
        }
    }
}
