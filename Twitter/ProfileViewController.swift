//
//  ProfileViewController.swift
//  Twitter
//
//  Created by William Tong on 2/23/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var user: User!
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
        if user.profileBackgroundUrl != nil {
            header.setImageWithURL(NSURL(string: user!.profileBackgroundUrl!)!)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
