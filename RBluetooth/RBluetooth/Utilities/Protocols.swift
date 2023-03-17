//
//  Protocols.swift
//  XcubeBluetooth
//
//  Created by Ramkumar Chintala on 17/03/23.
//  Copyright © 2023 Ramkumar Chintala. All rights reserved.
//

import Foundation
import UIKit

protocol Reusable: class {}

extension Reusable where Self:UIView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

protocol NibLoadableView: class {}

extension NibLoadableView where Self: UIView {
    static var NibName: String {
        return String(describing: self)
    }
}

/*##########################################################################################
 // MARK: Alerts Methods
 #########################################################################################*/

protocol Alertable { }

extension Alertable where Self: UIViewController {
    
    func showAlert(title: String = "APP NAME", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String, cancelButton: String = "Cancel", and otherButtons: [String], completion: ((_ buttonPressed: String) -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: cancelButton, style: .cancel, handler: nil)
        for buttonTitle in otherButtons {
            alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { (action: UIAlertAction) -> Void in
                completion?(action.title!)
            }))
        }
        alertController.addAction(cancelButton)
        if self.presentedViewController is UIAlertController {
            self.dismiss(animated: false, completion: {
                self.present(alertController, animated: true, completion: nil)
            })
        } else {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlertWithTextField(title: String?, message: String?, textFieldplaceHolder:String?, textFieldText:String?, buttons: [String], completion: ((_ buttonPressed: String, _ textFieldText:String) -> Void)?) {
        UIApplication.shared.endIgnoringInteractionEvents()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.isEnabled = false
                textField.placeholder = textFieldplaceHolder
                textField.keyboardType = .asciiCapable
                textField.autocapitalizationType = .words
                textField.text = textFieldText
                textField.keyboardType = UIKeyboardType.asciiCapable
                textField.delegate = self as? UITextFieldDelegate
        })
        for buttonTitle in buttons {
            alertController.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: { (button: UIAlertAction) -> Void in
                alertController.view.endEditing(true)
                if let textFields = alertController.textFields {
                    let theTextFields = textFields as [UITextField]
                    let enteredText = theTextFields[0].text
                    completion!(button.title!, enteredText!)
                }
            }))
        }
        self.present(alertController, animated: false, completion: {
            alertController.textFields?.first?.isEnabled = true
        })
    }
}
