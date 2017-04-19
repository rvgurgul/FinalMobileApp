//
//  Lobby.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 4/19/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import Foundation

struct Lobby
{
    var name: String
    var host: String
    var pass: String?
    
    init(name: String, host: String, pass: String?)
    {
        self.name = name
        self.host = host
        self.pass = pass
    }
    
    func valid(password: String) -> Bool
    {
        return self.pass == nil || self.pass == password
    }
}
