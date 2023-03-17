//
//  ServiceListViewController.swift
//  XcubeBluetooth
//
//  Created by Ramkumar Chintala on 17/03/23.
//  Copyright © 2023 Ramkumar Chintala. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServiceListViewController: UIViewController, Alertable {

    @IBOutlet var tableView: UITableView!
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.blue
        return refreshControl
    }()
    var serviceList: [CBService] = [CBService]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addSubview(refreshControl)
        tableView.reloadData()
        navigationController?.navigationBar.backItem?.title = "back"
        navigationController?.title = "pull to refresh"
    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        CentralManger.shared.device?.discoverServices(with: { (services) in
            self.serviceList = services ?? self.serviceList
            self.tableView.reloadData()
        })
        refreshControl.endRefreshing()
    }
}

extension ServiceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let list = serviceList[indexPath.section].characteristics else {
            return
        }
        let char = list[indexPath.row]
        if char.properties.contains([.write, .writeWithoutResponse]) {
            showAlertWithTextField(title: "Command", message: "Please enter your Command", textFieldplaceHolder: "Command", textFieldText: nil, buttons: ["Cancel", "Send"], completion: { (button, text) in
                    self.dismiss(animated: false, completion: nil)
                    CentralManger.shared.device?.sendData(data: text.dataFromHexString, charecterStic: char, completion: { (data, error) in
                        if error == nil {
                            self.showAlert(message: "Response \(String(describing: data?.hexadecimalString))")
                        } else {
                           self.showAlert(message: "errror \(error?.localizedDescription)")
                        }
                    })
            })
        }
    }
    
}

extension ServiceListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return serviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ServicesCell") else { return UITableViewCell() }
        guard let list = serviceList[indexPath.section].characteristics else {
            return UITableViewCell()
        }
        
        let device = list[indexPath.row]
        var text = ""
        switch device.properties {
        case .read: text = "Read/"
        case .notify: text = "Notify"
        default:
            if device.properties.contains([.write, .writeWithoutResponse]) {
                text = "Write"
            } else{
                text = "Defalt"
            }
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(device.uuid) Proerties: \(text)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceList[section].characteristics?.count ?? 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let frame = CGRect(x: 25, y: 0, width: tableView.frame.size.width, height: 55)
        let label  = UILabel(frame: frame)
        let device = serviceList[section]
        label.text = device.uuid.uuidString
        label.font = UIFont.systemFont(ofSize: 24)
        view.frame = frame
        label.textColor = .blue
        label.backgroundColor = .lightGray
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}
