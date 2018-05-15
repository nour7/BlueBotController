//
//  StopViewController.swift
//  BlueBotControl
//
//  Created by Nour on 14/05/2018.
//  Copyright © 2018 Nour Saffaf. All rights reserved.
//

import UIKit
import NotificationCenter
import AVFoundation

class StopViewController: UIViewController {
    /** BlueBotManager reference, injected from AppDelegate*/
    private var blueBotManager: BlueBotManager?
    
    /** Robot status label*/
    @IBOutlet weak var botStatusLabel: UILabel!
    /** Robot Timer label*/
    @IBOutlet weak var botTimerLabel: UILabel!
    /** Robot Speed label*/
    @IBOutlet weak var botSpeedLabel: UILabel!
    /** Robot Battery label*/
    @IBOutlet weak var botBatteryLabel: UILabel!
    /** Robot Warning label*/
    @IBOutlet weak var botWarningLabel: UILabel!
    
    /** Timer variable*/
    private var timerValue = 60
    /** Timer instance for count down*/
    private var timer: Timer?
    /** Timer periodic in seconds*/
    private var connectionTime = 3
    
    
    private let STATUS_OFF: UInt8 = 0
    private let STATUS_ON: UInt8 = 1
    private let STATUS_ERROR: UInt8 = 2
    private let STATUS_STUCK: UInt8 = 3
    
    
    /** Request read Info from the robot. Register four notification observer [SIMULATOR_CONNECTION, BOT_POWER_UPDATED, SIMULATOR_INFO, ALERT_INFO ]. Initial the labels to defualt values
     for more info check [viewDidLoad](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload/)
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        blueBotManager = (UIApplication.shared.delegate as? AppDelegate)?.blueBotManager
        blueBotManager?.readDataFromBot(cbuuid: BlueBotModel.BOT_INFO_UUID)
        
        botSpeedLabel.text = "Speed: \(BlueBotModel.getPref(key: BlueBotModel.PREF_SPEED_VALUE))"
        botTimerLabel.text = "Timer: \(BlueBotModel.getPref(key: BlueBotModel.PREF_TIMER_VALUE))"
        timerValue = BlueBotModel.getPref(key: BlueBotModel.PREF_TIMER_VALUE)
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.simulatorConnectionHandler(notification:)), name: NSNotification.Name("SIMULATOR_CONNECTION"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(botPowerHandler(notification:)), name: NSNotification.Name("BOT_POWER_UPDATED"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(botAlertHandler(notification:)), name: NSNotification.Name("ALERT_INFO"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(botInfoHandler(notification:)), name: NSNotification.Name("SIMULATOR_INFO"), object: nil)
        // Do any additional setup after loading the view.
    }
    
    /** Start count down timer*/
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(connectionTime), repeats: true) { timer in
            self.blueBotManager?.readDataFromBot(cbuuid: BlueBotModel.BOT_INFO_UUID)
            self.timerValue = self.timerValue - self.connectionTime
            self.botTimerLabel.text = "Timer: \(self.timerValue)"
        }
    }
    
    /** Invalidate the timer*/
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
        Stop button action that turns off the robot by updating the Power characterstic
 
        - returns: nothing
 
        - parameters:
            - sender: the UI button
     */
    @IBAction func stopBlueBot(_ sender: UIButton) {
        let data = Data.init(bytes: [0])
        blueBotManager?.writeDataToBot(data: data, cbuuid: BlueBotModel.BOT_POWER_UUID)
    }
    /**
     Receives the BOT_POWER_UPDATED notification message. if power is off then disconnect from the simulator and go back to first view
 
     - returns: nothing
 
     - parameters:
        - notification: contains the power status of the robot
     */
    @objc func botPowerHandler(notification: NSNotification){
        if let powerState = notification.object as? Bool {
           print("stop power state \(powerState)")
            if !powerState {
                (UIApplication.shared.delegate as? AppDelegate)?.window!.rootViewController?.dismiss(animated: false, completion: nil)
                blueBotManager?.dissconnect()
            }
        }
    }
    /**
     Receives the SIMULATOR_CONNECTION notification message. If power value is zero, then go back to the first view
     
     - returns: nothing
    
     - parameters:
        - notification: contains the connection status of the robot
     */
    @objc func simulatorConnectionHandler(notification: NSNotification){
        if let connection =  notification.object as? Bool {
            if !connection {
                 (UIApplication.shared.delegate as? AppDelegate)?.window!.rootViewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    /**
     Receives the read-only bot info characterstic SIMULATOR_INFO. It updates the status and battery labels in the view
     
     - returns: nothing
     
     - parameters:
        - notification: contains the info message of the robot
     */
    @objc func botInfoHandler(notification: NSNotification){
        if let info = notification.object as? [UInt8] {
            if info.count > 1 {
            if let status = info.first {
                switch status {
                case STATUS_OFF:
                    botStatusLabel.text = "Status is OFF"
                case STATUS_ON:
                    botStatusLabel.text = "Status is ON"
                case STATUS_STUCK:
                    botStatusLabel.text = "Status is STUCK"
                case STATUS_ERROR:
                    botStatusLabel.text = "Status is ERROR"
                default:
                    botStatusLabel.text = "Status is OFF"
                    
                }
            }
            
            botBatteryLabel.text = "Battery \(info.last!)%"
            }
        }
    }
    
    /**
     Receives the Alert characterstic and notify the user via message and sound
     
     - returns: nothing
     
     - parameters:
        - notification: contains the alert message of the robot
     */
    @objc func botAlertHandler(notification: NSNotification){
        if let alerts = notification.object as? [UInt8] {
            if alerts.count == 4 {
                if alerts.reduce(0, +) == 0 {
                    botWarningLabel.isHidden = true
                } else {
                    botWarningLabel.isHidden = false
                    if alerts[0] != 0 {
                        botWarningLabel.text = "Warning: Battery is LOW"
                        AudioServicesPlayAlertSound(SystemSoundID(1006))
                    } else if alerts[1] != 0 {
                        botWarningLabel.text = "Warning: BlueBot has error"
                        AudioServicesPlayAlertSound(SystemSoundID(1073))
                    }else if alerts[2] != 0 {
                        botWarningLabel.text = "Warning: BlueBot is Stuck"
                        AudioServicesPlayAlertSound(SystemSoundID(1005))
                    }else if alerts[3] != 0 {
                        botWarningLabel.isHidden = true
                    }
                }
            }
        }
    }
    
  

}
