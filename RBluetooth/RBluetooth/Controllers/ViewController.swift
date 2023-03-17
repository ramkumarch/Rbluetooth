//
//  ViewController.swift
//  XcubeBluetooth
//
//  Created by Ramkumar Chintala on 17/03/23.
//  Copyright © 2023 Ramkumar Chintala. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController {
    var deviceList: [CBPeripheral] = [CBPeripheral]()

    @IBOutlet var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.blue
        return refreshControl
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addSubview(refreshControl)
        // Do any additional setup after loading the view, typically from a nib.
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        deviceList.removeAll()
        CentralManger.shared.stopScan()
        CentralManger.shared.startScan(with: nil, progressHandler: { (peripherals) in
            self.deviceList = peripherals
            self.tableView.reloadData()
        }, completionHandler: nil)
        refreshControl.endRefreshing()
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CentralManger.shared.connectToCentral(with: deviceList[indexPath.row]) { (device, status) in
            if status {
                device.setDelegate()
                device.discoverServices(with: { (services) in
                    guard let list = services else { return }
                    let vc = ServiceListViewController.instantiate(fromStoryboard: .Main)
                    vc.serviceList = list
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            }
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") else { return UITableViewCell() }
        let device = deviceList[indexPath.row]
        cell.textLabel?.text = device.name ?? "nil"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
}

