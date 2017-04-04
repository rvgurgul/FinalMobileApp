//
//  BeaconDelegate.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 3/22/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import UserNotifications

class BeaconManager: NSObject, CLLocationManagerDelegate
{
    var manager = CLLocationManager()
    
    init(withBeaconUUID uuid: UUID)
    {
        super.init()
        
        self.manager.delegate = self
        
        self.manager.startMonitoring(for: beaconRange)
        self.manager.startRangingBeacons(in: beaconRange)
    }
    
    private func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [CLBeacon]!, inRegion region: CLBeaconRegion!)
    {
//        let goodBeacons = beacons.filter
//        {   (beacon) -> Bool in
//            return beacon.proximity != .unknown
//        }
        
        for beacon in beacons
        {
            //distanceFromBeacon[beacon.proximityUUID] = beacon.accuracy
            
            if beacon == beaconRange {
                for _ in 0...15 {
                    print("we found the beacon!")
                }
            }
            
            print(beacon.accuracy)
            print(calculateAccuracy(txPower: 1, rssi: beacon.rssi))
            
            print(beacon.proximityUUID.uuidString)
            print(beacon.major)
            print(beacon.minor)
            print(beacon.proximity)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion)
    {
        if region is CLBeaconRegion
        {
            let notification = UILocalNotification()
            notification.alertBody = "Turn back! You've left the game region."
            notification.soundName = "Default"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error)
    {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
}
