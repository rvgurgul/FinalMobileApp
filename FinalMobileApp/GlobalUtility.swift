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

var myPlayerID = UUID().uuidString

func joinLobby(_ name: String)
{
    if var dict = saved.object(forKey: "joinedLobbies") as? [String:[String]]
    {
        dict[myPlayerID]!.append(name)
        saved.set(dict, forKey: "joinedLobbies")
    }
    else
    {
        saved.set([myPlayerID: [name]], forKey: "joinedLobbies")
    }
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

