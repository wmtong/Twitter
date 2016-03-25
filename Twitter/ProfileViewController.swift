//
//  ProfileViewController.swift
//  Twitter
//
//  Created by William Tong on 2/23/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user: User!
    var tweets: [Tweet]?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var header: UIImageView!
    @IBOutlet weak var proPic: UIImageView!
    @IBOutlet weak var picView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var tweetCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setHeader()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        TwitterClient.sharedInstance.userTimelineWithParams(nil,user: user.id!) { (tweets, error) -> () in
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
    
    func setHeader(){
        if user.profileBackgroundUrl != nil {
            header.setImageWithURL(NSURL(string: user!.profileBackgroundUrl!)!)
            header.layer.cornerRadius = 8.0
            header.clipsToBounds = true
        } else {
            header.backgroundColor = UIColor()
        }
        proPic.setImageWithURL(NSURL(string: user!.profileImageURL!)!)
        proPic.layer.cornerRadius = 8.0
        proPic.clipsToBounds = true
        picView.layer.cornerRadius = 8.0
        picView.clipsToBounds = true
        
        nameLabel.text = user.name
        userLabel.text = "@\(user.screenname!)"
        bioLabel.text = user.tagline
        followingCount.text = String(user.numFollowing!)
        followerCount.text = String(user.numFollowers!)
        tweetCount.text = String(user.numTweets!)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileIdentifier", forIndexPath: indexPath) as! ProfileCell
        cell.user = user
        cell.tweet = tweets![indexPath.row]
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //refresh method
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        TwitterClient.sharedInstance.userTimelineWithParams(nil,user: user.id!) { (tweets, error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            print("reloading data")
        }
        refreshControl.endRefreshing()
    }
    
    //segue methods
    func profileDetailSegue(notification: NSNotification) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("profile") as! ProfileViewController
        vc.user = notification.userInfo!["user"]! as! User
        self.navigationController?.pushViewController(vc, animated: true)
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
        } else if segue.identifier == "tweetSegue" {
            if let replyTweet = sender as? Tweet {
                let composeViewController = segue.destinationViewController as! NewTweetViewController
                composeViewController.reply = replyTweet
            }
        }
    }
}
