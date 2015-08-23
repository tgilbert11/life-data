//
//  TextViewController.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 8/15/15.
//  Copyright (c) 2015 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import UIKit

class TextViewController: UIViewController {
    
    var request: Request?
    @IBOutlet var textView: UITextView?
    var categoryName: String?
    var dataTypeName: String?
    @IBOutlet var titleNavigationItem: UINavigationItem?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryName = request!.categoryByIndex[request!.categoryIndex]![-1]![-1]!
        dataTypeName = request!.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![-1]!
        titleNavigationItem!.title = request!.categoryDictionary[categoryName!]![dataTypeName!]!["descriptor"]!
    }
    
    override func viewWillDisappear(animated: Bool) {
        if self.isMovingFromParentViewController() {
            //println("moving from")
            request!.filledOutSoFar--
            request!.textBits.removeLast()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        textView!.becomeFirstResponder()
    }
    
    @IBAction func didTapOKButton() {
        //println("ok")
        
        let addedData = textView!.text!
        let newString = "&\(dataTypeName!)=%22\(addedData)%22"
        //println(newString)
        request!.textBits.append(newString)
        request!.filledOutSoFar++
        
        if request!.filledOutSoFar == request!.dataTypeNames.count {
            
            var requestURL = ""
            for item in request!.textBits {
                requestURL += item
            }
            //println(requestURL)
            let URL = NSURL(string: requestURL)!
            let response = String(contentsOfURL: URL, encoding: NSUTF8StringEncoding, error: nil)
            //println(response!)
            if response! == "command recognized" {
                self.navigationController!.popToRootViewControllerAnimated(true)
            }
            else {
                //println("oh crap")
            }
        }
        else {
            //println("eff this, another one?")
            let nextDataTypeName = request!.categoryByIndex[request!.categoryIndex]![request!.filledOutSoFar]![-1]!
            let type = request!.categoryDictionary[categoryName!]![nextDataTypeName]!["dataType"]!
            //println(type)
            if  type == "t" {
                self.performSegueWithIdentifier("showTextViewController", sender: self)
            }
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "showTextViewController" {
            let selectionViewController = segue.destinationViewController as! TextViewController
            selectionViewController.request = self.request
        }
        
    }
    
    
}