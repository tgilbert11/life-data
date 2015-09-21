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
    
    var username: String?
    var hostname: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField!.selectable = true
        self.textField!.text = getTextFromServer()
        self.textField!.selectable = false
    }
    
    override func viewDidLayoutSubviews() {
        self.textField!.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    
    func getTextFromServer() -> String {
        let urlString = "http://\(hostname!)/cgi-bin/database/readLast10?username=\(username!)"
        //println(requestString)
        let requestString = try? NSString(contentsOfURL: NSURL(string: urlString)!, encoding: NSUTF8StringEncoding)
        //println(returnString!)
        let splitByBreak = requestString!.componentsSeparatedByString("<br>")
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
        return returnString
    }
    
}