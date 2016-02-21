//
//  TweetsViewController.swift
//  Twitter
//
//  Created by William Tong on 2/16/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TweetsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UIScrollViewDelegate {
    
    var tweets: [Tweet]?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets != nil {
            return tweets!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetIdentifier", forIndexPath: indexPath) as! TweetCell
        cell.tweet = tweets![indexPath.row]
        return cell
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: { (tweets, error) -> () in
            print("reloading data")
            self.tweets = tweets
            self.tableView.reloadData()
        })
        refreshControl.endRefreshing()
    }
    
    var isMoreDataLoading = false
    
    func loadMoreData() {
        if tweets != nil {
            let max_id = tweets![tweets!.count-1].id!
            TwitterClient.sharedInstance.homeTimelineUpdate(max_id, completion: { (var tweets, error) -> () in
                print("updating data")
                if tweets != nil {
                    tweets!.removeAtIndex(0)
                    self.tweets!.appendContentsOf(tweets!)
                    self.isMoreDataLoading = false
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - (2 * tableView.bounds.size.height)
            
            if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                loadMoreData()
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    

}
