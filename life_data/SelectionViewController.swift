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
        self.navigationItem.setHidesBackButton(false, animated: false)
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
            self.removeATextBit()
        }
    }
    
    /// user submits an action via TableView:didSelectRowAtIndexPath
    func tappedSubmitButton() {
        if request!.filledOutSoFar == request!.dataTypeNames.count {
            self.startActivityIndicator()
            self.kickOffNewRequest()
        }
        else {
            let nextDataTypeName = request!.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![-1]!
            let type = request!.categoryDictionary[categoryName!]![nextDataTypeName]!["dataType"]!
            switch (type) {
            case "s":
                self.performSegueWithIdentifier("showSelectionViewController", sender: self)
            case "n":
                self.performSegueWithIdentifier("showNumericViewController", sender: self)
            case "t":
                self.performSegueWithIdentifier("showTextViewController", sender: self)
            default:
                break
            }
        }
    }
    
    /// happens when background thread report successful URLRequest
    func requestSucceeded() {
        self.stopActivityIndicatorAndClear()
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
        self.removeATextBit()
        self.stopActivityIndicatorAndClear()
    }
    
    // MARK: - helper methods
    
    /// happens async on main queue
    func startActivityIndicator() {
        self.activityIndicatorView!.startAnimating()
        self.maskView!.hidden = false
        self.errorStackView!.hidden = true
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    /// happens async on main queue
    func stopActivityIndicatorAndClear() {
        self.activityIndicatorView!.stopAnimating()
        self.maskView!.hidden = true
        self.navigationItem.setHidesBackButton(false, animated: false)
        let indexPath = self.theTableView!.indexPathForSelectedRow
        if indexPath != nil {
            self.theTableView!.deselectRowAtIndexPath(indexPath!, animated: true)
        }
    }
    
    /// happens async on main queue
    func stopActivityIndicatorWithError() {
        self.activityIndicatorView!.stopAnimating()
        self.errorStackView!.hidden = false
    }
    
    func removeATextBit() {
        request!.removeATextBit()
    }
    
    /// dispatches async main queue request to popToRootViewController
    func returnToRootViewController() {
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - Networking stuff
    
    func kickOffNewRequest() {
        
        var requestURLString = ""
        for item in request!.textBits {
            requestURLString += item
        }
        
        let failedClosure = {() in
            dispatch_async(dispatch_get_main_queue(), { () in
                self.requestFailed()
            })
        }
        let succeededClosure = {(result: String) in
            dispatch_async(dispatch_get_main_queue(), { () in
                if result == "command recognized" {
                    self.requestSucceeded()
                }
                else {
                    self.requestFailed()
                }
            })
        }
        MyNetworkHandler.submitRequest(requestURLString, failed: failedClosure, succeeded: succeededClosure)
        
    }
    
    // MARK: - View controller-triggered methods
    
    override func viewWillAppear(animated: Bool) {
        self.enteringPage()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier!) {
        case "showSelectionViewController":
            let selectionViewController = segue.destinationViewController as! SelectionViewController
            selectionViewController.request = self.request
        case "showNumericViewController":
            let selectionViewController = segue.destinationViewController as! NumericViewController
            selectionViewController.request = self.request
        case "showTextViewController":
            let selectionViewController = segue.destinationViewController as! TextViewController
            selectionViewController.request = self.request
        default:
            break
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
