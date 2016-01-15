//
//  UIDevice.swift
//  BotInstaller
//
//  Created by Steven on 16/1/5.
//  Copyright © 2016年 Neva. All rights reserved.
//

import UIKit

extension UIDevice {
    
    class func ss_appVersion() -> String {
        return NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    class func ss_appBuildVersion() -> String {
        return NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String ?? ""
    }

    class func ss_appName() -> String {
        return NSBundle.mainBundle().infoDictionary?["CFBundleDisplayName"] as? String ?? ""
    }
}