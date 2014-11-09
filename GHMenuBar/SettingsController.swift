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
        userDef.setValue(searchField.stringValue, forKey: "UserDefSearchString")
        userDef.synchronize()
        println(searchField.stringValue)

    }
    
    @IBAction func applyButtonPressed(sender: AnyObject) {
        let search = searchField.stringValue
        userDef.setValue(search, forKey: "UserDefSearchString")
        userDef.synchronize()
        println(searchField.stringValue)
        
        NSNotificationCenter.defaultCenter().postNotificationName("search-changed",
            object: nil, userInfo: ["string":search])
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
