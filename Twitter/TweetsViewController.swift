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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "profileDetailSegue:", name: "profileDetailNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "replySegue:", name: "replyNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTweets:", name: "newTweet", object: nil)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "twitterlogo")
        imageView.image = image
        self.navigationItem.titleView = imageView
    }
    
    //tableView methods
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
    
    //refresh control and infinite scroll methods
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
    
    func updateTweets(notification: NSNotification) {
        let newTweet = notification.userInfo!["new_tweet"] as! Tweet
        tweets?.insert(newTweet, atIndex: 0)
        tableView.reloadData()
    }
    
    //segue methods
    func profileDetailSegue(notification: NSNotification) {
        performSegueWithIdentifier("profileSegue", sender: notification.userInfo!["user"])
    }
    
    func replySegue(notification: NSNotification) {
        performSegueWithIdentifier("tweetSegue", sender: notification.userInfo!["reply_tweet"])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let tweet = tweets![indexPath!.row]
            let tweetDetailViewController = segue.destinationViewController as! DetailsViewController
            print("details")
            tweetDetailViewController.tweet = tweet
        } else if segue.identifier == "profileSegue" {
            let user = sender as! User
            print(user.screenname)
            let profileDetailViewController = segue.destinationViewController as! ProfileViewController
            profileDetailViewController.user = user
        } else if segue.identifier == "tweetSegue" {
            if let replyTweet = sender as? Tweet {
                let composeViewController = segue.destinationViewController as! NewTweetViewController
                composeViewController.reply = replyTweet
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //logout
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    

}
