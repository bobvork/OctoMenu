//
//  AppDelegate.swift
//  GHMenuBar
//
//  Created by Bob Vork on 06/11/14.
//  Copyright (c) 2014 Bob Vork. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var menu: NSMenu!
    
    @IBOutlet weak var popover: NSPopover!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
    
    var active:Bool = false

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "statusIcon")
        icon?.setTemplate(true)
        statusItem.image = icon
        statusItem.action = "toggleMenu"

        let ghManager = GHManager()
        ghManager.getPullRequests { (response, error) -> Void in
            
            if let dict = response {
                let items = dict["items"]?.allObjects as [NSDictionary]
                let titles = items.map { [unowned self]
                    (var d) -> String in
                    var num:Int = -1
                    var title:String = ""
                    
                    if let n = d.valueForKey("number") as? Int {
                        num = n
                    }
                    if let t = d.valueForKey("title") as? String {
                        title = t
                    }
                    return "#\(num): \(title)"
                }
                println("titles: \(titles)")
            }
        }
    }
    
    func toggleMenu() {
        if active {
            if let button = statusItem.button? {
                println("button")
                popover.showRelativeToRect(NSZeroRect, ofView: button, preferredEdge: NSMinYEdge)
            }
        } else {
            popover.close()
        }
        active = !active
    }
}



