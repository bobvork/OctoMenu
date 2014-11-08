//
//  GHViewController.swift
//  GHMenuBar
//
//  Created by Bob Vork on 08/11/14.
//  Copyright (c) 2014 Bob Vork. All rights reserved.
//

import Cocoa

class GHViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var issues:[GHIssue] = []
    
    required init?(coder:NSCoder) {
        super.init(coder: coder)
        loadData()
    }
    
    func loadData() {
        GHManager().getPullRequests { [unowned self]
            (response, error) -> Void in
            
            if let dict = response {
                let items = dict["items"]?.allObjects as [NSDictionary]
                let titles = (dict["items"]?.allObjects as [NSDictionary]).map {
                    (var d) -> GHIssue in
                    return GHIssue(dict: d)
                }
                self.issues = titles
                self.tableView.reloadData()
            }
        }
    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return issues.count
    }
    
    func tableView(tableView: NSTableView,
        viewForTableColumn tableColumn: NSTableColumn?,
        row: Int) -> NSView? {
            
            if tableColumn?.identifier == "num" {
                
                let cellView = tableView.makeViewWithIdentifier("numCell", owner: self) as? NSTableCellView
                
                if let view = cellView {
                    view.textField?.stringValue = "\(issues[row].num)"
                    view.textField?.textColor = NSColor.whiteColor()
                }
                return cellView
            } else if tableColumn?.identifier == "name" {
                
                let cellView = tableView.makeViewWithIdentifier("IssueCell", owner: self) as? NSTableCellView
                if let view = cellView {
                    view.textField?.stringValue = issues[row].title
                }
                
                return cellView
            }
            return nil
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        
        if self.tableView.selectedRow >= 0 {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: issues[self.tableView.selectedRow].htmlUrl)!)
            self.tableView.deselectAll(self)
            
        }
    }
}
