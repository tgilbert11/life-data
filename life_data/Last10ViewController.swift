//
//  Last10ViewController.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 9/20/15.
//  Copyright © 2015 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import UIKit

class Last10ViewController: UIViewController {
    @IBOutlet var textField: UITextView?
    @IBOutlet var errorStackView: UIStackView?
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView?
    @IBOutlet var maskView: UIView?
    
    var username: String?
    var hostname: String?
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        prepareStaticUI()
        kickOffNewRequest()
    }
    
    override func viewDidLayoutSubviews() {
        self.textField!.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    
    func prepareStaticUI() {
        self.textField!.selectable = true
        self.textField!.selectable = false
        self.activityIndicatorView!.hidesWhenStopped = true
        self.errorStackView!.hidden = true
        self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.0)
    }
    
    func clearDynamicData() {
        self.textField!.text = ""
    }
    
    @IBAction func didTapRetry() {
        kickOffNewRequest()
    }
    
    func kickOffNewRequest() {
        
        clearDynamicData()
        startActivityIndicator()
    
        let urlString = "http://taylorg.no-ip.org/cgi-bin/database/readLast10?username=\(username!)"
        
        NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(NSURLRequest(URL: NSURL(string: urlString)!)) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            
            if data != nil {
                self.requestSucceededWithData(String(data: data!, encoding: NSUTF8StringEncoding)!)
            }
            else {
                self.stopActivityIndicatorWithError()
            }
            
        }.resume()
    }
    
    func requestSucceededWithData(data: String) {
        let splitByBreak = data.componentsSeparatedByString("<br>")
        var returnString = ""
        for line in splitByBreak {
            let splitBySemicolon = line.componentsSeparatedByString(";")
            var firstLine = true
            for item in splitBySemicolon {
                if firstLine {
                    returnString += "\(item)\n"
                    firstLine = false
                }
                else {
                    returnString += "          \(item)\n"
                }
            }
        }
        self.stopActivityIndicatorAndClear()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.textField!.text = returnString
        })
    }
    
    func startActivityIndicator() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.startAnimating()
            self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.25)
            self.errorStackView!.hidden = true
        })
    }
    
    func stopActivityIndicatorAndClear() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.maskView!.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.0)
        })
    }
    
    func stopActivityIndicatorWithError() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.activityIndicatorView!.stopAnimating()
            self.errorStackView!.hidden = false
        })
    }
    

    
}