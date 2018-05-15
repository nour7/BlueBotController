//
//  BlueBotManager.swift
//  BlueBotControl
//
//  Created by Nour on 14/05/2018.
//  Copyright © 2018 Nour Saffaf. All rights reserved.
//

import Foundation
import CoreBluetooth
import NotificationCenter

/**
 This calss is responsible for bluetooth connection with the robot peripheral
 */
class BlueBotManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    /** CBCentralManager instance*/
    var centralManager: CBCentralManager!
    /** Macbook CBPeripheral instance*/
    var macPeripheral:CBPeripheral?
    /** Simulator CBService instance*/
    private var botService: CBService?
    /** Power status of the bot*/
    var botPowerState = false
    
    /**Init centralManager instance which will trigger centralManagerDidUpdateState method */
    override init(){
       super.init()
       centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /**
     Disconnect from the robot peripheral, for more info check [cancelPeripheralConnection](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/1518952-cancelperipheralconnection/)
     
     - returns: nothing

     */
    func dissconnect() {
        if let peripheral = macPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            botPowerState = false
        }
    }
    
    /**
     Send write request to the robot peripheral, for more info check [CBPeripheral:writeValue](https://developer.apple.com/documentation/corebluetooth/cbperipheral/1518747-writevalue)
     
     - returns: nothing
     
     - parameters:
        - data: Settings or Power characterstics data
        - cbuuid: The 128-bit universally unique identifier that identify the characterstic to read from. The value is defind in BlueBotModel structure
     */
    func writeDataToBot(data: Data, cbuuid: CBUUID){
        if let characteristics =  botService?.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == cbuuid {
                    if characteristic.properties.contains(.write) {
                        macPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
                    }
                }
            }
        }
    }
    
    /**
     Send read request to the robot peripheral, for more info check [CBPeripheral:readValue](https://developer.apple.com/documentation/corebluetooth/cbperipheral/1518759-readvalue/)
     
     - returns: nothing
     
     - parameters:
        - cbuuid: The 128-bit universally unique identifier that identify the characterstic to read from. The value is defind in BlueBotModel structure
     */
    func readDataFromBot(cbuuid: CBUUID){
        if let characteristics =  botService?.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == cbuuid {
                    if characteristic.properties.contains(.read) {
                        macPeripheral?.readValue(for: characteristic)
                    }
                }
            }
        }
    }
    
    /** Send BLUETOOTH_STATE notification, for more info about [centralManagerDidUpdateState](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate/1518888-centralmanagerdidupdatestate/)
     */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let notificationName = NSNotification.Name("BLUETOOTH_STATE")
        NotificationCenter.default.post(name: notificationName, object: central.state)
    }
    
    /** Send BLUETOOTH_CONNECTION notification, for more info about [didDisconnectPeripheral](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate)
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let notificationName = NSNotification.Name("BLUETOOTH_CONNECTION")
        NotificationCenter.default.post(name: notificationName, object: false)
    }
    
    /** called when the central discover peripheral, It will connect to the macbook using its CBUUID. it will stop scanning    for more info about [centralManager](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate)
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheral.identifier.uuidString == BlueBotModel.MAC_CBUUID.uuidString {
            macPeripheral = peripheral
            macPeripheral!.delegate = self
            centralManager.connect(macPeripheral!, options: nil)
            centralManager.stopScan()
        }
        
    }
    
    /** called when the central conneted to the peripheral to discover the services. For more info about [centralManager](https://developer.apple.com/documentation/corebluetooth/cbcentralmanagerdelegate)
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([BlueBotModel.BOT_SERVICE_UUID])
    }
    
    /** called when the peripheral services are discovered so you can discover the service characteristics . For more info about [CBPeripheralDelegate](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate)
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let _ = error {
            centralManager.cancelPeripheralConnection(peripheral)
            let notificationName = NSNotification.Name("BLUETOOTH_CONNECTION")
            NotificationCenter.default.post(name: notificationName, object: false)
            return
        }
        
        guard let service = peripheral.services?.first else {
            let notificationName = NSNotification.Name("SIMULATOR_CONNECTION")
            NotificationCenter.default.post(name: notificationName, object: false)
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        
        peripheral.discoverCharacteristics([BlueBotModel.BOT_ALERT_INFO_UUID, BlueBotModel.BOT_INFO_UUID, BlueBotModel.BOT_SETTINGS_UUID, BlueBotModel.BOT_POWER_UUID], for: service)
        
    }
    
    /** called when the peripheral service characteristics are discovered so you can register to notifiable characteristics . For more info about [CBPeripheralDelegate](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate)
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let _ = error {
            centralManager.cancelPeripheralConnection(peripheral)
            let notificationName = NSNotification.Name("BLUETOOTH_CONNECTION")
            NotificationCenter.default.post(name: notificationName, object: false)
            return
        }
        
        guard let characteristics = service.characteristics else {
            let notificationName = NSNotification.Name("SIMULATOR_CONNECTION")
            NotificationCenter.default.post(name: notificationName, object: false)
            centralManager.cancelPeripheralConnection(peripheral)
            return
            
        }
        
        botService = service
        for characteristic in characteristics {
            print(characteristic.uuid)
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("\(characteristic.uuid): properties contains .notify")
            }
        }
        
        let notificationName = NSNotification.Name("SIMULATOR_CONNECTION")
        NotificationCenter.default.post(name: notificationName, object: true)
    }
    
    
    /** called when the peripheral update its value or when as response to read request by the central. For more info about [CBPeripheralDelegate](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate)
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let _ = error {
            centralManager.cancelPeripheralConnection(peripheral)
            let notificationName = NSNotification.Name("BLUETOOTH_CONNECTION")
            NotificationCenter.default.post(name: notificationName, object: false)
            return
        }
        
        if let value = characteristic.value {
            let values =  value.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) -> [UInt8] in
                let array = UnsafeBufferPointer(start: pointer, count: value.count)
                return Array<UInt8>(array)
            }
            if characteristic.uuid == BlueBotModel.BOT_INFO_UUID {
                if values.count > 1 {
                    let notificationName = NSNotification.Name("SIMULATOR_INFO")
                    NotificationCenter.default.post(name: notificationName, object: values)
                }
            }
            
            if characteristic.uuid == BlueBotModel.BOT_ALERT_INFO_UUID {
                if let value = characteristic.value {
                    
                    let alerts =  value.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) -> [UInt8] in
                        let array = UnsafeBufferPointer(start: pointer, count: value.count)
                        return Array<UInt8>(array)
                    }
                    
                    let notificationName = NSNotification.Name("ALERT_INFO")
                    NotificationCenter.default.post(name: notificationName, object: alerts)
                    
                }
            }
        }
        
    }
    
    /** called when the peripheral response to write request by the central. For more info about [CBPeripheralDelegate](https://developer.apple.com/documentation/corebluetooth/cbperipheraldelegate)
     */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let _ = error {
            let notificationName = NSNotification.Name("BLUETOOTH_CONNECTION")
            NotificationCenter.default.post(name: notificationName, object: false)
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        
        if characteristic.uuid == BlueBotModel.BOT_POWER_UUID {
            botPowerState = !botPowerState
            let notificationName = NSNotification.Name("BOT_POWER_UPDATED")
            NotificationCenter.default.post(name: notificationName, object: botPowerState)
            }
        }

    
}
