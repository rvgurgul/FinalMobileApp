//
//  GlobalUtility.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 3/21/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Firebase

/*
 λ3
 
 Richie
 Peter
 Nick
 
 -------
 iBeacon
 -------
 - = incomplete
 ~ = complete
 
 -Beacons
    - implement nearby beacon connection
 
 -Firebase
    - gameState branch that everyone observes for the start of the game.
 
 -Functionality
    - create another tableVC to serve as the game screen. (H = hider, S = seeker)
        - H: frequently push distance to beacon up to firebase
        - S: observe updates to each player's distance and refresh table view data
    - add constraints onto the game settings
        - countdown: 10-60
        - game time: 120-1200
 
 //B9407F30-F5F8-466E-AFF9-25556B57FE6D

 */

let ESTIMOTE_PROXIMITY_UUID = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!

let lilBlue_PROXIMITY_UUID = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!


var beaconManager: BeaconManager!

var ref: FIRDatabaseReference
{
    return FIRDatabase.database().reference()
}

var saved: UserDefaults
{
    return UserDefaults.standard
}

var deviceName: String
{
    return UIDevice.current.name
}

var beaconUUID: String
{
    set (value)
    {
        saved.set(value, forKey: "beaconUUID")
    }
    get
    {
        if let uuid = saved.value(forKey: "beaconUUID") as? String{
            return uuid
        }
        return ESTIMOTE_PROXIMITY_UUID.uuidString
    }
}

var beaconMajor: Int 
{
    set (value)
    {
        saved.set(value, forKey: "beaconMajor")
    }
    get
    {
        if let major = saved.value(forKey: "beaconMajor") as? Int {
            return major
        }
        return 0
    }
}

var beaconMinor: Int
{
    set (value)
    {
        saved.set(value, forKey: "beaconMinor")
    }
    get
    {
        if let minor = saved.value(forKey: "beaconMinor") as? Int {
            return minor
        }
        return 0
    }
}

var beaconRange: CLBeaconRegion
{
    let uuid = UUID(uuidString: beaconUUID)!
    let maj = UInt16(beaconMajor)
    let min = UInt16(beaconMinor)
    return CLBeaconRegion(proximityUUID: uuid, major: maj, minor: min, identifier: "BEAC")
}

func cancelAction(withTitle title: String?) -> UIAlertAction
{
    return UIAlertAction(title: title, style: .cancel, handler: nil)
}

extension UIAlertController
{
    func addAction(title: String, style: UIAlertActionStyle, handler: @escaping (UIAlertAction) -> Void)
    {
        self.addAction(UIAlertAction(title: title, style: style, handler: handler))
    }
}

/*
func region(for player: Player) -> CLBeaconRegion
{
    return CLBeaconRegion(proximityUUID: player.uuid, major: player.majorValue, minor: player.minorValue, identifier: player.name)
}

func startMonitoring(player: Player)
{
    let beaconRegion = region(for: player)
    location.startMonitoring(for: beaconRegion)
    location.startRangingBeacons(in: beaconRegion)
}

func stopMonitoring(player: Player)
{
    let beaconRegion = region(for: player)
    location.stopMonitoring(for: beaconRegion)
    location.stopRangingBeacons(in: beaconRegion)
}
*/

func == (beacon: CLBeacon, region: CLBeaconRegion) -> Bool
{
    return beacon.proximityUUID == region.proximityUUID && beacon.major == region.major && beacon.minor == region.minor
}

//func == (uuid1: UUID, uuid2: UUID)
//{
//    return uuid1.uuidString == uuid2.uuidString
//}

func calculateAccuracy(txPower: Double, rssi: Int) -> Double
{
    if (rssi == 0)
    {
        return -1.0; // if we cannot determine accuracy, return -1.
    }
    
    let ratio = Double(rssi) / txPower
    if (ratio < 1.0) {
        return pow(ratio, 10)
    }
    else {
        let accuracy =  (0.89976)*pow(ratio, 7.7095) + 0.111
        return accuracy
    }
}

extension Array
{
    func random() -> Element
    {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
    
}

func sum(_ arr: [Double]) -> Double
{
    var temp = 0.0
    for value in arr
    {
        temp += value
    }
    return temp
}

func average(_ arr: [Double]) -> Double
{
    return arr.count == 0 ? 0 : sum(arr) / Double(arr.count)
}

