//
//  ActionViewController.swift
//  TonnyAction
//
//  Created by Tonny.hao on 3/18/15.
//  Copyright (c) 2015 OneV's Den. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class ActionViewController: UIViewController {

    
    @IBOutlet weak var textView:UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var item = (self.extensionContext?.inputItems[0]) as NSExtensionItem
        var attachments = item.attachments as [NSItemProvider]
        var itemProvider =  attachments[0] as NSItemProvider
        
        if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePlainText) {
            weak var textView = self.textView
            itemProvider.loadItemForTypeIdentifier(kUTTypePlainText, options: nil, completionHandler: { (item:NSSecureCoding!, error:NSError!) -> Void in
                if item != nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        textView!.text = item as NSString
                        println("the text is \(item)")
                        
                        var synthesizer = AVSpeechSynthesizer()
                        var utterance = AVSpeechUtterance(string: textView?.text)
                        utterance.rate = 0.1
                        synthesizer.speakUtterance(utterance)
                    })
                }
            })
        }
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }

}
