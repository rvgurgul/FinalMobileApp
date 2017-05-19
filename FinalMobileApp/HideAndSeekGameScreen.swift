//
//  HideAndSeekGameScreen.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 3/22/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HideAndSeekGameScreen: UITableViewController, ESTBeaconManagerDelegate
{
    var gameTime = 300
    var preTime = 30
    var tim: Timer!
    
    /*var timp: Timer!
    var jim: Timer!
    
    var timesCalc = [Double]()
    var timesAcc = [Double]()
    
    var firsttime = true
    */
    
    var distancesToAverage = [Double]()
    {
        didSet
        {
            if distancesToAverage.count == 10
            {
                let avg = toFeet(fromMeters: average(distancesToAverage))
                distancesToAverage.removeAll()
                currentLobby.child("players").child(myPlayerID).updateChildValues(["dist": avg])
            }
        }
    }
    var beaconManager = ESTBeaconManager()
    var beaconRegion: CLBeaconRegion!
    
    var players: [Player]!
    var lobby: Lobby?
    
    var currentLobby: FIRDatabaseReference
    {
        return ref.child(lobby!.name)
    }
    
    var distances = [String: CLLocationAccuracy]()
    {
        didSet
        {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard lobby != nil && players != nil else
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        currentLobby.child("settings").observe(.value, with:
        {   (snap) in
            if let dict = snap.value as? [String: Int]
            {
                self.preTime = dict["Countdown"]!
                print(self.preTime)
                
                self.gameTime = dict["Round Timer"]!
                print(self.gameTime)
            }
        })
        
        let playersBranch = currentLobby.child("players")
        for player in players
        {
            self.distances[player.name] = 0
            playersBranch.child(player.uuid).observe(.childChanged, with:
            {   (snap) in
                if snap.key == "dist" {
                    if let value = snap.value as? Double {
                        self.distances[player.name] = value
                    }
                }
                else if snap.key == "role" {
                    if let value = snap.value as? Int {
                        player.role = value
                    }
                }
            })
        }
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            CLLocationManager().requestAlwaysAuthorization()
        }
        else {
            for _ in 0...10 {
                print("already authorized")
            }
        }
        
        beaconRegion = CLBeaconRegion(proximityUUID: lilBlue_PROXIMITY_UUID , identifier: "ranged region")
        
        beaconManager.delegate = self
        beaconManager.startRangingBeacons(in: beaconRegion)
        
        tim = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeStep), userInfo: nil, repeats: true)
        
        /*timp = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(averageTimesCalc), userInfo: nil, repeats: true)
        
        jim = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(averageTimesAcc), userInfo: nil, repeats: true)*/
    }
    
    deinit
    {
        currentLobby.removeAllObservers()
        tim.invalidate()
        //timp.invalidate()
        //jim.invalidate()
        beaconManager.stopRangingBeaconsInAllRegions()
        print("deinitializing")
    }
    
    func timeStep()
    {
        if gameTime > 0{
            gameTime -= 1
            
            let minutes = "\(gameTime / 60)"
            let seconds = "\(gameTime % 60)".characters.count == 1 ? "0\(gameTime % 60)" : "\(gameTime % 60)"
            
            navigationItem.title = "\(minutes):\(seconds)"
        }
        else{
            print("job's done")
            tim.invalidate()
        }
    }
    
    //finds beacons, array of beacons with that uuid is beacons, this func updates every 1 second
    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        if let beac = beacons.first
        {
            let feet = toFeet(fromMeters: beac.accuracy)
            distancesToAverage.append(feet)
        }
        //let thisOneBoi = beacons.first!
        //let number = beacons.first?.accuracy
        //let number = calcDis(thisOneBoi: thisOneBoi)
        
        //let calcdis = calcDis(thisOneBoi: thisOneBoi)
        
//        if (firsttime)
//        {
//            firsttime = false
//            averageTimesAcc()
//        }
        
//        print("add to array")
//        timesCalc.append(calcdis)
//        timesAcc.append(givendis!)
    }
    
    //calculate the distance
    func calcDis(thisOneBoi: CLBeacon) -> Double
    {
        let rssi = Double(thisOneBoi.rssi)
        let txPower = -66.0 //internet said this is the power for when the beaonc is on -4db which is the default
        
        if rssi == 0
        {
            return -1.0 // if we cannot determine accuracy, return -1.
        }
        
        let ratio = rssi / txPower;
        
        if (ratio < 1.0)
        {
            return pow(ratio, 10)
        }
        else
        {
            let accuracy = (0.89976) * pow(ratio,7.7095) + 0.111;
            return accuracy
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return players.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerInfo", for: indexPath)
        let player = players[indexPath.row]
        
        cell.textLabel?.text = player.name
        if player.role == 0 {
            let dist = distances[player.name]!
            if dist <= 0 {
                cell.detailTextLabel?.text = "--ft"
            }
            else {
                cell.detailTextLabel?.text = "\(String(format: "%.1f", dist))ft"
            }
        }
        else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    /*func averageTimesCalc() -> Double
    {
        let avg = average(timesCalc)
        timesCalc.removeAll()
        
        let feet = toFeet(meters: avg)
        //currentLobby.child("players").child(branchID).updateChildValues(["dist": feet])
        
        return feet
    }
    
    func averageTimesAcc() -> Double
    {
        let avg = average(timesAcc)
        timesAcc.removeAll()
        
        let feet = toFeet(meters: avg)
        //currentLobby.child("players").child(myPlayerID).updateChildValues(["dist": feet])
        
        return feet
    }*/
    
    func toFeet(fromMeters meters: Double) -> Double
    {
        return meters * 3.28084
    }
}
