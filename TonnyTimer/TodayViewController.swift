//
//  TodayViewController.swift
//  TonnyTimer
//
//  Created by Tonny.hao on 3/17/15.
//  Copyright (c) 2015 OneV's Den. All rights reserved.
//

import UIKit
import NotificationCenter
import TonnyTimerKit

private let kSharedGroupIndentifier = "group.iWatchResearch"
private let kTimerLeftTimeKey = "com.tonny.research.com.SimpleTimer.lefttime"
private let kTimerQuitDateKey = "com.tonny.research.com.SimpleTimer.quitdate"

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var lblTImer: UILabel!
    
    var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = NSUserDefaults(suiteName: kSharedGroupIndentifier)
        let leftTimeWhenQuit = userDefaults!.integerForKey(kTimerLeftTimeKey)
        let quitDate = userDefaults!.integerForKey(kTimerQuitDateKey)
        
        let passedTimeFromQuit = NSDate().timeIntervalSinceDate(NSDate(timeIntervalSince1970: NSTimeInterval(quitDate)))
        let leftTime = leftTimeWhenQuit - Int(passedTimeFromQuit)
        lblTImer.text = "\(leftTime)"
        
        if (leftTime > 0) {
            timer = Timer(timeInteral: NSTimeInterval(leftTime))
            timer.start(updateTick: {
                [weak self] leftTick in self!.updateLabel()
                }, stopHandler: {
                    [weak self] finished in
                    self!.showOpenAppButton()
            })
        } else {
            // showOpenAppButton()
        }
        
        
        // Do any additional setup after loading the view from its nib.
    }
    
    private func updateLabel() {
        lblTImer.text = timer.leftTimeString
    }
    
    private func showOpenAppButton() {
        lblTImer.text = "Finished"
        preferredContentSize = CGSizeMake(0, 100)
        
        let button = UIButton(frame: CGRectMake(0, 50, 50, 63))
        button.setTitle("Open", forState: UIControlState.Normal)
        button.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(button)
    }
    
    @objc private func buttonPressed(sender: AnyObject!) {
        extensionContext!.openURL(NSURL(string: "simpleTimer://finished")!, completionHandler: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
}
