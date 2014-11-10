//
//  GHManager.swift
//  GHMenuBar
//
//  Created by Bob Vork on 06/11/14.
//  Copyright (c) 2014 Bob Vork. All rights reserved.
//

import Cocoa

protocol GHManagerDelegate {
    func ghManagerDidFindIssues(issues: [GHIssue])
}

class GHManager: NSObject, NSUserNotificationCenterDelegate {
    
    typealias ghResponse = (response: NSDictionary?, error: NSError?) -> Void
    let baseURL = NSURL(string: "https://api.github.com")
    
    var search:String = ""
    let timeInterval:NSTimeInterval = 10 // time interval in seconds
    var timer:NSTimer?
    var delegate:GHManagerDelegate?
    var lastIssueNums:[Int] = []
    
    let userDef = NSUserDefaults.standardUserDefaults()
    
    
    func token() -> String {
        if let gToken = userDef.stringForKey("UserDefTokenKey") {
            return gToken
        }
        return ""
    }
    
    func startRefreshLoop() {
        
        if (timer != nil) {
            timer!.invalidate()
        }
        self.reloadData()
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval,
            target: self,
            selector: "reloadData",
            userInfo: nil,
            repeats: true)
    }
    
    func reloadData() {
        
        getPullRequests { [unowned self] (response, error) -> Void in
            if let dict = response {
                if (dict["items"] == nil) {
                    return;
                }
                let issues = (dict["items"]?.allObjects as [NSDictionary]).map {
                    (var d) -> GHIssue in
                    return GHIssue(dict: d)
                }
                
                let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
                appDelegate.updateNumberOfIssues(issues.count)

                
                let issueNums = issues.map({ (i: GHIssue) -> Int in
                    return i.num
                })
                
                var newIssues:[GHIssue] = []
                for issue in issues {
                    if !(contains(self.lastIssueNums, issue.num)) {
                        newIssues += [issue]
                    }
                }
                
                self.lastIssueNums = issueNums
                
                var message = "Found "
                switch newIssues.count {
                case 0:
                    message += "no new issues"
                case 1:
                    message += "1 new issue"
                case 2...5:
                    message += "some new issues"
                default:
                    message += "lots of new issues"
                }
                
                println(message)
                
                if newIssues.count > 0 && self.userDef.boolForKey("UserDefEnableNotifications") {
                    self.deliverNotification(message)
                }
                self.delegate?.ghManagerDidFindIssues(issues)
            }
        }
    }
    
    func loadSearchString() {
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
        
//        println("Full url: \(fullURL?.absoluteString) ")
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        let request = NSMutableURLRequest(URL: fullURL!)
        
        let token = self.token()
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response:NSURLResponse!, error:NSError!) -> Void in
            
            if (error != nil) {
                println("API error: \(error.userInfo)")
            }
            
            var jsonError:NSError?
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSArray {
                
                if let handler = responseHandler {
                    handler(response: ["items":json], error: nil)
                }
                
            } else if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &jsonError) as? NSDictionary {
                
                if let handler = responseHandler {
                    handler(response: json, error: nil)
                }
                
            } else {
                println("Error parsing json: \(jsonError)")
            }
        })
        
        task.resume()
    }
    
    func deliverNotification(title: String) {
        let notification = NSUserNotification()
        notification.title = "OctoBar"
        notification.subtitle = title
        notification.actionButtonTitle = "Show me"
        notification.hasActionButton = true
        let notCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        notCenter.delegate = self
        notCenter.deliverNotification(notification)
        
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter,
        didActivateNotification notification: NSUserNotification) {
            
            let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
            
            appDelegate.showMenu()
            
    }
}
