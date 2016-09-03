//
//  TweetViewTableViewCell.swift
//  UPP App
//
//  Created by iParth on 9/3/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit

class TweetViewTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var uname: UILabel!
    @IBOutlet weak var tweet: UITextView!
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public func configure(profilePic:String?,name:String,uname:String?,tweet:String?)
    {
        self.tweet.text = tweet
        self.uname.text = "@" + (uname ?? "")
        self.name.text = name
        
        
        //        if((profilePic) != nil)
        //        {
        //            let imageData = NSData(contentsOfURL: NSURL(string:profilePic!)!)
        //            self.profilePic.image = UIImage(data:imageData!)
        //        }
        //        else
        //        {
        //            self.profilePic.image = UIImage(named:"profile")
        //        }
        
    }
}
