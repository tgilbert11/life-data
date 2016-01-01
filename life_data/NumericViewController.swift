//
//  NumericViewController.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 8/15/15.
//  Copyright (c) 2015 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import UIKit

class NumericViewController: UIViewController {
    
    var request: Request?
    @IBOutlet var textField: UITextField!
    var categoryName: String?
    var dataTypeName: String?
    @IBOutlet var titleNavigationItem: UINavigationItem?
    
    @IBOutlet var maskView: UIView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var errorStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.prepareStaticUI()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.isMovingFromParentViewController() {
            //println("moving from")
            request!.removeATextBit()
        }
    }
    
    func prepareStaticUI() {
        categoryName = request!.categoryByIndex[request!.categoryIndex]![-1]![-1]!
        dataTypeName = request!.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![-1]!
        titleNavigationItem!.title = request!.categoryDictionary[categoryName!]![dataTypeName!]!["descriptor"]!
        textField!.becomeFirstResponder()
        self.maskView.hidden = true
    }
    
    func requestStarted() {
        self.textField.resignFirstResponder()
        self.errorStackView.hidden = true
        self.activityIndicatorView.startAnimating()
        self.maskView.hidden = false
    }
    
    func makeRequest() {
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
    
    func requestFailed() {
        self.errorStackView.hidden = false
        self.activityIndicatorView.stopAnimating()
    }
    
    func requestSucceeded() {
        self.errorStackView.hidden = true
        self.activityIndicatorView.stopAnimating()
        self.maskView.hidden = true
        self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func didTapOKButton() {
        //println("ok")
        
        let addedData = textField!.text!
        let newString = "&\(dataTypeName!)=\(addedData)"
        //println(newString)
        request!.addATextBit(newString)
        
        if request!.filledOutSoFar == request!.dataTypeNames.count {
            self.requestStarted()
            self.makeRequest()
        }
        else {
            //println("eff this, another one?")
            let nextDataTypeName = request!.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![-1]!
            let type = request!.categoryDictionary[categoryName!]![nextDataTypeName]!["dataType"]!
            //println(type)
            if type == "n" {
                self.performSegueWithIdentifier("showNumericViewController", sender: self)
            }
            else if  type == "t" {
                self.performSegueWithIdentifier("showTextViewController", sender: self)
            }
        }
    }
    
    @IBAction func didTapCancelButton() {
        self.textField.becomeFirstResponder()
        self.errorStackView.hidden = true
        self.activityIndicatorView.stopAnimating()
        self.maskView.hidden = true
        request!.removeATextBit()
    }
    
    @IBAction func didTapRetryButton() {
        self.requestStarted()
        self.makeRequest()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "showNumericViewController" {
            let selectionViewController = segue.destinationViewController as! NumericViewController
            selectionViewController.request = self.request
        }
        if segue.identifier! == "showTextViewController" {
            let selectionViewController = segue.destinationViewController as! TextViewController
            selectionViewController.request = self.request
        }
    
    }
}