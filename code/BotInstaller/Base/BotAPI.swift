//
//  BotParser.swift
//  BotInstaller
//
//  Created by Steven on 15/11/18.
//  Copyright © 2015年 Neva. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

class BaseInfo: Mappable {
    
    var id: String?
    
    required init?(_ map: Map) {
        
    }
    func mapping(map: Map) {
        id <- map["_id"]
    }
    
    let BaseDateTransform = TransformOf<NSDate, String>(fromJSON: { (value: String?) -> NSDate? in
        return value?.date("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    }, toJSON: { (value: NSDate?) -> String? in
        return value?.string("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
    })
    
}

public struct BotAPI {
    
    static let Host = "https://ios-server.local:20343"
    
    // bot 列表
    static let bots = Host + "/api/bots"
    
    // 获取集成列表
    static func integrations(id: String, last: Int = 1000) -> String {
        return Host + "/api/bots/\(id)/integrations?last=\(last)"
    }
    
    // 获取资源
    static func assets(path: String) -> NSURL? {
        return NSURL(string: "\(Host)/api/assets/")?.URLByAppendingPathComponent(path)
    }
    
    // 获取commits
    static func commits(id: String) -> String {
        return Host + "/api/integrations/\(id)/commits"
    }
}

class Alamofire {
    
    // 信任不安全的证书
    // TODO 只信任指定证书
    class func configureAlamofireManager() {
        let manager = Manager.sharedInstance
        manager.delegate.sessionDidReceiveChallenge = {
            session, challenge in
            var disposition: NSURLSessionAuthChallengeDisposition = .PerformDefaultHandling
            var credential: NSURLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = NSURLSessionAuthChallengeDisposition.UseCredential
                credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .CancelAuthenticationChallenge
                } else {
                    credential = manager.session.configuration.URLCredentialStorage?.defaultCredentialForProtectionSpace(challenge.protectionSpace)
                    
                    if credential != nil {
                        disposition = .UseCredential
                    }
                }
            }
            return (disposition, credential)
        }
    }
}