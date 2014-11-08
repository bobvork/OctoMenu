//
//  AppDelegate.swift
//  GHMenuBar
//
//  Created by Bob Vork on 06/11/14.
//  Copyright (c) 2014 Bob Vork. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var popover: NSPopover!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1);
    
    var active:Bool = false
    var popoverMonitor:AnyObject?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "statusIcon")
        icon?.setTemplate(true)
        statusItem.image = icon
        statusItem.action = "toggleMenu"
    }
    
    func toggleMenu() {
        
        if let button = statusItem.button? {
            popover.showRelativeToRect(NSZeroRect, ofView: button, preferredEdge: NSMinYEdge)
        }
        
        self.popoverMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.LeftMouseDownMask | NSEventMask.RightMouseDownMask,
            handler: { (event: NSEvent!) -> Void in
                if (self.popoverMonitor != nil) {
                    NSEvent.removeMonitor(self.popoverMonitor!)
                }
                self.popoverMonitor = nil
                self.popover.close()
        })
    }
}



