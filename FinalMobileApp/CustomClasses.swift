//
//  Lobby.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 4/19/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import Foundation

class Lobby
{
    var name: String!
    var host: String!
    var pass: String?
    var gameState: Int! = 0
    var numPlayers: Int!
    
    init(name: String, host: String, pass: String?)
    {
        self.name = name
        self.host = host
        self.pass = pass
        gameState = 0
        numPlayers = 0
    }
    
    init(name: String, dict: [String:Any])
    {
        self.name = name
        
        if let players = dict["players"] as? [String:Any] {
            numPlayers = players.count - 1 //exclude host element
            if let host = players["host"] as? String
            {
                self.host = host
            }
        }
        
        if let password = dict["password"] as? String, password != ""
        {
            self.pass = password
        }
        
        if let state = dict["gameState"] as? Int
        {
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
