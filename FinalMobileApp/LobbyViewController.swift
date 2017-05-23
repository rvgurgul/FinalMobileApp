//
//  LobbyViewController.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 4/3/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit
import Firebase

class LobbyViewController: UITableViewController
{
    var players = [Player]()
    
    var hosting = false
    var ready = false
    {
        didSet
        {
            currentLobby.child("players").child(myPlayerID).updateChildValues(["ready": ready])
        }
    }
    
    var lobby: Lobby?
    var currentLobby: FIRDatabaseReference
    {
        return ref.child(lobby!.name)
    }
    
    var settings = ["preTime": 30, "gameTime": 300]
    
    override func didReceiveMemoryWarning()
    {
        currentLobby.child("players").child(UUID().uuidString).updateChildValues(["name": "DUMMY PLAYER", "role": 0, "dist": 0])
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard lobby != nil else
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        //Saves the lobby name to remove it later if you crash/exit the app
        joinLobby(lobby!.name)
        
        //Set the top bar to say the lobby's name.
        navigationItem.title = lobby!.name
        
        //Initialize Player's Branch with name, role, and ready state.
        currentLobby.child("players").child(myPlayerID).updateChildValues(["name": deviceName, "role": 0, "ready": false, "dist": 0])
        
        //Specifics based on whether the player is host or not.
        if hosting
        {
            currentLobby.updateChildValues(["gameState": 0])
            currentLobby.child("settings").updateChildValues(settings)
            currentLobby.updateChildValues(["host": deviceName])
            //currentLobby.child("beacon").updateChildValues(["uuid": beaconUUID, "major": beaconMajor, "minor": beaconMinor])
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(settingsButton))
        }
        
        //Listening for player joining
        currentLobby.child("players").observe(.childAdded, with:
        {   (snap) in
            if let value = snap.value as? [String:Any] {
                let uuid = snap.key
                if myPlayerID != uuid {
                    let name = value["name"] as! String
                    let role = value["role"] as! Int
                    let player = Player(uuid, name, role)
                    self.players.append(player)
                    self.tableView.reloadData()
                }
            }
        })
        {   (err) in
            print(err)
        }
        
        //Listening for player leaving
        currentLobby.child("players").observe(.childRemoved, with:
        {   (snap) in
            if myPlayerID == snap.key //player has been kicked, deal with them
            {
                let kickedAlert = UIAlertController(title: "You've been kicked!", message: nil, preferredStyle: .alert)
                kickedAlert.addAction(title: "Dismiss", style: .cancel, handler:
                {   _ in
                    //dismisses lobby view controller (returns to main screen)
                    let _ = self.navigationController?.popViewController(animated: true)
                })
                self.present(kickedAlert, animated: true, completion: nil)
            }
            else
            {
                for i in 0..<self.players.count {
                    if i >= self.players.count {for _ in 0...15 {print("oh no, very bad")}}
                    else if self.players[i].uuid == snap.key
                    {
                        self.players.remove(at: i)
                        self.tableView.reloadData()
                    }
                }
            }
        })
        {   (err) in
            print(err)
        }
        
        //Listening for game-beginning
        currentLobby.observe(.childChanged, with:
        {   (snap) in
            if snap.key == "gameState" {
                self.goToView(withID: "newGameVC", handler:
                {   (vc) in
                    if let nextVC = vc as? HideAndSeekGameScreen {
                        nextVC.lobby = self.lobby
                        nextVC.players = self.players
                        nextVC.hider = !self.hosting
                    }
                })
            }
        })
    }
    
    func settingsButton()
    {
        let alert = UIAlertController(title: "Settings Menu", message: nil, preferredStyle: .actionSheet)
        
        /*let rdyTxt = ready ? "Unready" : "Ready Up"
        alert.addAction(title: rdyTxt, style: .destructive, handler:
        {   _ in
            self.ready = !self.ready
            //do the readying up stuff here
        })*/
        
        alert.addAction(UIAlertAction(title: "Start Game", style: .default, handler:
        {   _ in
            self.currentLobby.updateChildValues(["gameState": 1])
        }))
        
        if lobby!.pass != nil {
            alert.addAction(UIAlertAction(title: "Show Password", style: .default, handler: passwordFlash))
        }
        
        alert.addAction(title: "Change Countdown (\(settings["preTime"]!))", style: .default, handler: preTimeHandler)
        
        alert.addAction(title: "Change Game Time (\(settings["gameTime"]!))", style: .default, handler: gameTimeHandler)
        
        alert.addAction(cancelAction(withTitle: "Cancel"))
        
        present(alert, animated: true, completion: nil)
    }
    
    func preTimeHandler(_: UIAlertAction)
    {
        let constraints = 10...60
        let alert = UIAlertController(title: "Change Countdown", message: nil, preferredStyle: .alert)
        alert.addTextField
        {   (field) in
            field.placeholder = "(default: 30)"
            field.text = "\(self.settings["preTime"]!)"
        }
        alert.addAction(title: "Done", style: .default)
        {   _ in
            if let input = alert.textFields?[0].text {
                if let value = Int(input) {
                    if constraints.contains(value) {
                        self.currentLobby.child("settings").updateChildValues(["preTime": value])
                        self.settings["preTime"] = value
                        self.ezAlert(title: "Countdown updated to \(value)", message: nil, buttonTitle: "OK")
                        return
                    }
                }
            }
            self.ezAlert(title: "Bad Input", message: "Countdown must be a number between 10 and 60.", buttonTitle: "OK")
        }
        present(alert, animated: true, completion: nil)
    }
    
    func gameTimeHandler(_: UIAlertAction)
    {
        let constraints = 60...600
        let alert = UIAlertController(title: "Change Game Time", message: nil, preferredStyle: .alert)
        alert.addTextField
        {   (field) in
            field.placeholder = "(default: 300)"
            field.text = "\(self.settings["gameTime"]!)"
        }
        alert.addAction(title: "Done", style: .default)
        {   _ in
            if let input = alert.textFields?[0].text {
                if let value = Int(input) {
                    if constraints.contains(value) {
                        self.currentLobby.child("settings").updateChildValues(["gameTime": value])
                        self.settings["gameTime"] = value
                        self.ezAlert(title: "Game time updated to \(value)", message: nil, buttonTitle: "OK")
                        return
                    }
                }
            }
            self.ezAlert(title: "Bad Input", message: "Game time must be a number between 60 and 600.", buttonTitle: "OK")
        }
        present(alert, animated: true, completion: nil)
    }
    
    func chooseSeeker(_: UIAlertAction)
    {
        let alert = UIAlertController(title: "Choose the seeker:", message: nil, preferredStyle: .actionSheet)
        alert.addAction(title: "You", style: .default)
        {   _ in
            self.currentLobby.child("players").child(myPlayerID).updateChildValues(["role": 1])
        }
    }
    
    func passwordFlash(_: UIAlertAction)
    {
        let alert = UIAlertController(title: "Password: \n\(lobby!.pass!)", message: "This message will disappear after 3 seconds.", preferredStyle: .alert)
        present(alert, animated: true)
        {
            sleep(3)
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return hosting
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let uuid = players[indexPath.row].uuid
            currentLobby.child("players").child(uuid).removeValue() //deletes them on Firebase
            
            players.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            //remove player from Firebase & kick them.
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Kick"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "player")!
        let player = players[indexPath.row]
        
        cell.textLabel?.text = player.name //"Device Name"
        cell.detailTextLabel?.text = player.uuid //"UUID"
        
        if player.role != 0 {
            cell.backgroundColor = UIColor(colorLiteralRed: 253/255, green: 128/255, blue: 100/255, alpha: 1)
        }
        
        return cell
    }
    
    func beaconConfiguration(beaconBranch ref: FIRDatabaseReference)
    {
        var beac = ("", 0, 0)
        ref.observeSingleEvent(of: .value, with:
        {   (snap) in
            if let value = snap.value as? [String:Any]
            {
                beac.0 = value["uuid"] as! String
                beac.1 = value["major"] as! Int
                beac.2 = value["minor"] as! Int
                
                let alert = UIAlertController(title: "Beaacon Configuration", message: nil, preferredStyle: .alert)
                //maybe we'll make it so that the user chooses the closest beacon and we do it that way.
            }
        })
    }
}
