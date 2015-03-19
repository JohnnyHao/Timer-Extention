//
//  ActionViewController.swift
//  TonnyAction-Web
//
//  Created by Tonny.hao on 3/19/15.
//  Copyright (c) 2015 OneV's Den. All rights reserved.
//

import UIKit
import MobileCoreServices


class TagStatus {
    let name: String
    let tag: String
    var status: Bool
    
    func toggleStatus() {
        status = !status
    }
    
    init(tag: String, name: String) {
        self.name = name
        self.tag = tag
        self.status = false
    }
}


extension TagStatus: Printable {
    var description: String {
        return "\(name) (\(tag))"
    }
}

class ActionViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var tagList = [TagStatus]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate the tag map
        tagList = createTagList()
        
        for item: AnyObject in self.extensionContext!.inputItems {
            let inputItem = item as NSExtensionItem
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as NSItemProvider
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as NSString) {
                    // You _HAVE_ to call loadItemForTypeIdentifier in order to get the JS injected
                    itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as NSString, options: nil, completionHandler: {
                        (list, error) in
                        if let results = list as? NSDictionary {
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                // We don't actually care about this...
                                println(results)
                            }
                        }
                    })
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Find out which tags need marqueefying
        let marqueeTagNames = tagList.filter{ $0.status }.map{ $0.tag }
        
        // Parcel them up in an NSExtensionItem
        let extensionItem = NSExtensionItem()
        let jsDict = [ NSExtensionJavaScriptFinalizeArgumentKey : [ "marqueeTagNames" : marqueeTagNames ]]
        extensionItem.attachments = [ NSItemProvider(item: jsDict, typeIdentifier: kUTTypePropertyList as NSString)]
        
        // Send them back to the javascript processor
        self.extensionContext!.completeRequestReturningItems([extensionItem], completionHandler: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        let error = NSError(domain: "errorDomain", code: 0, userInfo: nil)
        self.extensionContext!.cancelRequestWithError(error)
    }
    
    
    
    
    // MARK:- UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tagTypeCell", forIndexPath: indexPath) as UITableViewCell
        let tag = tagList[indexPath.row]
        cell.textLabel?.text = "\(tag)"
        cell.accessoryType = tag.status ? .Checkmark : .None
        return cell
    }
    
    // MARK:- UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var tag = tagList[indexPath.row]
        tag.toggleStatus()
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = tag.status ? .Checkmark : .None
            cell.selected = false
        }
    }

    
    // MARK:- Utility Methods
    private func createTagList() -> [TagStatus] {
        return [("Heading 1", "h1"),
            ("Heading 2", "h2"),
            ("Heading 3", "h3"),
            ("Heading 4", "h4"),
            ("Paragraph", "p")].map { (name: String, tag: String) in TagStatus(tag: tag,name: name) }
    }

}
