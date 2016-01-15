//
//  IntegrationsDetailController.swift
//  BotInstaller
//
//  Created by Steven on 15/12/28.
//  Copyright © 2015年 Neva. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import ObjectMapper
import UITableView_FDTemplateLayoutCell

class IntegrationsDetailController: UITableViewController {
    
    var integrationInfo: IntegrationInfo?
    
    var dataItems = [CommitInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
        refresh()
    }
    
    func refresh() {
        
        if let refreshControl = refreshControl where refreshControl.refreshing == false {
            refreshControl.beginRefreshing()
        }
        
        if let id = integrationInfo?.id, let remoteKey = integrationInfo?.remoteRepositoryKey {
            // 发起请求
            request(.GET, BotAPI.commits(id))
                .responseJSON {
                    [weak self] (response: Response<AnyObject, NSError>) -> Void in
                    
                    // 解析commits
                    dispatch_async(dispatch_get_global_queue(0, 0), { () -> Void in

                        if
                            let value = response.result.value as? [String: AnyObject],
                            let results = value["results"] as? [[String: AnyObject]] where results.count > 0,
                            let data = results[0]["commits"]?[remoteKey] as? [[String: AnyObject]] {
                                
                                let commits = Mapper<CommitInfo>().mapArray(data) ?? [CommitInfo]()
                                
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self?.dataItems.removeAll()
                                    self?.dataItems.appendContentsOf(commits)
                                    self?.refreshControl?.endRefreshing()
                                    self?.tableView.reloadData()
                                })
                                
                        }
                    })
            }
        }

    }
    
    @IBAction func onInstallTouch(sender: AnyObject) {

        if let ipaURL = integrationInfo?.ipaURL {
            SSAppInstaller.sharedInstance.installAPP(ipaURL, progress: {
                progress in
                SVProgressHUD.showProgress(progress)
                SVProgressHUD.showProgress(progress, status: String(format: "下载中%.1f%%", progress*100))
                if progress == 1.0 {
                    SVProgressHUD.dismiss()
                } else if progress == -1 {
                    SVProgressHUD.showErrorWithStatus("❌下载失败")
                }
            })
        } else {
            SVProgressHUD.showErrorWithStatus("❌打包失败")
        }
    }
    
    func setup() {
        refreshControl?.addTarget(self, action: Selector("refresh"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataItems.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "更新内容"
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.fd_heightForCellWithIdentifier("cell", cacheByIndexPath: indexPath, configuration: {
            [weak self](cell) -> Void in
            self?.setCell(cell, indexPath: indexPath)
        })
    }
    
    func setCell(cell: AnyObject?, indexPath:NSIndexPath) {
        let info = dataItems[indexPath.row]
        if let cell = cell as? CommitCell {
            cell.titleLab.text = info.message ?? "-"
            cell.subtitleLab.text = info.detail
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        setCell(cell, indexPath: indexPath)
        return cell
    }
    

}
