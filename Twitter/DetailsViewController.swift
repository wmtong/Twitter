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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        proPic.setImageWithURL(NSURL(string: tweet.user!.profileImageURL!)!)
        nameLabel.text = tweet.user!.name
        userLabel.text = "@\(tweet.user!.screenname!)"
        let calendar = NSCalendar.currentCalendar()
        let dates = calendar.components([.Month, .Day, .Year], fromDate: tweet.createdAt!)
        
        time.text = "\(dates.month)/\(dates.day)/\(dates.year)"
        textLabel.text = tweet.text
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
