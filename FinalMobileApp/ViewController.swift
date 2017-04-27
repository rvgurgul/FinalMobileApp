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
    func goToView(withID identifier: String, handler: ((UIViewController) -> Void)?)
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
    
    var viewIsInJoinState = true
    
    var refreshControl: UIRefreshControl!
    
    var lobbies = [Lobby]()//[String:String]()
    
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
        
        grabLobbies()
        
        tabBar.selectedItem = tabBar.items![0]
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "wifi"), style: .plain, target: self, action: #selector(connectBeacon))
   
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(grabLobbies), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func grabLobbies()
    {
        lobbies.removeAll()
        ref.observeSingleEvent(of: .value, with:
        {   (snap) in
            if let dict = snap.value as? [String:Any] {
                for lobbyName in dict.keys {
                    if let lobbyDict = dict[lobbyName] as? [String:Any] {
                        self.lobbies.append(Lobby(name: lobbyName, dict: lobbyDict))
                    }
                }
            }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        })
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        if item.tag == 1 //Join
        {
            viewIsInJoinState = true
            grabLobbies()
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
            return lobbies.count
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
            let lobby = lobbies[indexPath.row]
            
            cell.textLabel?.text = lobby.name//[String](lobbies.keys)[indexPath.row]
            cell.detailTextLabel?.text = lobby.host//[String](lobbies.values)[indexPath.row]
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
                cell.label.text = "Password?"
                cell.field.isSecureTextEntry = true
                
            default:
                cell.textLabel?.text = ""
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if viewIsInJoinState
        {
            let lobby = lobbies[indexPath.row]
            if lobby.pass != nil
            {
                let alert = UIAlertController(title: "Password protected lobby", message: nil, preferredStyle: .alert)
                alert.addTextField(configurationHandler:
                {   (field) in
                    field.placeholder = "(case sensitive)"
                    field.isSecureTextEntry = true
                })
                alert.addAction(UIAlertAction(title: "Enter", style: .default, handler:
                {   _ in
                    if let input = alert.textFields?[0].text
                    {
                        if lobby.valid(password: input)
                        {
                            self.goToView(withID: "newLobby", handler:
                            {   (vc) in
                                if let nextVC = vc as? LobbyViewController
                                {
                                    nextVC.lobby = self.lobbies[indexPath.row]
                                }
                            })
                        }
                        else
                        {
                            let phrase = ["China", "Wrong", "Liberal Conspiracies", "Vladimir Putin", "Fox News", "Make America Great Again",  "Mike Pence", "Fake News", "Chyyyna", "This is the worst trade deal in the history of trade deals, maybe ever.", "Failing New York Times", "We're going to build a wall.", "Steven Bannon", "Sean Spicer", "Russia", "North Korea", "Anime is now illegal.", "Alternative Facts", "CNN is FAKE NEWS"].random()
                            
                            let wrongAlert = UIAlertController(title: "WRONG", message: phrase, preferredStyle: .alert)
                            wrongAlert.addAction(cancelAction(withTitle: "OK"))
                            self.present(wrongAlert, animated: true, completion: nil)
                        }
                    }
                }))
                present(alert, animated: true, completion: nil)
            }
            else
            {
                goToView(withID: "newLobby", handler:
                {   (vc) in
                    if let nextVC = vc as? LobbyViewController
                    {
                        nextVC.lobby = self.lobbies[indexPath.row]
                    }
                })
            }
        }
        else if indexPath.row == 2 //assumed to not be in join state
        {
            let nameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! CreateLobbyFieldCell
            let passCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! CreateLobbyFieldCell
            
            let name = nameCell.field.text!
            let pass = passCell.field.text!
            
            //firebase checking for existing lobby.
            ref.observeSingleEvent(of: .value, with:
            {   (snap) in
                if let dict = snap.value as? [String:Any]
                {
                    let lobbyNames = [String](dict.keys)
                    if lobbyNames.contains(name)
                    {
                        let alert = UIAlertController(title: "Lobby Name Taken", message: "A lobby already exists with the name \"\(name)\"", preferredStyle: .alert)
                        alert.addAction(cancelAction(withTitle: "Dismiss"))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else
                    {
                        ref.child(name).updateChildValues(["password": pass])
                        
                        self.goToView(withID: "newLobby", handler:
                        {   (vc) in
                            if let lobby = vc as? LobbyViewController
                            {
                                lobby.lobby = Lobby(name: name, dict: ["password": pass, "host": deviceName])
                                lobby.hosting = true
                            }
                        })
                    }
                }
            })
        }
    }
    
    func connectBeacon()
    {
        let alert = UIAlertController(title: "Searching for beacons...", message: "", preferredStyle: .alert)
        alert.addAction(cancelAction(withTitle: "Cancel"))
        present(alert, animated: true, completion: nil)
        
        //get beacons from the beacon ranging function
        //present action sheet to choose from available beacons
        
        /*let alert = UIAlertController(title: "Enter your beacon's information:", message: nil, preferredStyle: .alert)
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
        alert.addAction(cancelAction(withTitle: "Cancel"))
        present(alert, animated: true, completion: nil)*/
    }
    
}
