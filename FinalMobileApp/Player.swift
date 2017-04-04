//
//  Player.swift
//  FinalMobileApp
//
//  Created by Richie Gurgul on 3/20/17.
//  Copyright © 2017 Richie Gurgul. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Player
{
    var name = ""
    var locationToBeacon = [UUID: Double]()
    
    var hider = true
    var ready = false
    
    init(name: String, uuid: UUID, majorValue: CLBeaconMajorValue, minorValue: CLBeaconMinorValue)
    {
        self.name = name
        self.uuid = uuid
        self.majorValue = majorValue
        self.minorValue = minorValue
    }
    
}
