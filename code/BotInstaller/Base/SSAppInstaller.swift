//
//  SSAppInstaller.swift
//  BotInstaller
//
//  Created by Steven on 15/10/26.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit
import Alamofire
import zipzap
import Swifter

class SSAppInstaller {
    
    // 安装时默认预览图
    static let defaultPlaceholder = "http://iosinstall.sinaapp.com/plist/ios-install.png"
    
    // 缓存目录
    static let tempDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
    
    // 单例
    static let sharedInstance = SSAppInstaller()
    
    let webServer: HttpServer
    
    init() {
        webServer = HttpServer()
        webServer["/:path"] = HttpHandlers.directory(SSAppInstaller.tempDirectory.path!)
        do {
            try webServer.start(9527)
        } catch {
            
        }
    }
    
    /**
    安装App
    
    - parameter title:       App标题
    - parameter ipa:         ipa的URL
    - parameter version:     版本号
    - parameter identifier:  Bundle Identifier
    - parameter placeholder: 预览图
    */
    class func installApp(title: String, ipa: String, version: String, identifier: String, placeholder: String = defaultPlaceholder) {
        
        let dic = ["title": title, "ipa": ipa, "version": version, "ident": identifier, "icon": placeholder]
        let jsonString = try? NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted)
        
        print("安装信息: ", dic)
        
        guard let json = jsonString else {
            // TODO 提示错误
            return
        }
        
        
        let base64Data = json.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
        let base64String = String(data: base64Data, encoding: NSUTF8StringEncoding)?.stringByReplacingOccurrencesOfString("=", withString: "") // 清除后面的等号
        
        let fileName = base64String!.hash
        let s = 128.0; // 128个字符分隔一次
        let count = Int( ceil( Double(base64String!.characters.count) / s) );
        var path = "";
        // 新浪对URL文件名长度有限制，切分文件名
        for (var i = 0; i < count; i++) {
            var l = Int(s);
            if (i == count - 1) {
                l = base64String!.characters.count - i * Int(s);
            }
            let start = base64String!.startIndex.advancedBy(i*Int(s))
            let end = start.advancedBy(l)
            
            path += (i != 0 ? "/" : "") + base64String!.substringWithRange(Range(start: start, end: end))
        }
        
        // 通过新浪的PHP服务器提供HTTPS服务，将参数封装在URL里面，PHP服务器读取URL中的APP信息，自动生成plist文件
        let plist = "https://iosinstall.sinaapp.com/plist/\(path)/\(fileName).plist";
        self.installApp(plist)
    }
    
    
    func installAPP(ipa: NSURL, progress:((Float) -> Void)? = nil) {
        
        // 获取下载保存路径
        let fileName = String(ipa.hash) + ".ipa"
        let saveURL = SSAppInstaller.tempDirectory.URLByAppendingPathComponent(fileName)
        
        // 启动安装
        let startInstall = { () -> Void in
            if let plist = self.readIPAInfo(saveURL) {
                let displayName = (plist["CFBundleDisplayName"] as? String) ?? saveURL.URLByDeletingPathExtension?.lastPathComponent ?? "_"
                if let
                    ident = plist["CFBundleIdentifier"] as? String,
                    version = plist["CFBundleShortVersionString"] as? String,
                    build = plist["CFBundleVersion"] as? String,
                    path = saveURL.lastPathComponent
                {
                    let url = "http://127.0.0.1:9527/\(path)"
                    SSAppInstaller.installApp("\(displayName)(\(version),\(build))", ipa: url, version: version, identifier: ident)
                } else {
                    print("解析Info.plist失败!!")
                }
            }
        }
        
        if let path = saveURL.path where NSFileManager.defaultManager().fileExistsAtPath(path) {
            // 已经下载则不再下载，直接安装
            startInstall()
        } else {
            // 未下载，下载ipa包
            download(.GET, ipa, destination: { temporaryURL, response -> NSURL in
                return saveURL
            })
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                dispatch_async(dispatch_get_main_queue()) {
                    progress?( Float(totalBytesRead)/Float(totalBytesExpectedToRead) )
                }
            }
            .response { _, _, _, error in
                if let error = error {
                    print("Failed with error: \(error)")
                    progress?( Float(-1) )
                } else {
                    print("Downloaded file successfully")
                    progress?( Float(1.0) )
                    startInstall()
                }
            }
        }
    }
    
    // 读取ipa文件信息
    // TODO 解析AppIcon
    func readIPAInfo(ipa: NSURL) -> [String: AnyObject]? {
        do {
            let archive = try ZZArchive(URL: ipa)
            let predicate = NSPredicate(format: "SELF MATCHES %@", "^Payload/(.*)\\.app/Info\\.plist") // 正则索引Info.plist
            for e in archive.entries {
                if predicate.evaluateWithObject(e.fileName) {
                    let data = try e.newData()
                    var format = CFPropertyListFormat.XMLFormat_v1_0
                    let plist = CFPropertyListCreateWithData(kCFAllocatorDefault, data as CFData, CFPropertyListMutabilityOptions.Immutable.rawValue, &format, nil)
                    if let plist = plist.takeRetainedValue() as? [String: AnyObject] {
                        return plist;
                    }
                }
            }
        } catch {
            // do nothing.
        }
        return nil
    }
    
    
    /**
    安装App
    
    - parameter plist: plist配置信息的URL
    */
    class func installApp(plist: String) {
        if let url = NSURL(string: "itms-services://?action=download-manifest&url=\(plist)") {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
                return
            } else {
                // TODO
                print("不能打开安装链接")
            }
        } else {
            // TODO
            print("安装连接错误")
        }
    }
}