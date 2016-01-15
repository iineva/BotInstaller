//
//  IntegrationInfo.swift
//  BotInstaller
//
//  Created by Steven on 15/12/16.
//  Copyright © 2015年 Neva. All rights reserved.
//

import ObjectMapper

class IntegrationInfo: BaseInfo {
    
    var size: Int              // 大小
    var minVersion: String?    // 最低支持版本
    var startedTime: NSDate    // 构建开始时间
    var endedTime: NSDate      // 构建结束时间
    var ipaPath: String?       // 安装URL
    var appInfo: IntegrationAppInfo? // APP信息
    var remoteRepositoryKey: String? // 远程仓库key
    
    required init?(_ map: Map) {
        size = 0
        startedTime = NSDate(timeIntervalSince1970: 0)
        endedTime = NSDate(timeIntervalSince1970: 0)
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        size        <- map["assets.product.size"]
        minVersion  <- map["assets.product.MinimumOSVersion"]
        startedTime <- (map["startedTime"], BaseDateTransform)
        endedTime   <- (map["endedTime"], BaseDateTransform)
        ipaPath     <- map["assets.product.relativePath"]
        appInfo     <- map["assets.product.infoDictionary"]
        remoteRepositoryKey <- map["bot.configuration.sourceControlBlueprint.DVTSourceControlWorkspaceBlueprintPrimaryRemoteRepositoryKey"]
    }
    
    var ipaURL: NSURL? {
        return BotAPI.assets(ipaPath ?? "")
    }
    
    var sizeString: String {
        var s   : String
        let k   : Double = 1024.0;
        let size: Double = Double(self.size ?? 0)
        var l   : Double = size
        
        if size < k {
            s = "bytes";
        } else if size >= k && size <= k * k {
            l = size / k;
            s = "KB";
        } else if size >= k * k && size <= k * k * k {
            l = size / k / k;
            s = "MB";
        } else {
            l = size / k / k / k;
            s = "GB";
        }
        return "\(String(format: "%.1f", l))\(s)"
    }
    
}

// APP信息
class IntegrationAppInfo: BaseInfo {
    var name: String          // APP名字
    var identifier: String    // APP标识符
    var version: String       // 版本号
    var build: String         // build版本号
    
    required init?(_ map: Map) {
        version     = "-"
        build       = "-"
        name        = "-"
        identifier  = "-"
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        build       <- map["CFBundleVersion"]
        identifier  <- map["CFBundleIdentifier"]
        version     <- map["CFBundleShortVersionString"]
        name        <- map["CFBundleDisplayName"]
    }
}
