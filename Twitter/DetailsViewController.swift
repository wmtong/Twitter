//
//  DetailsViewController.swift
//  Twitter
//
//  Created by William Tong on 2/23/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    var tweet: Tweet!

    @IBOutlet weak var proPic: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        proPic.setImageWithURL(NSURL(string: tweet.user!.profileImageURL!)!)
        proPic.layer.cornerRadius = 8.0
        proPic.clipsToBounds = true
        nameLabel.text = tweet.user!.name
        userLabel.text = "@\(tweet.user!.screenname!)"
        let calendar = NSCalendar.currentCalendar()
        let dates = calendar.components([.Month, .Day, .Year], fromDate: tweet.createdAt!)
        
        time.text = "\(dates.month)/\(dates.day)/\(dates.year)"
        textLabel.text = tweet.text
        
        if (tweet.isRetweeted != nil && !tweet.isRetweeted! ){
            retweetButton.setImage(UIImage(imageLiteral: "retweet"), forState: .Normal)
        }else{
            retweetButton.setImage(UIImage(imageLiteral: "retweet-pressed"), forState: .Normal)
        }
        if (!tweet.isFavorited! ){
            likeButton.setImage(UIImage(imageLiteral: "like"), forState: .Normal)
        }else{
            likeButton.setImage(UIImage(imageLiteral: "like-pressed"), forState: .Normal)
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "twitterlogo")
        imageView.image = image
        self.navigationItem.titleView = imageView
    }
    
    
    //Twitter functions
    @IBAction func reply(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("replyNotification", object: nil, userInfo: ["reply_tweet" : tweet])
    }
    
    @IBAction func retweet(sender: AnyObject) {
            if (tweet.isRetweeted != nil && !tweet.isRetweeted! ) {
                TwitterClient.sharedInstance.retweet(tweet.id!, completion: { (tweet, error) -> () in
                    let tempTweet = self.tweet
                    tempTweet.retweets!++
                    tempTweet.isRetweeted = true
                    tempTweet.originalId = tweet?.originalId
                    self.tweet = tempTweet
                })
                retweetButton.setImage(UIImage(imageLiteral: "retweet-pressed"), forState: .Normal)
            } else if (tweet.isRetweeted != nil && tweet.isRetweeted!) {
                var id: Int?
                if tweet.originalId != nil{
                    id = tweet.originalId
                }else{
                    id = tweet.id
                }
                TwitterClient.sharedInstance.untweet(id!, completion: { (tweet, error) -> () in
                    let tempTweet = self.tweet
                    tempTweet.retweets!--
                    tempTweet.isRetweeted = false
                    self.tweet = tempTweet
                })
                retweetButton.setImage(UIImage(imageLiteral: "retweet"), forState: .Normal)

            
        }
    }
    
    @IBAction func like(sender: AnyObject) {
        if (tweet.isFavorited != nil && !tweet.isFavorited!) {
            TwitterClient.sharedInstance.like(tweet.id!, completion: { (tweet, error) -> () in
                let tempTweet = self.tweet
                tempTweet.favorites!++
                tempTweet.isFavorited = true
                self.tweet = tempTweet
            })
            likeButton.setImage(UIImage(imageLiteral: "like-pressed"), forState: .Normal)
        } else if (tweet.isFavorited != nil && tweet.isFavorited!) {
            TwitterClient.sharedInstance.unlike(tweet.id!, completion: { (tweet, error) -> () in
                let tempTweet = self.tweet
                tempTweet.favorites!--
                tempTweet.isFavorited = false
                self.tweet = tempTweet
            })
            likeButton.setImage(UIImage(imageLiteral: "like"), forState: .Normal)

        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
