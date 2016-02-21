//
//  TweetCell.swift
//  Twitter
//
//  Created by William Tong on 2/18/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var proPic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    
    @IBOutlet weak var replyImage: UIImageView!
    @IBOutlet weak var retweetImage: UIImageView!
    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var likeCount: UILabel!
    
    let user = User.currentUser
    
    let tapProfileDetail = UITapGestureRecognizer()
    let tapReply = UITapGestureRecognizer()
    let tapRetweet = UITapGestureRecognizer()
    let tapFavorite = UITapGestureRecognizer()
    
    var tweet: Tweet! {
        didSet{

            proPic.setImageWithURL(NSURL(string: (tweet.user!.profileImageURL)!)!)
            print(tweet.user!.profileImageURL)
            name.text = tweet.user?.name
            username.text = "@\(tweet.user!.screenname!)"
            
            let calendar = NSCalendar.currentCalendar()
            let dates = calendar.components([.Month, .Day, .Year], fromDate: tweet.createdAt!)
            
            time.text = "\(dates.month)/\(dates.day)/\(dates.year)"
            
            tweetText.text = tweet.text
            
            retweetCount.text = String(tweet.retweets!)
            if tweet.retweets > 0 {
                retweetCount.hidden = false
            } else {
                retweetCount.hidden = true
            }
            
            likeCount.text = String(tweet.favorites!)
            if tweet.favorites > 0 {
                likeCount.hidden = false
            } else {
                likeCount.hidden = true
            }
            
            if (tweet.isRetweeted != nil && tweet.isRetweeted!) {
                retweetImage.image = UIImage(named: "retweet-pressed")
                retweetCount.textColor = UIColor.greenColor()
            } else {
                retweetImage.image = UIImage(named: "retweet")
                retweetCount.textColor = UIColor.grayColor()
            }
            
            if (tweet.isFavorited != nil && tweet.isFavorited!) {
                likeImage.image = UIImage(named: "like-pressed")
                likeCount.textColor = UIColor.redColor()
            } else {
                likeImage.image = UIImage(named: "like")
                likeCount.textColor = UIColor.grayColor()
            }


        }
    }
    
    func retweet() {
        if (tweet.isRetweeted != nil && !tweet.isRetweeted! && tweet.user!.name != user!.name) {
            TwitterClient.sharedInstance.retweet(tweet.id!, completion: { (tweet, error) -> () in
                let tempTweet = self.tweet
                tempTweet.retweets!++
                tempTweet.isRetweeted = true
                tempTweet.originalId = tweet?.originalId
                self.tweet = tempTweet
            })
        } else if (tweet.isRetweeted != nil && tweet.isRetweeted!) {
            TwitterClient.sharedInstance.untweet(tweet.originalId!, completion: { (tweet, error) -> () in
                let tempTweet = self.tweet
                tempTweet.retweets!--
                tempTweet.isRetweeted = false
                self.tweet = tempTweet
            })
        }
    }
    
    func like() {
        if (tweet.isFavorited != nil && !tweet.isFavorited!) {
            TwitterClient.sharedInstance.like(tweet.id!, completion: { (tweet, error) -> () in
                let tempTweet = self.tweet
                tempTweet.favorites!++
                tempTweet.isFavorited = true
                self.tweet = tempTweet
            })
        } else if (tweet.isFavorited != nil && tweet.isFavorited!) {
            TwitterClient.sharedInstance.unlike(tweet.id!, completion: { (tweet, error) -> () in
                let tempTweet = self.tweet
                tempTweet.favorites!--
                tempTweet.isFavorited = false
                self.tweet = tempTweet
            })
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        proPic.layer.cornerRadius = 8.0
        proPic.clipsToBounds = true
        tapRetweet.addTarget(self, action: "retweet")
        retweetImage.addGestureRecognizer(tapRetweet)
        retweetImage.userInteractionEnabled = true
        
        tapFavorite.addTarget(self, action: "like")
        likeImage.addGestureRecognizer(tapFavorite)
        likeImage.userInteractionEnabled = true
        
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
