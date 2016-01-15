//
//  NSDate.swift
//  BotInstaller
//
//  Created by Steven on 15/12/16.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit

extension NSDate {
    
    func string(format: String) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
}

extension String {
    
    func date(format: String) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.dateFromString(self)
    }
    
}
