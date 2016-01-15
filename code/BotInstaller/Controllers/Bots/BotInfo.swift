//
//  BotInfo.swift
//  BotInstaller
//
//  Created by Steven on 15/12/16.
//  Copyright © 2015年 Neva. All rights reserved.
//

import ObjectMapper

class BotInfo: BaseInfo {

    var name: String?   // 构建名
    var integration_counter: Int? // 构建版本
    var configuration: BotConfiguration? // 配置信息
    
    required init?(_ map: Map){
        super.init(map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map)
        name                <- map["name"]
        integration_counter <- map["integration_counter"]
        configuration       <- map["configuration"]
    }
}

class BotConfiguration: BaseInfo {
    
    // 是否存在归档
    var exportsProductFromArchive: Bool
    
    required init?(_ map: Map){
        exportsProductFromArchive = false
        super.init(map)
    }
    
    override func mapping(map: Map) {
        exportsProductFromArchive <- map["exportsProductFromArchive"]
    }
}
