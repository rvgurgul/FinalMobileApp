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

class LobbyViewController: UIViewController
{
    var gameType: GameType!
    var settings: [String:Any]!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        gameType = .HideAndBeac
        settings = defaultSettingsFor(game: gameType)
    }
    
    func settingsButton()
    {
        let alert = UIAlertController(title: "Settings Menu", message: nil, preferredStyle: .actionSheet)
        
        for setting in defaultSettingsFor(game: .HideAndBeac)
        {
            //alert.addAction(UIAlertAction(title: "\(setting.key): \(setting.value)", style: .default, handler: <#T##((UIAlertAction) -> Void)?##((UIAlertAction) -> Void)?##(UIAlertAction) -> Void#>))
            //programatically add the handlers.
            
        }
    }
    
    func defaultSettingsFor(game: GameType) -> [String:Any]
    {
        switch game
        {
        case .HideAndBeac: return ["Countdown": 30, "Round Timer": 300]
        }
    }
}
