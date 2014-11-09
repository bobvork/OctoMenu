//
//  GHViewController.swift
//  GHMenuBar
//
//  Created by Bob Vork on 08/11/14.
//  Copyright (c) 2014 Bob Vork. All rights reserved.
//

import Cocoa

class GHViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, GHManagerDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var issues:[GHIssue] = []
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
        
        let manager = GHManager()
        manager.delegate = self
        manager.startRefreshLoop()
    }
    
    func ghManagerDidFindIssues(issues: [GHIssue]) {
        self.issues = issues
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return issues.count
    }
    
    func tableView(tableView: NSTableView,
        viewForTableColumn tableColumn: NSTableColumn?,
        row: Int) -> NSView? {
            
            let issue = issues[row]
            
            if tableColumn?.identifier == "num" {
                
                let cellView = tableView.makeViewWithIdentifier("numCell", owner: self) as? NSTableCellView
                
                if let view = cellView {
                    view.textField?.stringValue = "\(issue.num)"
                    view.textField?.textColor = NSColor.whiteColor()
                }
                return cellView
            } else if tableColumn?.identifier == "name" {
                
                let cellView = tableView.makeViewWithIdentifier("IssueCell", owner: self) as? NSTableCellView
                if let view = cellView {
                    var mTitle = NSMutableAttributedString(string: issue.title)
                    var mSubtitle = NSAttributedString(string: " — \(issue.repos)", attributes: [NSForegroundColorAttributeName : NSColor.redColor(),
                        NSStrokeColorAttributeName: NSColor.greenColor(),
                        NSFontSizeAttribute: 8,
                        NSFontAttributeName: NSFont.systemFontOfSize(8)])
                    
                    mTitle.appendAttributedString(mSubtitle)
                    view.textField?.attributedStringValue = mTitle
                    var imgName:String = "icon-issue"
                    if issue.isPR {
                        imgName = "icon-pr"
                    }
                    view.imageView?.image = NSImage(named: imgName)
                }
                
                return cellView
            }
            return nil
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        
        if self.tableView.selectedRow >= 0 {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: issues[self.tableView.selectedRow].htmlUrl)!)
            self.tableView.deselectAll(self)
            let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
            
            appDelegate.hideMenu()
        }
    }
}
