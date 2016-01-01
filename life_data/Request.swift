//
//  Request.swift
//  life_data
//
//  Created by Taylor H. Gilbert on 8/15/15.
//  Copyright (c) 2015 Taylor H. Gilbert. All rights reserved.
//

import Foundation

class Request {
    var textBits = [String]()
    var dataTypeNames = [String]()
    var filledOutSoFar = 0
    var categoryDictionary = [String: Dictionary<String, Dictionary<String, String>>]()
    var categoryByIndex = [Int: Dictionary<Int, Dictionary<Int, String>>]()
    var categoryIndex = 0
    
    func removeATextBit() {
        filledOutSoFar -= 1
        textBits.removeLast()
    }
    func addATextBit(bit: String) {
        textBits.append(bit)
        filledOutSoFar += 1
    }
}