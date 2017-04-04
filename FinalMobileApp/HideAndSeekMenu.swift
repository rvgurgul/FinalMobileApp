//
//  HideAndSeekMenu.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 3/21/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import UIKit
import CoreLocation

class HideAndSeekMenu: UITableViewController, CLLocationManagerDelegate
{
    let uuid = UUID().uuidString
    
    var countdown = 30
    var roundTime = 300
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //set(countdown, forKey: "\(uuid)/countdown")
        //set(roundTime, forKey: "\(uuid)/timer")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(settingsButton))
    }
    
    func settingsButton()
    {
        let actions = UIAlertController(title: "Hide & Seek Options", message: nil, preferredStyle: .actionSheet)
        actions.addAction(UIAlertAction(title: "Change Initial Countdown", style: .default, handler: changeCountdown))
        actions.addAction(UIAlertAction(title: "Change Round Time Limit", style: .default, handler: changeRoundTimer))
        actions.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actions, animated: true, completion: nil)
    }
    
    func changeCountdown(_: UIAlertAction)
    {
        let alert = UIAlertController(title: "Change Initial Countdown", message: "This is the amount of time of the starting countdown before the seeker can start looking for hiders.", preferredStyle: .alert)
        alert.addTextField
        {   (field) in
            field.placeholder = "\(self.countdown)"
        }
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler:
        {   _ in
            //set(countdown, forKey: "\(uuid)/countdown"
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func changeRoundTimer(_: UIAlertAction)
    {
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let uuid = [UUID](players.keys)[indexPath.row]
        let name = players[uuid]
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = uuid.uuidString

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "Kick"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let uuid = [UUID](players.keys)[indexPath.row]
            players.removeValue(forKey: uuid)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
