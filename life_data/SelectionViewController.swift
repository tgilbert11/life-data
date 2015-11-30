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
    
    // MARK: - properties
    
    var request: Request?
    var categoryName: String?
    var dataTypeName: String?
    @IBOutlet var titleNavigationItem: UINavigationItem?
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?
    @IBOutlet var maskView: UIView?
    @IBOutlet var errorStackView: UIStackView?
    @IBOutlet var theTableView: UITableView?
    
    // MARK: - State transitions
    
    /// This function is called when the page loads from another view.
    ///
    /// Enters state: Waiting_For_Inupt
    ///
    /// From state: away
    func enteringPage() { // allowable: exit page, submit new request
        categoryName = request!.categoryByIndex[request!.categoryIndex]![-1]![-1]!
        dataTypeName = request!.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![-1]!
        titleNavigationItem!.title = request!.categoryDictionary[categoryName!]![dataTypeName!]!["descriptor"]!
        self.maskView!.hidden = true
        self.activityIndicatorView!.hidesWhenStopped = true
        let indexPath = self.theTableView!.indexPathForSelectedRow
        if indexPath != nil {
            self.theTableView!.deselectRowAtIndexPath(indexPath!, animated: true)
        }
    }
    /// called to depart the view to another page in the app
    ///
    /// Enters state: away
    ///
    /// From state: Waiting_For_Input
    func exitingPage() {
        if self.isMovingFromParentViewController() {
            print("moving from")
            self.removeATextBit()
            print("textBits.count: \(request!.textBits.count)")
        }
    }
    
    /// user submits an action via TableView:didSelectRowAtIndexPath
    func tappedSubmitButton() {
        if request!.filledOutSoFar == request!.dataTypeNames.count {
            self.startActivityIndicator()
            self.kickOffNewRequest()
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        else {
            let nextDataTypeName = request!.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![-1]!
            let type = request!.categoryDictionary[categoryName!]![nextDataTypeName]!["dataType"]!
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
    
    /// happens when background thread report successful URLRequest
    func requestSucceeded() {
        print("requestSucceeded()")
        self.stopActivityIndicatorAndClear()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationItem.setHidesBackButton(false, animated: false)
        })
        self.returnToRootViewController()
    }
    
    func requestFailed() {
        self.stopActivityIndicatorWithError()
    }
    
    @IBAction func tappedRetry() {
        self.startActivityIndicator()
        self.kickOffNewRequest()
    }
    
    @IBAction func cancelledRequest() {
        self.stopActivityIndicatorAndClear()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationItem.setHidesBackButton(false, animated: false)
            let indexPath = self.theTableView!.indexPathForSelectedRow
            if indexPath != nil {
                self.theTableView!.deselectRowAtIndexPath(indexPath!, animated: true)
            }
            self.removeATextBit()
        })
    }
    
    // MARK: - helper methods
    
    /// happens async on main queue
    func startActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.startAnimating()
            self.maskView!.hidden = false
            self.errorStackView!.hidden = true
            print("started")
        })
    }
    
    /// happens async on main queue
    func stopActivityIndicatorAndClear() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.maskView!.hidden = true
            print("stop and clear")
        })
    }
    
    /// happens async on main queue
    func stopActivityIndicatorWithError() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.errorStackView!.hidden = false
            print("stop with error")
        })
    }
    
    func removeATextBit() {
        request!.filledOutSoFar--
        request!.textBits.removeLast()
        print("a text bit removed")
    }
    
    /// dispatches async main queue request to popToRootViewController
    func returnToRootViewController() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.navigationController!.popToRootViewControllerAnimated(true)
            print("popped to root view controller")
        })
    }
    
    // MARK: - Networking stuff
    
    func kickOffNewRequest() {
        var requestURL = ""
        for item in request!.textBits {
            requestURL += item
        }
        
        NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(NSURLRequest(URL: NSURL(string: requestURL)!), completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if data != nil {
                if String(data: data!, encoding: NSUTF8StringEncoding) == "command recognized" {
                    self.requestSucceeded()
                }
                else {
                    self.requestFailed()
                }
            }
            else {
                self.requestFailed()
            }
            
        }).resume()
        
    }
    
    // MARK: - View controller-triggered methods
    
    override func viewWillAppear(animated: Bool) {
        self.enteringPage()
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
    
    override func viewWillDisappear(animated: Bool) {
        self.exitingPage()
    }
    
    // MARK: - Table-view stuff

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
        request!.textBits.append(newString)
        request!.filledOutSoFar++
        
        self.tappedSubmitButton()
    }
}
