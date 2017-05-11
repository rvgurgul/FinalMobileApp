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
    
    var lobby: Lobby?
    var currentLobby: FIRDatabaseReference
    {
        if let branch = lobby!.name
        {
            return ref.child(branch)
        }
        return ref
    }
    
    var branchID: String!
    var players: [Player]!
    
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
        
        guard lobby != nil && branchID != nil && players != nil else
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        for player in players
        {
            let playerBranch = currentLobby.child("players").child(player.uuid)
            playerBranch.observe(.childChanged, with:
            {   (snap) in
                print("we in there")
                if snap.key == "dist"
                {
                    print("\(player.name)'s distance changed to:")
                    if let value = snap.value as? Double
                    {
                        print(value)
                        self.distances[snap.key] = value
                    }
                }
            })
        }
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization() //not sure if this needed here

        let beaconRegion = CLBeaconRegion(
            proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "ranged region") // lil blue
        
        self.beaconManager.startRangingBeacons(in: beaconRegion)
        
        tim = Timer(timeInterval: 1, target: self, selector: #selector(timeStep), userInfo: nil, repeats: true)
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
        
        //PUSHES DISTANCE TO FIREBASE
        //(I'm assuming this would update the value every time it ranges a beacon, so maybe move this around so that it's not constantly updating so you can average it to get a better number.)
        currentLobby.child("players").child(branchID).updateChildValues(["dist": number])
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
        return 10//players.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerInfo", for: indexPath)
        return cell
        
        let player = players[indexPath.row]
        
        cell.textLabel?.text = player.name
        if player.role == 0
        {
            cell.detailTextLabel?.text = "\(distances[player.name])m" //player's distance
        }

        return cell
    }
}
