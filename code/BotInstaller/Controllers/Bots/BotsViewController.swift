//
//  BotsViewController.swift
//  BotInstaller
//
//  Created by Steven on 15/12/16.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit
import Alamofire

class BotsViewController: UITableViewController {
    
    var dataItems = [BotInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        refresh()
    }
        
    func setup() {

        // 信任不安全的证书
        Alamofire.configureAlamofireManager()
        
        refreshControl?.addTarget(self, action: Selector("refresh"), forControlEvents: UIControlEvents.ValueChanged)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("refresh"), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func onInfoButtonTouch(sender: UIButton) {
        showAlertController(
            title: UIDevice.ss_appVersion() + "_" + UIDevice.ss_appBuildVersion(),
            cancel: (title: "确定", block: nil)
        )
    }
    
    func refresh() {
        
        if let refreshControl = refreshControl where refreshControl.refreshing == false {
            refreshControl.beginRefreshing()
        }
        
        // 发起请求
        request(.GET, BotAPI.bots).responseArray("results", completionHandler: {
            [weak self] (response: Response<[BotInfo], NSError>) -> Void in
            
            self?.dataItems.removeAll()
            if let value = response.result.value {
                self?.dataItems.appendContentsOf(value.sort({ (left, right) -> Bool in
                    // 按照文件名排序
                    return left.name > right.name
                }))
            }
            self?.refreshControl?.endRefreshing()
            self?.tableView.reloadData()
        })
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataItems.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let info = dataItems[indexPath.row]
        
        cell.textLabel?.text = info.name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("push", sender: dataItems[indexPath.row])
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if
            let info = sender as? BotInfo,
            let vc = segue.destinationViewController as? IntegrationsViewController {
            vc.botInfo = info
        }
    }

}
