//
//  User.swift
//  Twitter
//
//  Created by William Tong on 2/16/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var id: Int?
    var name: String?
    var screenname: String?
    var profileImageURL: String?
    var profileBackgroundUrl: String?
    var profileBackgroundColor: String?
    var tagline: String?
    var numTweets: Int?
    var numFollowers: Int?
    var numFollowing: Int?
    var dictionary: NSDictionary
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        
        id = dictionary["id"] as? Int
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageURL = dictionary["profile_image_url"] as? String
        profileBackgroundUrl = dictionary["profile_banner_url"] as? String
        profileBackgroundColor = dictionary["profile_background_color"] as? String
        tagline = dictionary["description"] as? String
        numTweets = dictionary["statuses_count"] as? Int
        numFollowers = dictionary["followers_count"] as? Int
        numFollowing = dictionary["friends_count"] as? Int
    }
    
    func logout(){
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
   
    class var currentUser: User? {
        get {
        if _currentUser == nil {
        let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
        if data != nil {
        do {
        let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
        _currentUser = User(dictionary: dictionary as! NSDictionary)
    } catch let error as NSError {
        print(error.localizedDescription)
        }
        }
        }
        return _currentUser
        }
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: [])
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
}

