//
//  GHIssue.swift
//  GHMenuBar
//
//  Created by Bob Vork on 08/11/14.
//  Copyright (c) 2014 Bob Vork. All rights reserved.
//

import Cocoa

class GHIssue: NSObject {
    var num:Int = -1
    var title:String = ""
    var htmlUrl:String = ""
    
    init(dict: NSDictionary) {
        if let n = dict.valueForKey("number") as? Int {
            num = n
        }
        if let t = dict.valueForKey("title") as? String {
            title = t
        }
        if let html = dict.valueForKey("html_url") as? String {
            htmlUrl = html
        }
        super.init()
    }
   
}
