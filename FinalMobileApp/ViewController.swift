//
//  ViewController.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 3/15/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit
import CoreLocation

extension UIViewController
{
    func goToView(with identifier: String, handler: ((UIViewController) -> Void)?)
    {
        if let vc = storyboard?.instantiateViewController(withIdentifier: identifier)
        {
            if handler != nil {handler!(vc)}
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    
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
    
    var viewIsInJoinState = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tabBar.delegate = self
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            CLLocationManager().requestAlwaysAuthorization()
        }
        else {
            for _ in 0...10 {
                print("already authorized")
            }
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "wifi"), style: .plain, target: self, action: #selector(connectBeacon))
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        if item.tag == 1 //Join
        {
            viewIsInJoinState = true
        }
        else if item.tag == 2 //Make
        {
            viewIsInJoinState = false
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if viewIsInJoinState {
            //number of lobbies
            return 7
        }
        else {
            //lobby name
            //lobby password
            //confirm button
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if viewIsInJoinState
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "joinCell")!
            cell.textLabel?.text = "Lobby name"
            cell.detailTextLabel?.text = "Hosted by: host name"
            return cell
        }
        else
        {
            /**
            Lobby Name     (Text Field)
            Lobby Pass     (Text Field {secure})
            Confirm Button (Whole Cell {centered text})
                            Checks for existing lobbies with same name
            */
            
            if indexPath.row == 2
            {
                return tableView.dequeueReusableCell(withIdentifier: "confirmationCell")!
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "createCell") as! CreateLobbyFieldCell
            
            //create 2 custom cells with text fields for name and pass (pass should be secure)
            switch indexPath.row
            {
            case 0:
                cell.label.text = "Lobby Name"
                
            case 1:
                cell.label.text = "Password"
                cell.field.isSecureTextEntry = true
                
            default:
                cell.textLabel?.text = ""
            }
            
            return cell
        }
    }
    
    func connectBeacon()
    {
        let alert = UIAlertController(title: "Enter your beacon's information:", message: nil, preferredStyle: .alert)
        alert.addTextField
        {   (field) in
            field.placeholder = "Beacon UUID"
            field.text = beaconUUID
        }
        alert.addTextField
        {   (field) in
            field.placeholder = "Major Value"
            field.text = "\(beaconMajor)"
        }
        alert.addTextField
        {   (field) in
            field.placeholder = "Minor Value"
            field.text = "\(beaconMinor)"
        }
        alert.addAction(UIAlertAction(title: "Set", style: .default, handler:
        {   _ in
            if let uid = alert.textFields?[0].text{
                beaconUUID = uid
            }
            
            if let maj = Int((alert.textFields?[1].text)!){
                beaconMajor = maj
            }
            
            if let min = Int((alert.textFields?[2].text)!){
                beaconMinor = min
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
