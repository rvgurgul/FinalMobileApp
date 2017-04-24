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
 
 -Main Menu
 -Hide & Seek
 -lobby
 -invite people/show nearby phones
 -options
 -initial timer (~30s)
 -round timer (~5m)
 -hiders become seekers
 -who is next seeker (1st? 2nd to last? winner?)
 -ready up button
 -randomly pick a seeker/allow someone to choose
 -initial timer
 -begin round timer
 -seeker has large range beacon
 -seeker can see each player & distance to them
 -hiders can see each player & distance to them except the seeker.
 -after time is up, if all remaining hiders are together, they win
 -first/2nd to last player found becomes next seeker
 -Sharks & Minnows
 -3 beacons to triangulate position
 -CTF?
 -TTT?
 
 */

let ESTIMOTE_PROXIMITY_UUID = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!

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

var players: [UUID:String] = [:]
var distanceFromBeacon: [UUID:Double] = [:]

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


