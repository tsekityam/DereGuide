//
//  CharInfoViewController.swift
//  CGSSGuide
//
//  Created by zzk on 16/8/18.
//  Copyright © 2016年 zzk. All rights reserved.
//

import UIKit
import ZKDrawerController

class CharInfoViewController: BaseTableViewController, CharFilterSortControllerDelegate, ZKDrawerControllerDelegate {
    
    var charList: [CGSSChar]!
    var searchBar: UISearchBar!
    var filter: CGSSCharFilter {
        return CGSSSorterFilterManager.default.charFilter
    }
    var sorter: CGSSSorter {
        return CGSSSorterFilterManager.default.charSorter
    }
    
    var filterVC: CharFilterSortController!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化导航栏的搜索条
        searchBar = UISearchBar()
        // 为了避免push/pop时闪烁,searchBar的背景图设置为透明的
        for sub in searchBar.subviews.first!.subviews {
            if let iv = sub as? UIImageView {
                iv.alpha = 0
            }
        }
        self.navigationItem.titleView = searchBar
        searchBar.returnKeyType = .done
        // searchBar.showsCancelButton = true
        searchBar.placeholder = NSLocalizedString("日文名/罗马音/CV", comment: "角色信息页面")
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.delegate = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "889-sort-descending-toolbar"), style: .plain, target: self, action: #selector(filterAction))
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .stop, target: self, action: #selector(cancelAction))
//        
        self.tableView.register(CharInfoTableViewCell.self, forCellReuseIdentifier: "CharCell")
        let backItem = UIBarButtonItem.init(image: UIImage.init(named: "765-arrow-left-toolbar"), style: .plain, target: self, action: #selector(backAction))
        
        navigationItem.leftBarButtonItem = backItem
        
        filterVC = CharFilterSortController()
        filterVC.filter = self.filter
        filterVC.sorter = self.sorter
        filterVC.delegate = self
    }
    
    func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // 根据设定的筛选和排序方法重新展现数据
    func refresh() {
        let dao = CGSSDAO.sharedDAO
        self.charList = dao.getCharListByFilter(filter)
        if searchBar.text != "" {
            self.charList = dao.getCharListByName(charList, string: searchBar.text!)
        }
        dao.sortListInPlace(&charList!, sorter: sorter)
        tableView.reloadData()
        // 滑至tableView的顶部 暂时不需要
        // tableView.scrollToRowAtIndexPath(IndexPath.init(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    
    func filterAction() {
        CGSSClient.shared.drawerController?.show(animated: true)
    }
    
    func cancelAction() {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // self.navigationController?.setToolbarHidden(false, animated: true)
        // 页面出现时根据设定刷新排序和搜索内容
        searchBar.resignFirstResponder()
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let drawer = CGSSClient.shared.drawerController
        drawer?.rightVC = filterVC
        drawer?.defaultRightWidth = Screen.width - 68
        drawer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CGSSClient.shared.drawerController?.rightVC = nil
        // self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func drawerController(_ drawerVC: ZKDrawerController, didHide vc: UIViewController) {
        
    }
    
    func drawerController(_ drawerVC: ZKDrawerController, willShow vc: UIViewController) {
        filterVC.filter = self.filter
        filterVC.sorter = self.sorter
        filterVC.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharCell", for: indexPath) as! CharInfoTableViewCell
        cell.setup(charList[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return charList?.count ?? 0
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        let CharDVC = CharDetailViewController()
        CharDVC.char = charList[indexPath.row]
        CharDVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(CharDVC, animated: true)
    }
    
    func doneAndReturn(filter: CGSSCharFilter, sorter: CGSSSorter) {
        CGSSSorterFilterManager.default.charFilter = filter
        CGSSSorterFilterManager.default.charSorter = sorter
        CGSSSorterFilterManager.default.saveForChar()
        self.refresh()
    }
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//MARK: searchBar的协议方法
extension CharInfoViewController: UISearchBarDelegate {
    
    // 文字改变时
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        refresh()
    }
    // 开始编辑时
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        return true
    }
    // 点击搜索按钮时
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    // 点击searchbar自带的取消按钮时
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        refresh()
    }
}

//MARK: scrollView的协议方法
extension CharInfoViewController {
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 向下滑动时取消输入框的第一响应者
        searchBar.resignFirstResponder()
    }
}
