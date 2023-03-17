//
//  Extensions.swift
//  XcubeBluetooth
//
//  Created by Ramkumar Chintala on 17/03/23.
//  Copyright © 2023 Ramkumar Chintala. All rights reserved.
//

import Foundation
import UIKit

/*##########################################################################################
 // MARK: Data Extension
 #########################################################################################*/

extension Data {
    
    /// Create hexadecimal string representation of NSData object.
    /// - returns: String representation of this NSData object.
    var hexadecimalString: String {
        get {
            return map { String(format: "%02hhx", $0) }.joined()
        }
    }
}

/*##########################################################################################
 // MARK: String Extensions
 #########################################################################################*/

extension String {
    
    /// Create NSData from hexadecimal string representation
    /// This takes a hexadecimal representation and creates a NSData object. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    /// The use of `strtoul` inspired by Martin R at [http://stackoverflow.com/a/26284562/1271826](http://stackoverflow.com/a/26284562/1271826)
    ///
    /// - returns: NSData represented by this hexadecimal string.
    
    var dataFromHexString:Data {
        get {
            let data = NSMutableData(capacity: characters.count / 2)
            
            let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
            regex.enumerateMatches(in: self, options: [], range: NSMakeRange(0, characters.count)) {
                match, flags, stop in
                let byteString = (self as NSString).substring(with: match!.range)
                let num = UInt8(byteString.withCString {
                    strtoul($0, nil, 16)
                })
                data?.append([num], length: 1)
            }
            return (data as Data?)!
        }
    }
    /// this is converted value to hexa String.
    /// this is not generic
    var hexToBinary:String {
        get {
            let num2 = Int(self, radix: 16)
            var str: String = String(num2!, radix: 2)
            while (str.characters.count < 16) {
                str = "0" + str
            }
            return str
        }
    }
    /// this is converted hexa binary to Bool Araay.
    /// this is not generic
    
    /// giving class name as String
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
}

/*##########################################################################################
 // MARK: Viewcontroller Extension
 #########################################################################################*/
extension UIViewController {
    class var storyboardID: String {
        return "\(self)"
    }
    static func instantiate(fromStoryboard storyboard: AppStoryboard) -> Self {
        return storyboard.viewController(viewControllerClass: self)
    }
    
    func disableMultiTouch() {
        self.disable2ButtonTouchAtSameTimer(on: self.view)
    }
    
    private func disable2ButtonTouchAtSameTimer(on view: UIView) {
        for subView in view.subviews {
            self.disable2ButtonTouchAtSameTimer(on: subView)
        }
        view.isExclusiveTouch = true
    }
}


/*##########################################################################################
 // MARK: StoryBoard Extension
 #########################################################################################*/

enum AppStoryboard: String {
    case Main, Main_iPhone
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T: UIViewController>(viewControllerClass: T.Type) -> T {
        let storyboardID = viewControllerClass.storyboardID
        return instance.instantiateViewController(withIdentifier: storyboardID) as! T
    }
}


