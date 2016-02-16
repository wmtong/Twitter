//
//  ViewController.swift
//  Twitter
//
//  Created by William Tong on 2/15/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func onLogin(sender: AnyObject) {
//        TwitterClient.sharedInstance.loginWithBlock(){
            //go to next screen
//        }
    TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
    TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterWill://oauth"), scope: nil, success: {
    (requestToken: BDBOAuth1Credential!) -> Void in print("Got the request token")
    var authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
    UIApplication.sharedApplication().openURL(authURL!)
    }) {(error:NSError!) -> Void in print("Failed to get request token") }
    
    }

}

