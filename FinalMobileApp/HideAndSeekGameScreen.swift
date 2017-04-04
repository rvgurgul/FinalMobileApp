//
//  HideAndSeekGameScreen.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 3/22/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit

class HideAndSeekGameScreen: UITableViewController
{
    var time = 300
    var tim: Timer!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tim = Timer(timeInterval: 1, target: self, selector: #selector(timeStep), userInfo: nil, repeats: true)
    }
    
    func timeStep()
    {
        if time > 0{
            time -= 1
            
            let minutes = "\(time / 60)"
            var seconds = "\(time % 60)"
            if seconds.characters.count == 1 {seconds = "0\(seconds)"}
            
            navigationItem.title = "\(minutes):\(seconds)"
        }
        else{
            tim.invalidate()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0//number of players
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = "Player name"
        if true //player.hider = true
        {
            cell.detailTextLabel?.text = "Distance to Player"
        }

        return cell
    }
}
