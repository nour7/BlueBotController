//
//  StartViewController.swift
//  BlueBotControl
//
//  Created by Nour on 14/05/2018.
//  Copyright © 2018 Nour Saffaf. All rights reserved.
//

import UIKit
import NotificationCenter

class StartViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    /** BlueBotManager reference, injected from AppDelegate*/
    private var blueBotManager: BlueBotManager?
    
    /** Speed values for Speed PickerView*/
    let botSpeed: [UInt8] = [1,2,3,4,5]
     /** Timer values for Timer PickerView*/
    let botTime: [UInt8] = [20,30,40,50,60]
     /** Speed PickerView*/
    @IBOutlet weak var speedPickerView: UIPickerView!
      /** Timer PickerView*/
    @IBOutlet weak var timerPickerView: UIPickerView!
    
    /** Register the two notification observer [BOT_POWER_UPDATED, SIMULATOR_CONNECTION]
     for more info check [viewDidLoad](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload/)
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blueBotManager = (UIApplication.shared.delegate as? AppDelegate)?.blueBotManager
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.simulatorConnectionHandler(notification:)), name: NSNotification.Name("SIMULATOR_CONNECTION"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(botPowerHandler(notification:)), name: NSNotification.Name("BOT_POWER_UPDATED"), object: nil)
        
        if blueBotManager == nil {
            dismiss(animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
        Start button action that turn on the robot by updating the Power characterstics
 
        - returns: nothing
 
        - parameters:
            - sender:The UIButton
 */
    @IBAction func startBlueBot(_ sender: UIButton) {
        let data = Data.init(bytes: [1])
        blueBotManager?.writeDataToBot(data: data, cbuuid: BlueBotModel.BOT_POWER_UUID)
    }
    
    /**
        Receives the BOT_POWER_UPDATED notification message. If the power is on, segue to third view
 
        - returns: nothing
 
        - parameters:
            - notification: contains the power status of the robot
     */
    @objc func botPowerHandler(notification: NSNotification){
        if let powerState = notification.object as? Bool {
            if powerState {
                print("start power state \(powerState)")
                performSegue(withIdentifier: "segue_to_running", sender: nil)
            }
        }
    }
    
    /**
        Receives the SIMULATOR_CONNECTION notification message. If the connection is lost, dismiss this view and return to first Connect view
 
        - returns: nothing
 
        - parameters:
            - notification: contains the value of the Power characterstic
     */
    @objc func simulatorConnectionHandler(notification: NSNotification){
        if let connection =  notification.object as? Bool {
            if !connection {
                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    /** For more info check [UIPickerView](https://developer.apple.com/documentation/uikit/uipickerview)
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /** For more info check [UIPickerView](https://developer.apple.com/documentation/uikit/uipickerview)
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return botSpeed.count
    }
    
    /** For more info check [UIPickerView](https://developer.apple.com/documentation/uikit/uipickerview)
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.restorationIdentifier == speedPickerView.restorationIdentifier {
            BlueBotModel.savePref(key: BlueBotModel.PREF_SPEED_PICKER_ROW, value: row)
            BlueBotModel.savePref(key: BlueBotModel.PREF_SPEED_VALUE, value: Int(botSpeed[row]))
            let settings: [UInt8] = [0, botSpeed[row]]
            let data = Data.init(bytes: settings)
            blueBotManager?.writeDataToBot(data: data, cbuuid: BlueBotModel.BOT_SETTINGS_UUID)
        }
        
        if pickerView.restorationIdentifier == timerPickerView.restorationIdentifier {
            BlueBotModel.savePref(key: BlueBotModel.PREF_TIMER_PICKER_ROW, value: row)
            BlueBotModel.savePref(key: BlueBotModel.PREF_TIMER_VALUE, value: Int(botTime[row]))
            let settings: [UInt8] = [botTime[row], 0]
            let data = Data.init(bytes: settings)
            blueBotManager?.writeDataToBot(data: data, cbuuid: BlueBotModel.BOT_SETTINGS_UUID)
        }
        
    }
    
    /** For more info check [UIPickerView](https://developer.apple.com/documentation/uikit/uipickerview)
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.restorationIdentifier == speedPickerView.restorationIdentifier {
            return String(botSpeed[row])
        }else {
            return String(botTime[row])
        }
        
    }

}
