# BlueBotController
iOS App bluetooth remote controller acting as central iOS App bluetooth remote controller acting as central.

The BlueBot project consists of two parts. The first part is the laptop application that simulate an electronic robot
that communicate via bluetooth with its remote. The second part is an iOS application that behave as a bluetooth controller.

The iOS communicate with the [simualtor OSX app](https://github.com/nour7/BlueBotSimulator) to turn on/off the robot and to 
receive alerts notifications when the robot has low battery or get stuck. 

The steps that are required to turn the mobile app into a bluetooth central:

1. Implement CBCentralManagerDelegate methods [centralManagerDidUpdateState,
didDiscover, didConnect, didDisconnectPeripheral]
2. Implement CBPeripheralDelegate methods [didDiscoverServices,
didDiscoverCharacteristicsFor, didUpdateValueFor, didWriteValueFor]
3. Create a instance of CBCentralManager , CBPeripheral classes
4. Scan for peripherals using CBCentralManager instance
5. Connect to the robot peripheral From the list of scanned peripherals (Laptop)
6. Discover the peripheral services and its characteristics
7. Register as a listener for notifiable characteristics.
8. Start reading and writing values using CBPeripheral instance [readValue, writeValue]
9. Detect alerts and read responses using didUpdateValueFor method
10. Detect the response of write request using didWriteValueFor method

![screen1](/c1.PNG) ![screen2](/c2.PNG) ![screen3](/c3.PNG)
