//
//  SettingsController.swift
//  GHMenuBar
//
//  Created by Bob Vork on 08/11/14.
//  Copyright (c) 2014 Bob Vork. All rights reserved.
//

import Cocoa

class SettingsController: NSWindowController {
   
    @IBOutlet weak var searchField: NSTextField!
    @IBOutlet weak var tokenField: NSSecureTextField!
    
    
    let userDef = NSUserDefaults.standardUserDefaults()
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        applyButtonPressed(sender)
        hide()
    }
    
    @IBAction func applyButtonPressed(sender: AnyObject) {
        let search = searchField.stringValue
        userDef.setValue(search, forKey: "UserDefSearchString")
        userDef.setValue(tokenField.stringValue, forKey: "UserDefTokenKey")
        userDef.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName("search-changed",
            object: nil, userInfo: ["string":search])
    }
    
    @IBAction func notificationPrefChanged(sender: NSButton) {
        let enabled = (sender.state == NSOnState)
        userDef.setBool(enabled, forKey: "UserDefEnableNotifications")
        userDef.synchronize()
    }
    
    
    func show() {
        window?.makeKeyAndOrderFront(self)
        if let searchString = userDef.stringForKey("UserDefSearchString") {
            println(searchString)
            searchField.stringValue = searchString
        }
    }
    
    func hide() {
        window?.orderOut(self)
    }
}
