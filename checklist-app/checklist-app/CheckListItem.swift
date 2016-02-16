//
//  CheckListItem.swift
//  checklist-app
//
//  Created by Abel Osorio on 2/16/16.
//  Copyright © 2016 Abel Osorio. All rights reserved.
//

import Foundation
import UIKit

class CheckListItem : NSObject, NSCoding{
    
    var text = ""
    var checked = false
    var dueDate = NSDate()
    var shouldRemind = false
    var itemID: Int
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(text, forKey: "Text")
        aCoder.encodeBool(checked, forKey: "Checked")
        aCoder.encodeObject(dueDate, forKey: "DueDate")
        aCoder.encodeBool(shouldRemind, forKey: "ShouldRemind")
        aCoder.encodeInteger(itemID, forKey: "ItemID")
    }
    
    required init?(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObjectForKey("Text") as! String
        checked = aDecoder.decodeBoolForKey("Checked")
        dueDate = aDecoder.decodeObjectForKey("DueDate") as! NSDate
        shouldRemind = aDecoder.decodeBoolForKey("ShouldRemind")
        itemID = aDecoder.decodeIntegerForKey("ItemID")
        super.init()
    }
    
    override init() {
        itemID = DataModel.nextChecklistItemID()
        super.init()
    }
    
    deinit {
        
        if let notification = notificationForThisItem() {
            print("Removing existing notification \(notification)")
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
    }
    
    
    
    
    func toggleChecked() {
        checked = !checked
    }
    
    func scheduleNotification (){
        
        if shouldRemind && dueDate.compare(NSDate()) != .OrderedAscending {
        
        let existingNotification = notificationForThisItem()
        
        if let notification = existingNotification {
            print("Found an existing notification \(notification)")
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = dueDate
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.alertBody = text
        localNotification.soundName = UILocalNotificationDefaultSoundName
        localNotification.userInfo = ["ItemID": itemID]
        UIApplication.sharedApplication().scheduleLocalNotification( localNotification)
        print("Scheduled notification \(localNotification) for itemID \(itemID)")
        
        }
        
    }
    
    func notificationForThisItem() -> UILocalNotification? {
            let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!
            for notification in allNotifications {
            if let number = notification.userInfo?["ItemID"] as? Int
            where number == itemID {
            return notification
            }
            
            }
            return nil
    }
    
}