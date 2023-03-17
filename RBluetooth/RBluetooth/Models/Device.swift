//
//  Device.swift
//  XcubeBluetooth
//
//  Created by Ramkumar Chintala on 17/03/23.
//  Copyright © 2023 Ramkumar Chintala. All rights reserved.
//

import CoreBluetooth

class Device: NSObject {
    typealias ServicesHandler = ((_ services:[CBService]?) -> Void)
    typealias DataResponseHandler = ((_ data:Data?, _ error: Error?) -> Void)
    var characteristicData: CBCharacteristic?
    var peripheral: CBPeripheral?
    var serviceHandler: ServicesHandler?
    var dataResponseHandler: DataResponseHandler?
    
    init(with device: CBPeripheral) {
        super.init()
        self.peripheral = device
    }
    
    func setNotify(to charecterstic: CBCharacteristic) {
        peripheral?.setNotifyValue(true, for: charecterstic)
    }
    
    func clearNotify(to charecterstic: CBCharacteristic) {
        peripheral?.setNotifyValue(false, for: charecterstic)
    }
    func setDelegate() {
        return
//        self.peripheral?.delegate = nil
//        self.peripheral?.delegate = self
    }
    func unSubscribeAll()  {
        guard peripheral?.services != nil else { return  }
        for service in peripheral!.services! {
            guard service.characteristics != nil else { continue }
            for characteristic in service.characteristics! {
                peripheral?.setNotifyValue(false, for: characteristic)
            }
        }
    }
    func discoverServices(with completion:@escaping ServicesHandler) {
        self.serviceHandler = completion
//        peripheral!.delegate = nil
        debugPrint(peripheral?.delegate ?? "Invalid")
        peripheral!.delegate = self
        debugPrint(peripheral?.delegate ?? "invalid")
        peripheral!.discoverServices(nil)
    }
    
    func sendData(data: Data, charecterStic: CBCharacteristic?, completion:DataResponseHandler?) {
        self.dataResponseHandler = completion
        guard let character = charecterStic else {
            self.peripheral?.writeValue(data, for: characteristicData!, type: .withResponse)
            return
        }
        self.peripheral?.writeValue(data, for: character, type: .withResponse)
    }
    
    deinit {
        debugPrint("deaalloc called")
    }
}


extension Device: CBPeripheralDelegate {
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        //
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        //
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        self.serviceHandler?(services)
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let serviceCharacteristics = service.characteristics else { return }
        
        for characteristics in serviceCharacteristics {
            if characteristics.properties == .notify {
                peripheral.setNotifyValue(true, for: characteristics)
            } else if characteristics.properties == .read {
                peripheral.readValue(for: characteristics)
            } else if characteristics.properties.contains([.write, .writeWithoutResponse]) {
                characteristicData = characteristics
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        //
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        //
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard error == nil else {
            self.dataResponseHandler?(nil, error)
            return
        }
        self.dataResponseHandler?(characteristic.value, nil)
    }
}
