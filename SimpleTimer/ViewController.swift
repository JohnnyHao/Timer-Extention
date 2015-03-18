//
//  ViewController.swift
//  SimpleTimer
//
//  Created by Tonny on 15-3-8.
//  Copyright (c) 2015年 Tonny.hao. All rights reserved.
//

import UIKit
import TonnyTimerKit
import NotificationCenter


private let kSharedGroupIndentifier = "group.iWatchResearch"
private let kTimerLeftTimeKey = "com.tonny.research.com.SimpleTimer.lefttime"
private let kTimerQuitDateKey = "com.tonny.research.com.SimpleTimer.quitdate"

private let kTimerExtentionFinishedNotification = "TimerExtentionFinishedNotification"

let defaultTimeInterval: NSTimeInterval = 100

class ViewController: UIViewController {
                            
    @IBOutlet weak var lblTimer: UILabel!
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "applicationWillResignActive",name: UIApplicationWillResignActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter()
            .addObserver(self, selector: "extentionTimerFinished",name: kTimerExtentionFinishedNotification, object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @objc private func applicationWillResignActive() {
        if timer == nil {
            clearDefaults()
        } else {
            if timer.running {
                saveDefaults()
            } else {
                clearDefaults()
            }
        }
    }
    
    @objc private func extentionTimerFinished(){
        println("the TonnyTimer extention timer finished")
        hideTonnyTimerExtention()
    }
    
    
    private func saveDefaults() {
        let userDefault = NSUserDefaults(suiteName: kSharedGroupIndentifier)
        userDefault!.setInteger(Int(timer.leftTime), forKey: kTimerLeftTimeKey)
        userDefault!.setInteger(Int(NSDate().timeIntervalSince1970), forKey: kTimerQuitDateKey)
        
        userDefault!.synchronize()
    }
    
    private func clearDefaults() {
        let userDefault = NSUserDefaults(suiteName: "group.iWatchResearch")
        userDefault!.removeObjectForKey(kTimerLeftTimeKey)
        userDefault!.removeObjectForKey(kTimerQuitDateKey)
        userDefault!.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateLabel() {
        lblTimer.text = timer.leftTimeString
    }
    
    private func showFinishAlert(# finished: Bool) {
        let ac = UIAlertController(title: nil , message: finished ? "Finished" : "Stopped", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: {[weak ac] action in ac!.dismissViewControllerAnimated(true, completion: nil)}))
            
        presentViewController(ac, animated: true, completion: nil)
    }

    @IBAction func btnStartPressed(sender: AnyObject) {
        if timer == nil {
            timer = Timer(timeInteral: defaultTimeInterval)
        }
        
        let (started, error) = timer.start(updateTick: {
                [weak self] leftTick in self!.updateLabel()
            }, stopHandler: {
                [weak self] finished in
                self!.showFinishAlert(finished: finished)
                self!.timer = nil
            })
        
        if started {
            updateLabel()
        } else {
            if let realError = error {
                println("error: \(realError.code)")
            }
        }
    }
    
    @IBAction func btnStopPressed(sender: AnyObject) {
        if let realTimer = timer {
            let (stopped, error) = realTimer.stop()
            if !stopped {
                if let realError = error {
                    println("error: \(realError.code)")
                }
            }
        }
    }
    

    //Hide the extention in Today Page
    func showTonnyTimerExtention() {
      var widegCtl = NCWidgetController.widgetController() as NCWidgetController
       widegCtl.setHasContent(true,  forWidgetWithBundleIdentifier:"com.tonny.research.com.SimpleTimer.TonnyTimer")
    }
    
    
    // Show the extention in Today Page
    func hideTonnyTimerExtention(){
        var widegCtl = NCWidgetController.widgetController() as NCWidgetController
        widegCtl.setHasContent(false,  forWidgetWithBundleIdentifier:"com.tonny.research.com.SimpleTimer.TonnyTimer")
    }
    

}

