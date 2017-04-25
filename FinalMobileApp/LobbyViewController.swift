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
    
    var hosting = false
    
    var lobby: Lobby? = nil
    var currentLobby: FIRDatabaseReference
    {
        if let branch = lobby!.name
        {
            return ref.child(branch)
        }
        return ref
    }
    
    let uuid = UUID().uuidString
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard lobby != nil else
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        currentLobby.child("players").child(uuid).updateChildValues(["name": deviceName, "role": 0])
        
        gameType = .HideAndBeac
        settings = defaultSettingsFor(game: gameType)
        
        if hosting
        {
            currentLobby.child("settings").updateChildValues(settings)
            currentLobby.child("players").updateChildValues(["host": deviceName])
            currentLobby.child("beacon").updateChildValues(["uuid": beaconUUID, "major": beaconMajor, "minor": beaconMinor])
        }
        
        navigationItem.title = lobby?.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(settingsButton))
    }
    
    deinit //viewDidUnload()
    {
        currentLobby.child("players").child(uuid).removeValue()
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
    }
    
    func settingsButton()
    {
        let alert = UIAlertController(title: "Settings Menu", message: nil, preferredStyle: .actionSheet)
        
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
            tableView.deleteRows(at: [indexPath], with: .left)
            //remove player from Firebase & kick them.
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "Kick"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "player")!
        cell.textLabel?.text = "Device Name"
        cell.detailTextLabel?.text = "UUID"
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
}
