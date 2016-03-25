//
//  NewTweetViewController.swift
//  Twitter
//
//  Created by William Tong on 2/23/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit

class NewTweetViewController: UIViewController, UITextViewDelegate {
    
    var reply: Tweet?
    @IBOutlet weak var tweetTextField: UITextView!
    @IBOutlet weak var charCount: UILabel!
    @IBOutlet weak var proPic: UIImageView!
    @IBOutlet weak var fillerText: UILabel!
    
    let maxChars = 140
    var counter = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tweetTextField.delegate = self
        tweetTextField.becomeFirstResponder()
        if reply != nil {
            fillerText.hidden = true
            tweetTextField.text = "@\(reply!.user!.screenname!): "
            charCount.text = "\(maxChars - tweetTextField.text.characters.count)"
        }
        
        let current = User.currentUser!
        print(current.name)
        print(current.profileImageURL!)
        proPic.setImageWithURL(NSURL(string: (current.profileImageURL)!)!)
        proPic.layer.cornerRadius = 8.0
        proPic.clipsToBounds = true

    }

    //keeps track of characters
    func textViewDidChange(textView: UITextView) {
        let characters = textView.text.characters.count
        if characters > 0 {
            fillerText.hidden = true
            counter = maxChars-characters
            charCount.text = "\(maxChars - characters)"
        } else {
            fillerText.hidden = false
            charCount.text = "\(maxChars)"
        }
        
    }
    
    //sends an acceptable tweet
    @IBAction func sendTweet(sender: AnyObject) {
        var params = [String : AnyObject]()
        params["status"] = tweetTextField.text
        if(counter==0){
            let alertController = UIAlertController(title: "Cannot Send Tweet", message: "No characters in Tweet", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
        }else{
        if(counter<0){
            let alertController = UIAlertController(title: "Cannot Send Tweet", message: "Tweet is over 140 characters", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)

        }else{
        
        if reply != nil {
            params["in_reply_to_status_id"] = reply!.id!
        }
        TwitterClient.sharedInstance.tweetWithParams(params as NSDictionary) { (tweet, error) -> () in
            NSNotificationCenter.defaultCenter().postNotificationName("newTweet", object: nil, userInfo: ["new_tweet" : tweet!])
        }
        self.dismissViewControllerAnimated(true) { () -> Void in
            print("dismiss from tweet")
        }
        }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
