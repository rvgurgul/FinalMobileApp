//
//  LobbyViewController.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 4/3/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit

enum GameType: String
{
    case HideAndBeac = "hide_and_seek"
}

var gameSettings: [GameType:[String:Any]]
{
    var settings = [GameType:[String:Any]]()
    settings[GameType.HideAndBeac] = ["Countdown": 30, "Round Timer": 300]
    
    return settings
}

class LobbyViewController: UIViewController
{
    var gameType: GameType!
    
    func settingsButton()
    {
        let alert = UIAlertController(title: "Settings Menu", message: nil, preferredStyle: .actionSheet)
        if let settings = gameSettings[gameType]
        {
            for setting in settings
            {
                alert.addAction(UIAlertAction(title: "\(setting.key): \(setting.value)", style: .default, handler: <#T##((UIAlertAction) -> Void)?##((UIAlertAction) -> Void)?##(UIAlertAction) -> Void#>))
            }
        }
    }
}
