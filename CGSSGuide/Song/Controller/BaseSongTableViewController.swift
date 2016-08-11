//
//  BaseSongTableViewController.swift
//  CGSSGuide
//
//  Created by zzk on 16/8/7.
//  Copyright © 2016年 zzk. All rights reserved.
//

import UIKit
protocol BaseSongTableViewControllerDelegate :class {
    func selectSong(live:CGSSLive, beatmaps:[CGSSBeatmap], diff:Int)
}
class BaseSongTableViewController: RefreshableTableViewController {
    weak var delegate: BaseSongTableViewControllerDelegate?
    var liveList:[CGSSLive]!
    var sorter:CGSSSorter!
    var searchBar:UISearchBar!
    func check(mask:UInt) {
        let updater = CGSSUpdater.defaultUpdater
        if updater.isUpdating {
            refresher.endRefreshing()
            return
        }
        self.updateStatusView.setContent("检查更新中", hasProgress: false)
        updater.checkUpdate(mask, complete: { (items, errors) in
            if !errors.isEmpty {
                self.updateStatusView.hidden = true
                let alert = UIAlertController.init(title: "检查更新失败", message: errors.joinWithSeparator("\n"), preferredStyle: .Alert)
                alert.addAction(UIAlertAction.init(title: "确定", style: .Default, handler: nil))
                self.tabBarController?.presentViewController(alert, animated: true, completion: nil)
            } else {
                if items.count == 0 {
                    self.updateStatusView.setContent("数据是最新版本", hasProgress: false)
                    self.updateStatusView.activityIndicator.stopAnimating()
                    UIView.animateWithDuration(2.5, animations: {
                        self.updateStatusView.alpha = 0
                        }, completion: { (b) in
                            self.updateStatusView.hidden = true
                            self.updateStatusView.alpha = 1
                    })
                    return
                }
                self.updateStatusView.setContent("更新数据中", hasProgress: true)
                updater.updateItems(items, progress: { (process, total) in
                    self.updateStatusView.updateProgress(process, b: total)
                    }, complete: { (success, total) in
                        let alert = UIAlertController.init(title: "更新完成", message: "成功\(success),失败\(total-success)", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction.init(title: "确定", style: .Default, handler: nil))
                        self.tabBarController?.presentViewController(alert, animated: true, completion: nil)
                        self.updateStatusView.hidden = true
                        updater.setVersionToNewest()
                        self.refresh()
                })
                
            }
        })
        refresher.endRefreshing()
    }
    
    //根据设定的筛选和排序方法重新展现数据
    func refresh() {
        let dao = CGSSDAO.sharedDAO
        liveList = Array(dao.validLiveDict.values)
        if searchBar.text != "" {
            liveList = dao.getLiveListByName(liveList, string: searchBar.text!)
        }
        dao.sortListByAttibuteName(&liveList!, sorter: sorter)
        tableView.reloadData()
    }
    func cancelAction() {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        refresh()
    }
    
    //    func filterAction() {
    //        let sb = self.storyboard!
    //        let filterVC = sb.instantiateViewControllerWithIdentifier("SongFilterTable") as! SongFilterTable
    //        filterVC.filter = self.filter
    //        //navigationController?.pushViewController(filterVC, animated: true)
    //
    //
    //        //使用自定义动画效果
    //        let transition = CATransition()
    //        transition.duration = 0.3
    //        transition.type = kCATransitionFade
    //        navigationController?.view.layer.addAnimation(transition, forKey: kCATransition)
    //        navigationController?.pushViewController(filterVC, animated: false)
    //
    //    }
    
    override func refresherValueChanged() {
        super.refresherValueChanged()
        check(0b11100)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dao = CGSSDAO.sharedDAO
        liveList = Array(dao.validLiveDict.values)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //初始化导航栏的搜索条
        searchBar = UISearchBar()
        self.navigationItem.titleView = searchBar
        searchBar.returnKeyType = .Done
        //searchBar.showsCancelButton = true
        searchBar.placeholder = "歌曲名"
        searchBar.autocapitalizationType = .None
        searchBar.autocorrectionType = .No
        searchBar.delegate = self
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "889-sort-descending-toolbar"), style: .Plain, target: self, action: #selector(filterAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .Stop, target: self, action: #selector(cancelAction))
        self.tableView.registerClass(SongTableViewCell.self, forCellReuseIdentifier: "SongCell")
        self.tableView.rowHeight = 86
        sorter = CGSSSorter.init(att: "updateId")
        dao.sortListByAttibuteName(&liveList!, sorter: sorter)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return liveList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as! SongTableViewCell
        
        cell.initWith(liveList[indexPath.row])
        cell.delegate = self
        // Configure the cell...
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let live = liveList[indexPath.row]
        let maxDiff = (live.masterPlus == 0) ? 4 : 5
        if let beatmaps = checkBeatmapData(live) {
            selectLive(live, beatmaps: beatmaps, diff: maxDiff)
        }
    }
    
    //此方法应该被override或者通过代理来响应
    func selectLive(live:CGSSLive, beatmaps:[CGSSBeatmap], diff:Int) {
        searchBar.resignFirstResponder()
        delegate?.selectSong(live, beatmaps: beatmaps, diff: diff)
    }
    
    func checkBeatmapData(live:CGSSLive) -> [CGSSBeatmap]? {
        var beatmaps = [CGSSBeatmap]()
        let maxDiff = (live.masterPlus == 0) ? 4 : 5
        let dao = CGSSDAO.sharedDAO
        for i in 1...maxDiff {
            if let beatmap = dao.findBeatmapById(live.id!, diffId: i) {
                beatmaps.append(beatmap)
            } else {
                let alert = UIAlertController.init(title: "数据缺失", message: "缺少难度为\(CGSSTool.diffStringFromInt(i))的歌曲,建议等待当前更新完成,或尝试下拉歌曲列表手动更新数据", preferredStyle: .Alert)
                alert.addAction(UIAlertAction.init(title: "确定", style: .Default, handler: nil))
                self.navigationController?.presentViewController(alert, animated: true, completion: nil)
                return nil
            }
        }
        return beatmaps
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//MARK: SongTableViewCell的协议方法
//MARK: SongTableViewCell的协议方法
extension BaseSongTableViewController: SongTableViewCellDelegate {
    func diffSelected(live: CGSSLive, diff: Int) {
        if let beatmaps = checkBeatmapData(live) {
            selectLive(live, beatmaps: beatmaps, diff: diff)
        }
    }
}

//MARK: searchBar的协议方法
extension BaseSongTableViewController : UISearchBarDelegate {
    
    //文字改变时
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        refresh()
    }
    //开始编辑时
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        
        return true
    }
    //点击搜索按钮时
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    //点击searchbar自带的取消按钮时
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        refresh()
    }
}

//MARK: scrollView的协议方法
extension BaseSongTableViewController {
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //向下滑动时取消输入框的第一响应者
        searchBar.resignFirstResponder()
    }
}

