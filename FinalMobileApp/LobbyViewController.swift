//
//  LobbyViewController.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 4/3/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit
import Firebase

enum GameType: String
{
    case HideAndBeac = "hide_and_seek"
}

class LobbyViewController: UITableViewController
{
    var gameType: GameType!
    var settings: [String:Int]!
    
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard lobby != nil else
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        //Set the top bar to say the lobby's name.
        navigationItem.title = lobby?.name
        
        //Initialize Player's Branch with name, role, and ready state.
        currentLobby.child("players").child(myPlayerID).updateChildValues(["name": deviceName, "role": 0, "ready": false, "dist": 0])
        
        //Default to Hide and Beac
        gameType = .HideAndBeac
        settings = defaultSettingsFor(game: gameType)
        
        //Specifics based on whether the player is host or not.
        if hosting
        {
            currentLobby.updateChildValues(["gameState": 0])
            currentLobby.child("settings").updateChildValues(settings)
            currentLobby.child("players").updateChildValues(["host": deviceName])
            currentLobby.child("beacon").updateChildValues(["uuid": beaconUUID, "major": beaconMajor, "minor": beaconMinor])
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(settingsButton))
        }
        else
        {
            //set rightbaritem to a ready up button.
        }
        
        //Listening for player joining
        currentLobby.child("players").observe(.childAdded, with:
        {   (snap) in
            print("Added")
            if let value = snap.value as? [String:Any]
            {
                let uuid = snap.key
                if myPlayerID != uuid //don't include the host themself
                {
                    let name = value["name"] as! String
                    let role = value["role"] as! Int
                    
                    self.players.append(Player(uuid, name, role))
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
            print("Removed")
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
                for i in 0..<self.players.count
                {
                    if i >= self.players.count
                    {
                        for _ in 0...15 {print("oh no, very bad")}
                    }
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
                    if let nextVC = vc as? HideAndSeekGameScreen
                    {
                        nextVC.lobby = self.lobby
                        nextVC.players = self.players
                    }
                })
            }
        })
        
        allJoinedLobbies.append(currentLobby)
    }
    
    deinit //viewDidUnload()
    {
        print("deinitializing")
        currentLobby.child("players").child(myPlayerID).removeValue()
        currentLobby.child("players").observeSingleEvent(of: .value, with:
        {   (snap) in
            if let value = snap.value as? [String: Any]
            {
                if value.count == 1 //only "host" remains
                {
                    //goes up 1 level and destroys the lobby.
                    snap.ref.parent!.removeValue()
                }
            }
        })
        
        currentLobby.child("players").removeAllObservers()
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
        
        for setting in settings {
            alert.addAction(SettingsAlertAction(setting: setting))
        }
        
        alert.addAction(cancelAction(withTitle: "Cancel"))
        
        present(alert, animated: true, completion: nil)
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
    
    func defaultSettingsFor(game: GameType) -> [String:Int]
    {
        switch game
        {
        case .HideAndBeac: return ["Countdown": 30, "Round Timer": 300]
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "Kick"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return players.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "player")!
        let player = players[indexPath.row]
        
        cell.textLabel?.text = player.name //"Device Name"
        cell.detailTextLabel?.text = player.uuid //"UUID"
        return cell
    }
    
    func SettingsAlertAction(setting: (String, Int)) -> UIAlertAction
    {
        return UIAlertAction(title: "\(setting.0): \(setting.1)", style: .default, handler: settingHandler)
    }
    
    func settingHandler(action: UIAlertAction)
    {
        if let parts = action.title?.components(separatedBy: ": ")
        {
            let alert = UIAlertController(title: "Change \(parts[0])", message: nil, preferredStyle: .alert)
            alert.addTextField
            {   (field) in
                field.placeholder = parts[1]
            }
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler:
            {   _ in
                if let input = alert.textFields?[0].text! {
                    if let output = Int(input)
                    {
                        self.currentLobby.child("settings").updateChildValues([parts[0]: output])
                        self.settings[parts[0]] = output
                    }
                }
            }))
            alert.addAction(cancelAction(withTitle: "Cancel"))
            present(alert, animated: true, completion: nil)
        }
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
