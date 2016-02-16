//
//  TwitterClient.swift
//  Twitter
//
//  Created by William Tong on 2/15/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import BDBOAuth1Manager

let twitterConsumerKey = "p4DMDRTzqrNp7cAl1WbBIvir6"
let twitterConsumerSecret = "NJjPrYd3IB41wvXAa693VOBt10zEBt7SlYkdek5MFoOmOrLVD9"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
        
        class var sharedInstance: TwitterClient{
            struct Static{
                static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
            }
            return Static.instance
        }
}


