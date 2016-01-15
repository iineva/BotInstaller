//
//  IntegrationsViewController.swift
//  BotInstaller
//
//  Created by Steven on 15/12/16.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit
import Alamofire
import NSObjectExtend

class IntegrationsViewController: UITableViewController {
    
    var botInfo: BotInfo?
    var dataItems = [IntegrationInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
        refresh()
    }
    
    func setup() {
        
        title = botInfo?.name
        
        refreshControl?.addTarget(self, action: Selector("refresh"), forControlEvents: UIControlEvents.ValueChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("refresh"), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func refresh() {
        
        if let refreshControl = refreshControl where refreshControl.refreshing == false {
            refreshControl.beginRefreshing()
        }
        
        if let id = botInfo?.id {
            // 发起请求
            request(.GET, BotAPI.integrations(id))
                .responseArray("results", completionHandler: {
                    [weak self] (response: Response<[IntegrationInfo], NSError>) -> Void in
                    
                    self?.dataItems.removeAll()
                    if let value = response.result.value {
                        self?.dataItems.appendContentsOf(value.filter({ (info) -> Bool in
                            // 过滤失败的构建
                            return info.appInfo != nil
                        }))
                    }
                    self?.refreshControl?.endRefreshing()
                    self?.tableView.reloadData()
                })
                .responseJSON { (response: Response<AnyObject, NSError>) -> Void in
                    // 输出Json
                    // print(response)
                }
        }
        
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let info = dataItems[indexPath.row]
        if let appInfo = info.appInfo {
            cell.textLabel?.text = "\(appInfo.version)(\(appInfo.build))"
            cell.detailTextLabel?.text = info.endedTime.toChatString()
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("push", sender: dataItems[indexPath.row])
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if
            let info = sender as? IntegrationInfo,
            let vc = segue.destinationViewController as? IntegrationsDetailController {
            vc.integrationInfo = info
        }
    }

}
