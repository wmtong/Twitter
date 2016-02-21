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
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
        
        class var sharedInstance: TwitterClient{
            struct Static{
                static let instance = TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
            }
            return Static.instance
        }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        // Fetch request token & redirect to authorization page
        requestSerializer.removeAccessToken()
        fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterwill://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            print("Got the request token")
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            UIApplication.sharedApplication().openURL(authURL!)
            }) {(error: NSError!) -> Void in
                print("Failed to get request token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: params, progress: nil, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            print("home timeline: \(response)")
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error getting home timeline")
                completion(tweets: nil, error: error)
        })
    }
    
    func homeTimelineUpdate(max_id: Int, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        let params = ["max_id" : max_id]
        GET("1.1/statuses/home_timeline.json", parameters: params, progress: nil, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error getting timeline update")
                completion(tweets: nil, error: error)
        })
    }
    
    func retweet(id: Int, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/statuses/retweet/\(String(id)).json", parameters: nil, progress: nil, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            print("successful retweet")
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("failed retweet")
                completion(tweet: nil, error: error)
        })
    }
    
    func untweet(id: Int, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        GET("1.1/statuses/show.json?id=\(String(id))", parameters: ["include_my_retweet" : true], progress: nil, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            //print("home timeline: \(response)")
            let tweet = response as! NSDictionary
            let currentUserRetweetId = tweet["current_user_retweet"]!["id"] as! Int
            
            self.POST("1.1/statuses/destroy/\(String(currentUserRetweetId)).json", parameters: nil, progress: nil, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
                print("successful untweet")
                let tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet: tweet, error: nil)
                }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                    print("failed untweet")
                    completion(tweet: nil, error: error)
            })
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error getting tweet id")
                completion(tweet: nil, error: error)
        })
    }
    
    func like(id: Int, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/favorites/create.json?id=\(String(id))", parameters: nil, progress: nil, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            print("successful favorite")
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("failed favorite")
                completion(tweet: nil, error: error)
        })
    }
    
    func unlike(id: Int, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/favorites/destroy.json?id=\(String(id))", parameters: nil, progress: nil, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            print("successful defavorite")
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("failed defavorite")
                completion(tweet: nil, error: nil)
        })
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            print("Got the access token!")
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
                //print("user: \(response)")
                let user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                print("user: \(user.name)")
                self.loginCompletion?(user: user, error: nil)
                }, failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                    print("error getting current user")
                    self.loginCompletion?(user: nil, error: error)
            })
            }) { (error: NSError!) -> Void in
                print("Failed to receive access token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
}