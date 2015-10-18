//
//  ReadDataViewController.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 8/22/15.
//  Copyright (c) 2015 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import UIKit

class ReadDataViewController: UIViewController {

    var username: String?
    var hostname: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "showWeightViewController" {
            let weightViewController = segue.destinationViewController as! WeightViewController
            weightViewController.username = username!
            weightViewController.category = "weight"
            weightViewController.hostname = hostname
        }
        if segue.identifier! == "showLast10ViewController" {
            let last10ViewController = segue.destinationViewController as! Last10ViewController
            last10ViewController.username = username!
            last10ViewController.hostname = hostname
        }
        if segue.identifier! == "showWeekViewController" {
            let weekViewController = segue.destinationViewController as! WeekViewController
            weekViewController.username = username!
            weekViewController.hostname = hostname
            print("seguePrepared")
        }
    }
    
}