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
    @IBOutlet weak var settingsController: SettingsController!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(40);
    
    var active:Bool = false
    var popoverMonitor:AnyObject?

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let icon = NSImage(named: "icon-pr")
        icon?.setTemplate(true)
        statusItem.image = icon
        statusItem.title = ""

        statusItem.action = "toggleMenu"
    }
    
    @IBAction func settingsButtonClicked(sender: NSButton) {
        settingsController.show()
//        showMenu()
    }
    
    func updateNumberOfIssues(number:Int) {
        let attString = NSAttributedString(string: "\(number)",
            attributes: [NSFontSizeAttribute: 8])
//        self.statusItem.title = "\(number)"
        statusItem.attributedTitle = attString
    }
    
    func toggleMenu() {
        
        if !popover.shown {
            showMenu()
        } else {
            hideMenu()
        }
        
        self.popoverMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.LeftMouseDownMask | NSEventMask.RightMouseDownMask,
            handler: { [unowned self] (event: NSEvent!) -> Void in
                
                if let appEvent = NSApplication.sharedApplication().currentEvent {
                    if appEvent == event {
                        return
                    }
                }
                self.hideMenu()
        })
    }
    func showMenu() {
        if let button = statusItem.button? {
            popover.showRelativeToRect(NSZeroRect, ofView: button, preferredEdge: NSMinYEdge)
        }
    }
    func hideMenu() {
        if (self.popoverMonitor != nil) {
            NSEvent.removeMonitor(self.popoverMonitor!)
        }
        self.popoverMonitor = nil
        self.popover.close()
    }
}



