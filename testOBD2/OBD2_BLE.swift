import Foundation
import CoreBluetooth
import UserNotifications
import RealmSwift

private class OBD2_BLESetup {
    var restoreId:String?
}

//MARK: - parameter & function
public class OBD2_BLE: NSObject {
    var centralManager: CBCentralManager!
    var obd2: CBPeripheral?
    var charToWriteWithRes: CBCharacteristic?
    var charToWrite: CBCharacteristic?
    var charToNoti: CBCharacteristic?
    
    var obdResponse:[UInt8] = []
    let endOfResponseNotificationIdentifier = Notification.Name("endOfResponseNotificationIdentifier")
    let warucRestoreId = "test.OBD2.CDG"
    
    // setupOutput is expected output from device after reset (no prior configuration)
    // partialsetupOutput is expected output from device without reset (device remained configured from previous run)
    let restartSetupOutput = "\r\rELM327 v1.5\r\r>ATE0\rOK\r\r>OK\r\r>OK\r\r>OK\r\r>OK\r\r>"
    let setupOutput = "ATE0\rOK\r\r>OK\r\r>OK\r\r>OK\r\r>OK\r\r>"
    let partialsetupOutput = "OK\r\r>OK\r\r>OK\r\r>OK\r\r>OK\r\r>"
    var setupComplete = false
    var vinNumber:String?
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    
    var setUpCommand: [Command] = [.set1,.set1]
    //,.set2,.set3,.set4,.set5,.set6,.set7,.set8,.set9,.set10,.set11
    var mainCommand: [Command] = [.engineRPM,.velocity]
    var inprogressCommand: [Command] = []
    var enableLoop = false
    var tempSpeedValue: Int = 0
    var tempEngineValue: Int = 0
    
    static let sharedInstance = OBD2_BLE()
    private static let setup = OBD2_BLESetup()
    var isNoti = false
    
    let realm = try! Realm()
    
    class func setup(restoreId: String) {
        OBD2_BLE.setup.restoreId = restoreId
    }
    
    public override init() {
        super.init()
        let restoreId = OBD2_BLE.setup.restoreId
        if restoreId == nil {
            self.initWithoutBackground()
        } else {
            self.initWithBackground(restoreId: restoreId!)
        }
        
        self.userNotificationCenter.delegate = self
        self.requestNotificationAuthorization()
        
    }
    
    internal func initWithoutBackground() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    internal func initWithBackground(restoreId: String) {
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey : restoreId])
    }
    
    public func configureOBD() {
        obd2?.writeValue(Data(Array("ATZ\r".utf8)), for: charToWrite!, type: .withoutResponse)
        obd2?.writeValue(Data(Array("ATE0\r".utf8)), for: charToWrite!, type: .withoutResponse)
        obd2?.writeValue(Data(Array("ATL0\r".utf8)), for: charToWrite!, type: .withoutResponse)
        obd2?.writeValue(Data(Array("ATS1\r".utf8)), for: charToWrite!, type: .withoutResponse)
        obd2?.writeValue(Data(Array("ATAT0\r".utf8)), for: charToWrite!, type: .withoutResponse)
        obd2?.writeValue(Data(Array("ATSP0\r".utf8)), for: charToWrite!, type: .withoutResponse)
        obd2?.writeValue(Data(Array("ATH1\r".utf8)), for: charToWrite!, type: .withoutResponse)
        obd2?.writeValue(Data(Array("0100\r".utf8)), for: charToWrite!, type: .withoutResponse)
        obd2?.writeValue(Data(Array("0120\r".utf8)), for: charToWrite!, type: .withoutResponse)
        obd2?.writeValue(Data(Array("0140\r".utf8)), for: charToWrite!, type: .withoutResponse)
        obd2?.writeValue(Data(Array("ATH0\r".utf8)), for: charToWrite!, type: .withoutResponse)
    }
    
    public func byteToData(byteData: [UInt8]) -> Double{
        let resStr = String(byteData.map{Character(UnicodeScalar($0))})
        let commandStr = resStr.split(separator: "\r")[0]
        let dataStr = resStr.split(separator: "\r")[1]
        print(">> \(resStr) ")
        
        return 124124235
        
        let thisCommand = Command(commandCode: String(commandStr))
        let res = thisCommand?.getValue(dataStr: String(dataStr)) ?? -1
        print(">>> \(thisCommand!.rawValue) = \(res)")
        
        if thisCommand == .engineRPM && res > 15 && !isNoti {
            isNoti = true
            sendNotification(value: "rpm = \(res) << to high")
        } else if thisCommand == .engineRPM && res < 15 {
            isNoti = false
        }
        if thisCommand == .velocity {
            let newItem = Speed()
            newItem.howfast = Double(res)
            
            let allItems = realm.objects(Speed.self)
            if(allItems.isEmpty){
                do{
                    try realm.write{
                        realm.add(newItem)
                        print("From ADD")
                    }
                } catch {   print("realm error to add latlng >> \(error)") }
            }else{
                var item = allItems[0]
                do{
                    try realm.write{
                        item = newItem
                        print("From Update")
                    }
                }catch {   print("realm error to update latlng >> \(error)") }
                
            }
        }
        
        return Double(res)
    }
}
//MARK: - Notification
extension OBD2_BLE: UNUserNotificationCenterDelegate{
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    func sendNotification(value: String) {
        print("send noti")
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Test"
        notificationContent.body = "\(value)"
        notificationContent.badge = NSNumber(value: 3)
        if let url = Bundle.main.url(forResource: "dune",
                                     withExtension: "png") {
            if let attachment = try? UNNotificationAttachment(identifier: "dune",
                                                              url: url,
                                                              options: nil) {
                notificationContent.attachments = [attachment]
            }
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification",
                                            content: notificationContent,
                                            trigger: trigger)
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
}
//MARK: - check bt > scan > connect > disconnect
extension OBD2_BLE: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("Bluetooth on this device is currently powered off.")
        case .unsupported:
            print("This device does not support Bluetooth Low Energy.")
        case .unauthorized:
            print("This app is not authorized to use Bluetooth Low Energy.")
        case .resetting:
            print("The BLE Manager is resetting; a state update is pending.")
        case .unknown:
            print("The state of the BLE Manager is unknown.")
        case .poweredOn:
            print("Bluetooth LE is turned on and ready for communication.")
//            centralManager.scanForPeripherals(withServices: nil, options: nil)
            centralManager.scanForPeripherals(withServices: [CBUUID(string: "FFF0")],  options: nil)
        @unknown default:
            print("error")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                               advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil else {
//            print(peripheral)
            return
        }
        print(peripheral.name!,peripheral.identifier)
        if peripheral.name! == "OBDII" || peripheral.name!.hasPrefix("MYCAR") {
            print("OBD2 Found! : \(peripheral.identifier)")
            obd2 = peripheral
            obd2?.delegate = self
            centralManager.stopScan()
            centralManager.connect(obd2!)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral")
        sendNotification(value: "bt disconnect")
        centralManager.scanForPeripherals(withServices: [CBUUID(string: "FFF0")],  options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect")
        sendNotification(value: "bt connect")
        obd2?.discoverServices(nil)
    }
    
    //        public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
    //            print("willRestoreState")
    //        }
}
//MARK: - check service & check characteristic & receive rersponse from bt device
extension OBD2_BLE: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverServices")
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //        print("didDiscoverCharacteristicsFor")
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.writeWithoutResponse) {          // 2a07 || fff2 for request service
                print("\(characteristic.uuid): properties contains .writeWithoutResponse")
                charToWrite = characteristic
            } else if characteristic.properties.contains(.write) {                  // fff2 for config
                print("\(characteristic.uuid): properties contains .write")
                charToWriteWithRes = characteristic
            } else if characteristic.properties.contains(.notify) {                 // fff1 for noti
                print("\(characteristic.uuid): properties contains .notify")
                charToNoti = characteristic
                obd2?.setNotifyValue(true, for: charToNoti!)
            }
        }
        if charToWrite != nil && charToNoti != nil {
            LatLngCallService.shared.locationManager.requestAlwaysAuthorization()
            LatLngCallService.shared.locationManager.requestLocation()
            inprogressCommand = mainCommand
            setupComplete = true
//            print("send \(inprogressCommand[0].getCommand()) command")
//            obd2!.writeValue(Data(Array("\(inprogressCommand[0].getCommand())\r".utf8)), for: charToWrite!, type: .withoutResponse)
//            inprogressCommand.removeFirst()
            obd2!.writeValue(Data(Array("\(inprogressCommand[0].getCommand())\r".utf8)), for: charToWrite!, type: .withoutResponse)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //        print("didUpdateValueFor")
        if error != nil {
            print("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(String(describing: error?.localizedDescription))")
            return
        }
        let returnedBytes = [UInt8](characteristic.value!)
        obdResponse += returnedBytes
        if (Array(obdResponse.suffix(3)).map { String(UnicodeScalar($0)) }.joined()) == "\r\r>" {   // found \r\r> = End of response
            let responseData = byteToData(byteData: obdResponse)
            
            obdResponse = []
            if enableLoop {
                if !setupComplete{
                    if obd2 == nil || charToWrite == nil {
                        print("Device is not connected to an OBD-II scanner.")
                    } else {
                        print("send \(inprogressCommand[0].getCommand()) command")
                        obd2!.writeValue(Data(Array("\(inprogressCommand[0].getCommand())\r".utf8)), for: charToWrite!, type: .withoutResponse)
                        inprogressCommand.removeFirst()
                    }
                    if inprogressCommand.isEmpty {
                        setupComplete = true
                    }
                } else {
                    if inprogressCommand == [] {
                        if mainCommand == [] {
                            print("no command in list")
                            enableLoop = false
                            return
                        }
                        inprogressCommand = mainCommand
                    }
                    if obd2 == nil || charToWrite == nil {
                        print("Device is not connected to an OBD-II scanner.")
                    } else {
                        print("send \(inprogressCommand[0].getCommand()) command")
                        obd2!.writeValue(Data(Array("\(inprogressCommand[0].getCommand())\r".utf8)), for: charToWrite!, type: .withoutResponse)
                    }
                    inprogressCommand.removeFirst()
                }
                
            }
        }
    }
}
