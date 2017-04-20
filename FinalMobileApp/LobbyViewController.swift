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
    var settings: [String:Any]!
    
    var lobbyName: String? = nil
    var currentLobby: FIRDatabaseReference
    {
        if let branch = lobbyName
        {
            return ref.child(branch)
        }
        return ref
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        guard lobbyName != nil else
        {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        currentLobby.child("players").childByAutoId().updateChildValues(["name": deviceName, "role": 0])
        
        gameType = .HideAndBeac
        settings = defaultSettingsFor(game: gameType)
        print(settings)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(settingsButton))
        goToView(withID: "newGame", handler: nil)
    }
    
    func settingsButton()
    {
        let alert = UIAlertController(title: "Settings Menu", message: nil, preferredStyle: .actionSheet)
        
        for setting in defaultSettingsFor(game: .HideAndBeac)
        {
            alert.addAction(UIAlertAction(title: "\(setting.key): \(setting.value)", style: .default, handler: settingHandler))
            
        }
    }
    
    func settingHandler(action: UIAlertAction)
    {
        let key = action.title?.components(separatedBy: ": ").first!
        //currentLobby.child("options").child(key).
    }
    
    func defaultSettingsFor(game: GameType) -> [String:Any]
    {
        switch game
        {
        case .HideAndBeac: return ["Countdown": 30, "Round Timer": 300]
        }
    }
}
