//
//  Tweet.swift
//  Twitter
//
//  Created by William Tong on 2/16/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class Tweet: NSObject {
    var user: User?
    var id: Int?
    var originalId: Int?
    var text: String?
    var retweets: Int?
    var favorites: Int?
    var isRetweeted: Bool?
    var isFavorited: Bool?
    var createdAtString: String?
    var createdAt: NSDate?
    
    init(dictionary: NSDictionary){
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        id = dictionary["id"] as? Int
        text = dictionary["text"] as? String
        retweets = dictionary["retweet_count"] as? Int
        favorites = dictionary["favorite_count"] as? Int
        isRetweeted = dictionary["retweeted"] as? Bool
        isFavorited = dictionary["favorited"] as? Bool
        createdAtString = dictionary["created_at"] as? String
        
        if let retweetData = dictionary["retweeted_status"] as? NSDictionary {
            favorites = retweetData["favorite_count"] as? Int
            originalId = retweetData["id"] as? Int
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
            //print((dictionary: dictionary))
        }
        
        return tweets
    }
}
