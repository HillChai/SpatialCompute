//
//  BluetoothViewModel.swift
//  RecordingnARView
//
//  Created by cccc on 2024/3/20.
//

import Foundation
import CoreBluetooth
import os

enum ConnectionStatus: String {
    case connected
    case disconnected
    case scanning
    case connecting
    case error
}

class BlueToothViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    static var instance = BlueToothViewModel()
    
    var centralManager: CBCentralManager!
    @Published var peripheralStatus: ConnectionStatus = .disconnected
    
    // BlueTooth Configurations
    public var savedName: String = UserDefaults.standard.string(forKey: "Name") ?? "BT04-E"
    public var savedServiceUUID: String = UserDefaults.standard.string(forKey: "ServiceUUID") ?? "FFE0"
    public var savedCharacteristicUUID: String = UserDefaults.standard.string(forKey: "CharacteristicUUID") ?? "FFE1"
    
    //BlueTooth connected
    var discoveredPeripheral: CBPeripheral?
    var data = ""
    public var completemessage = ""
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanForPeripherals() {
        peripheralStatus = .scanning
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("CB is powered on")
            scanForPeripherals()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == savedName {
            discoveredPeripheral = peripheral
            centralManager.connect(peripheral)  // attempt to connect it
            peripheralStatus = .connecting
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralStatus = .connected
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        centralManager.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        peripheralStatus = .disconnected
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        peripheralStatus = .error
        print(error?.localizedDescription ?? "no error")
    }
    
    
    // Mark: Characteristic transportation starts.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            if service.uuid == CBUUID(string: savedServiceUUID) {
                print("Service for \(savedServiceUUID) Found!")
                peripheral.discoverCharacteristics([CBUUID(string: savedCharacteristicUUID)], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics ?? [] {
            peripheral.setNotifyValue(true, for: characteristic)
            print("Characteristics from \(characteristic.uuid.uuidString) Found!")
        }
    }
 
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == CBUUID(string: savedCharacteristicUUID) {
            guard let characteristicData = characteristic.value,
                  let stringFromData = String(data: characteristicData, encoding: .utf8) else { return }
            
            if !stringFromData.hasSuffix("\r\n") {
                data.append(stringFromData)
//                print(data)
            } else {
                data.append(stringFromData)
//                print(data)
                completemessage = data
                
//                if self.completemessage.count <= 2 {
//                    self.completemessage.append(self.data)
//                } else {
//                    print(self.completemessage)
//                    self.completemessage.remove(at: 0)
//                    self.completemessage.append(self.data)
//                }
                
                data = ""
            }
        }
        
    }
    
}
