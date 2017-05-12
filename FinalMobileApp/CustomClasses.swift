//
//  Lobby.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 4/19/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Lobby
{
    var name: String
    var host: String
    var pass: String?
    var gameState: Int
    var numPlayers: Int
    var players: [Player]!
    
    init(name: String, dict: [String:Any])
    {
        self.name = name
        self.host = ""
        self.gameState = 0
        self.numPlayers = 0
        
        if let players = dict["players"] as? [String:Any] {
            self.numPlayers = players.count - 1 //exclude host element
            if let host = players["host"] as? String
            {
                self.host = host
            }
        }
        
        if let password = dict["password"] as? String, password != "" {
            self.pass = password
        }
        
        if let state = dict["gameState"] as? Int {
            self.gameState = state
        }
    }
    
    func valid(password: String) -> Bool
    {
        return self.pass == nil || self.pass == password
    }
}

class Player
{
    var uuid: String
    var name: String
    var role: Int
    
    init(_ uuid: String, _ name: String, _ role: Int)
    {
        self.uuid = uuid
        self.name = name
        self.role = role
    }
}
