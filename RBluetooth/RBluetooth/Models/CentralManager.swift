//
//  CentralManager.swift
//  XcubeBluetooth
//
//  Created by Ramkumar Chintala on 17/03/23.
//  Copyright © 2023 Ramkumar Chintala. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol CentralManagerDelegate: NSObjectProtocol {
    func didDeviceDisconnected()
    @available(iOS 10.0, *)
    func didUpdateBluetoothState(state:CBManagerState)
}

class CentralManger: NSObject {
    // MARK: Type Aliases
    
    public typealias ScanCompletionHandler = ((_ result: [CBPeripheral]?, _ error: Error?) -> Void)
    public typealias ScanProgressHandler = ((_ newDiscoveries: [CBPeripheral]) -> Void)
    public typealias ConnectionHandler = ((_ device:Device,_ status:Bool) -> Void)
    
    // MARK: - Initialization
    fileprivate var centralManager: CBCentralManager?
     private var discoveries = [CBPeripheral]()
    var device: Device?

    static let shared = CentralManger()
    private override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    private var scanHandlers: (progressHandler: ScanProgressHandler?, completionHandler: ScanCompletionHandler? )?
    private var connectionHadler: ConnectionHandler?
    weak var delegate: CentralManagerDelegate?
    
    
    // MARK : METHODS
    func startScan(with services:[CBUUID]? = nil,  progressHandler: ScanProgressHandler? = nil, completionHandler: ScanCompletionHandler?)  {
        self.discoveries.removeAll()
        self.scanHandlers = ( progressHandler: progressHandler, completionHandler: completionHandler)
        if !(centralManager?.isScanning)! {
        self.centralManager?.scanForPeripherals(withServices: services, options: nil)
        }
    }
    
    func stopScan() {
        centralManager?.stopScan()
        scanHandlers = nil
        self.discoveries.removeAll()
    }
    
    func connectToCentral(with device:CBPeripheral, completion: @escaping ConnectionHandler) {
        self.centralManager?.connect(device, options: nil)
        self.connectionHadler = completion
    }
}

extension CentralManger: CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        device = Device(with: peripheral)
        self.connectionHadler?(device!, true)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff: break
        case .unsupported: break
        case .poweredOn: break
        default: return
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        let device = Device(with: peripheral)
        self.connectionHadler?(device, false)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveries.contains(peripheral) {
            discoveries.append(peripheral)
            scanHandlers?.progressHandler?(discoveries)
        }
    }
    
    
}
