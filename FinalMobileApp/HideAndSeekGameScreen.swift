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
    var preTime = 30
    var gameTime = 300
    
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
    
    var hider = true
    var seeker: Bool
    {
        return !hider
    }
    
    var currentLobby: FIRDatabaseReference {
        return ref.child(lobby!.name)
    }
    
    var distances = [String: CLLocationAccuracy]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var hidersRemain: Bool {
        if hider {
            return true
        }
        
        for player in players {
            if player.role == 0 {
                return true
            }
        }
        return false
    }
    
    var remainingHiders: Int {
        var sum = 0
        for player in players {
            if player.role == 0 {
                sum += 1
            }
        }
        return sum
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard lobby != nil && players != nil else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        currentLobby.child("settings").observe(.value, with:
        {   (snap) in
            if let dict = snap.value as? [String: Int]
            {
                self.preTime = dict["preTime"]!
                self.gameTime = dict["gameTime"]!
            }
        })
        
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
        
        tim = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(preTimeStep), userInfo: nil, repeats: true)
        
        currentLobby.child("players").child(myPlayerID).observe(.childChanged, with:
        {   (snap) in
            if snap.key == "role" {
                self.ezAlert(title: "You've been found!", message: nil, buttonTitle: "OK")
            }
        })
        
        for player in players {
            self.distances[player.name] = 0
            currentLobby.child("players").child(player.uuid).observe(.childChanged, with:
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
    }
    
    deinit {
        beaconManager.stopRangingBeaconsInAllRegions()
        currentLobby.removeAllObservers()
        tim.invalidate()
    }
    
    var countdownAlert: UIAlertController!
    func preTimeStep() {
        if countdownAlert != nil {
            countdownAlert.dismiss(animated: false, completion: nil)
            countdownAlert = nil
        }
        
        if preTime > 0 {
            var dots = ""
            for _ in 0..<(3 - preTime % 4)
            {
                dots += "."
            }
            
            let msg = hider ? "You're a hider! Find a spot." : "You're a seeker! Please wait\(dots)"
            countdownAlert = UIAlertController(title: "Game begins in: \(preTime)", message: msg, preferredStyle: .alert)
            present(countdownAlert, animated: false, completion: nil)
            
            preTime -= 1
        }
        else {
            let msg = hider ? "Good luck!" : "Find those hiders!"
            ezAlert(title: "Let the game begin!", message: msg, buttonTitle: "OK")
            tim.invalidate()
            tim = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(gameTimeStep), userInfo: nil, repeats: true)
        }
    }
    
    func gameTimeStep() {
        if gameTime > 0 {
            let minutes = "\(gameTime / 60)"
            let seconds = "\(gameTime % 60)".characters.count == 1 ? "0\(gameTime % 60)" : "\(gameTime % 60)"
            
            gameTime -= 1
            
            navigationItem.title = "\(minutes):\(seconds)"
        }
        else {
            tim.invalidate()
            gameOver()
        }
    }
    
    //finds beacons, array of beacons with that uuid is beacons, this func updates every 1 second
    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beac = beacons.first {
            let feet = toFeet(fromMeters: beac.accuracy)
            distancesToAverage.append(feet)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let dist = [CLLocationAccuracy](distances.values)[indexPath.row]
        let name = [String](distances.keys)[indexPath.row]
        if seeker && dist < 10 {
            for player in players {
                if player.name == name {
                    player.role = 2
                    currentLobby.child("players").child(player.uuid).updateChildValues(["role": 2])
                    
                    if hidersRemain{
                        ezAlert(title: "You found \(player.name)", message: "\(remainingHiders) hiders remain.", buttonTitle: "OK")
                    }
                    else {
                        gameOver()
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    let CONVERSION_FACTOR = 3.28084
    
    func toFeet(fromMeters meters: Double) -> Double {
        return meters * CONVERSION_FACTOR
    }
    
    func toMeters(fromFeet feet: Double) -> Double {
        return feet / CONVERSION_FACTOR
    }
    
    func gameOver() {
        let result = hidersRemain ? "Hiders Win!" : "Seeker Wins!"
        let alert = UIAlertController(title: "Game Over!", message: result, preferredStyle: .alert)
        alert.addAction(title: "Dismiss", style: .cancel)
        {   _ in
            let _ = self.navigationController?.popViewController(animated: true)
        }
        present(alert, animated: true, completion: nil)
    }
}
