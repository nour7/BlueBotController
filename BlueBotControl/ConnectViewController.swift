//
//  ViewController.swift
//  BlueBotControl
//
//  Created by Nour on 09/05/2018.
//  Copyright © 2018 Nour Saffaf. All rights reserved.
//

import UIKit
import CoreBluetooth
import NotificationCenter

class ConnectViewController: UIViewController {
    /** BlueBotManager reference, injected from AppDelegate*/
    private var blueBotManager: BlueBotManager?
    
     /** Bluetooth status label*/
    @IBOutlet weak var bluetoothStatusLabel: UILabel!

    /** Register the two notification observer [BLUETOOTH_STATE, SIMULATOR_CONNECTION]
     for more info check [viewDidLoad](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload/)
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        blueBotManager = (UIApplication.shared.delegate as? AppDelegate)?.blueBotManager
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showBluetoothState(notification:)), name: NSNotification.Name("BLUETOOTH_STATE"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.simulatorConnectionHandler(notification:)), name: NSNotification.Name("SIMULATOR_CONNECTION"), object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /**
     Recieves the status of the bluetooth and display it to the user
 
     - returns:  nothing
 
     - Parameters:
        - notification: contains the message
     */
    @objc func showBluetoothState(notification: NSNotification){
        
        if let state  = notification.object as? CBManagerState {
         switch state {
         case .unknown:
            bluetoothStatusLabel.text = "Bluetooth Unknown Error"
         case .resetting:
            bluetoothStatusLabel.text = "Bluetooth is resetting, try again later!"
         case .unsupported:
            bluetoothStatusLabel.text = "Bluetooth is unsupported!"
         case .unauthorized:
            bluetoothStatusLabel.text = "It is unauthorized to use Bluetooth!"
         case .poweredOff:
            bluetoothStatusLabel.text = "Bluetooth is powered off!"
         case .poweredOn:
            bluetoothStatusLabel.text = "Bluetooth is powered on!"
         }
         
         if state != .poweredOn {
            let alert  = UIAlertController(title: "Error", message:  bluetoothStatusLabel.text, preferredStyle: .alert)
            present(alert, animated: false, completion: nil)
            
         }
            
        }
        
    }
    
    /**
     Recieves the status of the bluetooth connection. If app is connected to the simualtor then segue to second view
     
     - returns: nothing
     
     - parameters:
        - notification: contains the status of the connection
     */
    @objc func simulatorConnectionHandler(notification: NSNotification){
        if let connection =  notification.object as? Bool {
            if connection {
                performSegue(withIdentifier: "segue_to_start", sender: nil)
                //segue
            }else {
                bluetoothStatusLabel.text = "Failed to connect to simulator?!!"
            }
        }
    }
    
    /**
        Connect button action that start scanning for bluetooth peripherals. For more information check [scanForPeripherals](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518986-scanforperipherals/)
 
        - returns: nothing
 
        - parameters:
            - sender: The UIButton.
     */
    @IBAction func connectToBlueBot(_ sender: UIButton) {
        
        if blueBotManager?.centralManager.state == .poweredOn {
            blueBotManager?.centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
}

