//
//  BlueBotModel.swift
//  BlueBotControl
//
//  Created by Nour on 14/05/2018.
//  Copyright © 2018 Nour Saffaf. All rights reserved.
//

import Foundation
import CoreBluetooth

/**
 The model of the app. It constains static 128-bit universally unique identifiers for Laptop, Service and all characterstics. It also saves defauls values using UserDefaults
 */
struct BlueBotModel {
    /** Macbook CBUUID*/
     static let MAC_CBUUID = CBUUID(string: "12345678-111-222-333-AABBCCDDEEFF")
    
    /** Robot service CBUUID */
    static let BOT_SERVICE_UUID = CBUUID(string: "F48DA104-D6B8-43C4-A719-3A03FEA55088")
    /** Robot Alert Characstertic CBUUID */
    static let BOT_ALERT_INFO_UUID =  CBUUID(string: "7AD4DFE9-E047-45CC-88F9-08AB24264423")
    
    /** Robot Info Characstertic CBUUID */
    static let BOT_INFO_UUID =  CBUUID(string: "2EC2C4B8-3199-40BB-88CA-C1CDFA4A897A")
    
     /** Robot Settings Characstertic CBUUID */
    static let BOT_SETTINGS_UUID =  CBUUID(string: "441CDBF6-9446-4794-B167-A7C0339CBBFD")
    
    /** Robot Power Characstertic CBUUID */
    static let BOT_POWER_UUID =  CBUUID(string: "320B4788-BA18-47A7-BEE6-698E9CAF2DB0")
    
    /** UserDefaults Key for selected Speed picker row */
    static let PREF_SPEED_PICKER_ROW = "SPEED_PICKER"
     /** UserDefaults Key for selected Timer picker row */
    static let PREF_TIMER_PICKER_ROW = "TIMER_PICKER"
     /** UserDefaults Key for Speed integer value */
    static let PREF_SPEED_VALUE = "SPEED_VALUE"
      /** UserDefaults Key for Timer integer value */
    static let PREF_TIMER_VALUE = "TIMER_VALUE"
    
    /**
     Read the saved preference. For more info check [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults/)
     
     - returns: Integer value (Speed, Timer...)
     
     - parameters:
        - key: The string identifier of the preference
     */
    static func getPref(key: String) -> Int {
        let botDefaults = UserDefaults.init()
        return botDefaults.integer(forKey: key)
    }
    
    /**
     Save the preference. For more info check [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults/)
     
     - returns: nothing
     
     - parameters:
        - key: The string identifier of the preference
        - value: Integer value (Speed, Timer ..)
     */
    static func savePref(key: String, value: Int) {
        let botDefaults = UserDefaults.init()
         botDefaults.set(value, forKey: key)
    }

}
