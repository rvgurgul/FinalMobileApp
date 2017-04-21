//
//  HideAndSeekGameScreen.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 3/22/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit

class HideAndSeekGameScreen: UIViewController, ESTBeaconManagerDelegate
{
    var time = 300
    var tim: Timer!
    
    let beaconManager = ESTBeaconManager()
    
   
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization() //not sure if this needed here

        
        let beaconRegion = CLBeaconRegion(
            proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "ranged region") // lil blue
        
        self.beaconManager.startRangingBeacons(in: beaconRegion)
        
        
        
        
        tim = Timer(timeInterval: 1, target: self, selector: #selector(timeStep), userInfo: nil, repeats: true)
    }
    
    
    func timeStep()
    {
        if time > 0{
            time -= 1
            
            let minutes = "\(time / 60)"
            var seconds = "\(time % 60)"
            if seconds.characters.count == 1 {seconds = "0\(seconds)"}
            
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
        
        let number = calcDis(thisOneBoi: thisOneBoi)  // distance
    

    }
    
    //calculate the distance
    func calcDis(thisOneBoi: CLBeacon) -> Double
    {
        var rssi: Double = Double(thisOneBoi.rssi)
        var txPower = -66.0 //internet said this is the power for when the beaonc is on -4db which is the defalt
        
        
        if (rssi == 0)
        {
            return -1.0 // if we cannot determine accuracy, return -1.
        }
        
        var ratio: Double = rssi * 1.0/txPower;
        
        if (ratio < 1.0)
        {
            return pow(ratio,10)
        }
        else
        {
            var accuracy : Double =  (0.89976) * pow(ratio,7.7095) + 0.111;
            return accuracy
        }
     
        
    }

    
    
    
    
    
    
    
    
    
    
    
    
    /*override func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0//number of players
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = "Player name"
        if true //player.hider = true
        {
            cell.detailTextLabel?.text = "Distance to Player"
        }

        return cell
    }*/
}
