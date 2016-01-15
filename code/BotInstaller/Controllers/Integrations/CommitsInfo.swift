//
//  CommitInfo.swift
//  BotInstaller
//
//  Created by Steven on 16/1/5.
//  Copyright © 2016年 Neva. All rights reserved.
//

import ObjectMapper

class CommitInfo: BaseInfo {
    
    var message = ""
    
    var detail = ""
    
    override func mapping(map: Map) {
        super.mapping(map)
        
        message <- map["XCSCommitMessage"]
        
        let strings = message.split("\n")

        for var i = 0; i < strings.count; i++ {
            let s = strings[i]
            switch i {
            case 0:
                message = s
            case 1:
                detail += s
            default:
                detail += "\n" + s
            }
        }
    }

}
