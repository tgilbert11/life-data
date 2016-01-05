//
//  MyNetworkHandler.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 12/31/15.
//  Copyright © 2015 Taylor H. Gilbert. All rights reserved.
//

import Foundation

class MyNetworkHandler {

    static var lastLocationWasHome = false
    static let homeHostnameString = "http://192.168.1.110"
    static let awayHostnameString = "http://taylorg.no-ip.org"

    class func submitRequest(requestPath: String, failed: () -> (), succeeded: (result: String) -> ()) {
        NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(NSURLRequest(URL: NSURL(string: "\(lastLocationWasHome ? homeHostnameString : awayHostnameString)\(requestPath)")!), completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) in
            if data != nil && response != nil && response!.isKindOfClass(NSHTTPURLResponse) && (response! as! NSHTTPURLResponse).statusCode == 200 {
                succeeded(result: String(data: data!, encoding: NSUTF8StringEncoding)!)
            }
            else {
                NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration()).dataTaskWithRequest(NSURLRequest(URL: NSURL(string: "\(!lastLocationWasHome ? homeHostnameString : awayHostnameString)\(requestPath)")!), completionHandler: {(data: NSData?, response: NSURLResponse?, error: NSError?) in
                    if data != nil && response != nil && response!.isKindOfClass(NSHTTPURLResponse) && (response! as! NSHTTPURLResponse).statusCode == 200 {
                        lastLocationWasHome = !lastLocationWasHome
                        succeeded(result: String(data: data!, encoding:NSUTF8StringEncoding)!)
                    }
                    else {
                        failed()
                    }
                }).resume()
                
            }
        }).resume()
        
    }
}