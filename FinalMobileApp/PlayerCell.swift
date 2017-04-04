//
//  PlayerCell.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 3/20/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit
import CoreLocation

class PlayerCell: UITableViewCell
{
    var player: Player?
    {
        didSet
        {
            //player?.addO
        }
        willSet
        {
            
        }
    }
    
    /*
     Open ItemCell.swift and add the following to the beginning of the didSet property observer for item :
     item?.addObserver(self, forKeyPath: "lastSeenBeacon", options: .New, context: nil)
     
     Add a willSet property observer next to didSet . Make sure it's still inside the item property:
     willSet {
     if let thisItem = item {
     thisItem.removeObserver(self, forKeyPath: "lastSeenBeacon")
     }
     }
     
     You should also remove the observer when the cell is deallocated. Still in ItemCell.swift , add the following deinitializer to the ItemCell class:
     deinit {
     item?.removeObserver(self, forKeyPath: "lastSeenBeacon")
     }
     
     
     */
    
    func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutableRawPointer)
    {
        if keyPath == "lastSeenBeacon", let aPlayer = object as? Player//, aPlayer == player
        {
            let accuracy = String(format: "%.2f", aPlayer.lastSeenBeacon!.accuracy)
            detailTextLabel!.text = "Location: approx. \(accuracy)m"
        }
    }
}
