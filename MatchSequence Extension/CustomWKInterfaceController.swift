//
//  CustomWKInterfaceController.swift
//  Watch_MatchSequenceGame
//
//  Created by Shubhank on 31/03/16.
//  Copyright © 2016 com. All rights reserved.
//

import Foundation
import WatchKit

public func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

extension WKInterfaceController {
    func animateWithDuration(duration: NSTimeInterval, animations: () -> Void, completion: (() -> Void)?) {
        animateWithDuration(duration, animations: animations)
        let completionDelay = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * Double(NSEC_PER_SEC)))
        dispatch_after(completionDelay, dispatch_get_main_queue()) {
            completion?()
        }
    }
    
}