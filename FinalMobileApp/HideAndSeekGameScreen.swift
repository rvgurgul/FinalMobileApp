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
    var time = 300
    var tim: Timer!
    
    let beaconManager = ESTBeaconManager()
    
    var branchID: String!
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
    
    var timesCalc = [Double]()
    var timesAcc = [Double]()
    
    var timp: Timer!
    var jim: Timer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard lobby != nil && branchID != nil && players != nil else
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let playersBranch = currentLobby.child("players")
        for player in players {
            self.distances[player.name] = 0
            playersBranch.child(player.uuid).observe(.childChanged, with:
            {   (snap) in
                if snap.key == "dist" {
                    print("\(player.name)'s distance changed to:")
                    if let value = snap.value as? Double {
                        print(value)
                        self.distances[snap.key] = value
                    }
                }
            })
        }
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization() //not sure if this needed here

        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "ranged region") // lil blue
        
        self.beaconManager.startRangingBeacons(in: beaconRegion)
        
        tim = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeStep), userInfo: nil, repeats: true)
        
        timp = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(AveragetimesCalc), userInfo: nil, repeats: true)
        jim = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(AveragetimesAcc), userInfo: nil, repeats: true)
        
        
    }
    
    //This ain't working. Mr. Peh the timer man, fix it por favor.
    func timeStep()
    {
        if time > 0{
            time -= 1
            
            let minutes = "\(time / 60)"
            let seconds = "\(time % 60)".characters.count == 1 ? "0\(time % 60)" : "\(time % 60)"
            
            navigationItem.title = "\(minutes):\(seconds)"
        }
        else{
            tim.invalidate()
        }
    }
    
    //finds beacons, array of beacons with that uuid is beacons, this func updates every 1 second
    func beaconManager(_ manager: Any, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        let thisOneBoi = beacons.first!
        let number = beacons.first?.accuracy
        // let number = calcDis(thisOneBoi: thisOneBoi)  // distance
        
        var calcdis = calcDis(thisOneBoi: thisOneBoi)
        var givendis = beacons.first?.accuracy
        
        print("add to array")
        timesCalc.append(calcdis)
        timesAcc.append(givendis!)
        
        
        
        
        
        //PUSHES DISTANCE TO FIREBASE
        //(I'm assuming this would update the value every time it ranges a beacon, so maybe move this around so that it's not constantly updating so you can average it to get a better number.)
      //  currentLobby.child("players").child(branchID).updateChildValues(["dist": number])
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
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
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
        cell.detailTextLabel?.text = "Unknown"
        if true//player.role == 0
        {
            cell.detailTextLabel?.text = "\(distances[player.name])ft"
        }

        return cell
    }
    
    func AveragetimesCalc() -> Double
    {
        var sum = 0.00
        
        for i in timesCalc
        {
            sum += i
        }
        var average = sum / Double(timesCalc.count)
        if timesCalc.count == 0
        {
            average = 0
        }
        
        timesCalc.removeAll()
        let feet = toFeet(meters: average)
       // currentLobby.child("players").child(branchID).updateChildValues(["dist": feet])
        return average
        
    }
    
    func AveragetimesAcc() -> Double
    {
        var sum = 0.00
        print("boi")
        
        for i in timesAcc
        {
            sum += i
        }
        var average = sum / Double(timesAcc.count)
        if timesAcc.count == 0
        {
            average = 0
        }
        
        timesAcc.removeAll()
        
        let feet = toFeet(meters: average)
        currentLobby.child("players").child(branchID).updateChildValues(["dist": feet])
        
        return average
    }
    
    func toFeet(meters: Double) -> Double
    {
        return meters * 3.28084
    }
    
    
    
    
    
    
}
