//
//  GHManager.swift
//  GHMenuBar
//
//  Created by Bob Vork on 06/11/14.
//  Copyright (c) 2014 Bob Vork. All rights reserved.
//

import Cocoa

class GHManager: NSObject {
    
    typealias ghResponse = (response: NSDictionary?, error: NSError?) -> Void
    let baseURL = NSURL(string: "https://api.github.com")
    let token = "336156d5ce665107239a0118b2bef6bc00fb66ea"  // TODO: get this out of here
    var search:String = ""
        
    func loadSearchString() {
        let userDef = NSUserDefaults.standardUserDefaults()
        if let savedString = userDef.stringForKey("UserDefSearchString") {
            search = savedString
        } else {
            search = "search/issues?q=mentions:bob-codingdutchmen+is:open&sort=updated"
            userDef.setValue(search, forKey: "UserDefSearchString")
            userDef.synchronize()
        }
    }
    
    func getPullRequests(handler: ghResponse) {
        loadSearchString()
        requestWithPath(search, responseHandler: handler)
    }
    
    func requestWithPath(path: NSString, responseHandler: ghResponse?) {

        let fullURL = NSURL(string: path, relativeToURL: baseURL)
        
        println("Full url: \(fullURL?.absoluteString) ")
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let request = NSMutableURLRequest(URL: fullURL!)
        
        request.setValue("token \(self.token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            
            if (error != nil) {
                println("API error: \(error.userInfo)")
            }
            
            var jsonError:NSError?
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSArray {
                
//                println("got array: \(json)")
                if let handler = responseHandler {
                    handler(response: ["items":json], error: nil)
                }
                
            } else if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary {
                
//                println("got dictionary: \(json)")
                if let handler = responseHandler {
                    handler(response: json, error: nil)
                }
                
                
            } else {
                println("Error parsing json: \(jsonError)")
            }
            
        })
        
        task.resume()
        
        
    }
   
}
