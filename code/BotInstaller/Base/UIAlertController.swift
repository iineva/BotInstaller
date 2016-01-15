//
//  UIAlertController.swift
//  BotInstaller
//
//  Created by Steven on 16/1/5.
//  Copyright © 2016年 Neva. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func show(
        viewController: UIViewController,
        title: String? = nil,
        message: String? = nil,
        cancel: (title: String?, block: ((UIAlertAction) -> Void)?)? = nil,
        buttons: [(title: String?, block: ((UIAlertAction) -> Void)?)]? = nil
    ) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        if let cancel = cancel {
            alert.addAction(UIAlertAction(title: cancel.title, style: .Cancel, handler: cancel.block))
        }
        
        if let buttons = buttons {
            for b in buttons {
                alert.addAction(UIAlertAction(title: b.title, style: .Default, handler: b.block))
            }
        }
        
        viewController.presentViewController(alert, animated: true, completion: nil)
        
        return alert
    }
}

extension UIViewController {
    
    func showAlertController (
        title title: String? = nil,
        message: String? = nil,
        cancel: (title: String?, block: ((UIAlertAction) -> Void)?)? = nil,
        buttons: [(title: String?, block: ((UIAlertAction) -> Void)?)]? = nil
    ) -> UIAlertController {
        return UIAlertController.show(self, title: title, message: message, cancel: cancel, buttons: buttons)
    }
    
}