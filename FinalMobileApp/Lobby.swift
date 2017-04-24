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
    
    init(name: String, host: String, pass: String?)
    {
        self.name = name
        self.host = host
        self.pass = pass
    }
    
    init(name: String, dict: [String:Any])
    {
        self.name = name
        
        if let players = dict["players"] as? [String:Any] {
            if let host = players["host"] as? String
            {
                self.host = host
            }
        }
        
        if let password = dict["password"] as? String, password != ""
        {
            self.pass = password
        }
    }
    
    func valid(password: String) -> Bool
    {
        return self.pass == nil || self.pass == password
    }
}
