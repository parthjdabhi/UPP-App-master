//
//  TweetViewTableViewCell.swift
//  UPP App
//
//  Created by iParth on 9/3/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class TweetViewTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var uname: UILabel!
    @IBOutlet weak var tweet: UITextView!
    
    @IBOutlet weak var btnReply: UIButton!
    @IBOutlet weak var btnRepost: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    
    var post:Post?
    var ref:FIRDatabaseReference = FIRDatabase.database().reference()
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    internal func configure(forPost post:Post)
    {
        self.post = post
        //profilePic:String?,name:String,uname:String?,tweet:String?
        
        self.tweet.text = post.Text
        self.uname.text = "@" + (post.userID ?? "")
        self.name.text = post.key
        
//        if((profilePic) != nil)
//        {
//            let imageData = NSData(contentsOfURL: NSURL(string:profilePic!)!)
//            self.profilePic.image = UIImage(data:imageData!)
//        }
//        else
//        {
//            self.profilePic.image = UIImage(named:"profile")
//        }
        
        
        ref.child("users").child(MyUserID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.post?.username = snapshot.value!["username"] as? String
            self.name.text = self.post?.username ?? ""
            //Show Image too
        })
        { (error) in
            print(error.localizedDescription)
        }
        
        self.btnLike.backgroundColor = UIColor.clearColor()
        btnLike.tag = 0
        //is Liked ??
        var FavUser:Array<String> = []
        if let FavUsers = self.post?.FavUsers
        {
            if let FavUser = FavUsers[MyUserID] {
                print(FavUser)
                self.btnLike.backgroundColor = UIColor.lightGrayColor()
                btnLike.tag = 1
//                self.btnReply.setCornerRadious(self.btnLike.frame.width/2)
//                self.btnReply.setBorder(2, color: UIColor.blackColor())
                //self.btnReply..userInteractionEnabled = false
            }
            
            for key : String in Array(FavUsers.keys) {
                FavUser.append(key)
            }
            self.btnLike.setTitle("\(FavUser.count)", forState: .Normal)
            print(FavUser)
        } else {
            self.btnLike.setTitle("", forState: .Normal)
        }
    }
    
    @IBAction func actionReply(sender: UIButton) {
    }
    
    @IBAction func actionRepost(sender: UIButton) {
        SVProgressHUD.showWithStatus("Publishing..")
        let timestamp = NSDate().timeIntervalSince1970
        ref.child("posts").childByAutoId().updateChildValues(["Text": self.post?.Text ?? "", "userID": MyUserID,"originPost":post?.key ?? "","repostAt": timestamp]) { (error, ref) in
            
            if error == nil {
                print("Repost successfully")
                SVProgressHUD.showSuccessWithStatus("Your tweets reposted successfully!")
            } else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @IBAction func actionLike(sender: UIButton) {
        //MyUserID
        
        if sender.tag == 0 {
            let timestamp = NSDate().timeIntervalSince1970
            let FavUser:[String:AnyObject] = ["joinedAt": timestamp, "uid": MyUserID]
            print(FavUser,post)
            
            SVProgressHUD.showWithStatus("Loading..")
            ref.child("posts").child((post?.key)!).child("FavUsers").child(MyUserID).updateChildValues(FavUser) { (error, ref) in
                if error == nil {
                    SVProgressHUD.showSuccessWithStatus("Likes successfully!")
                    self.btnLike.backgroundColor = UIColor.lightGrayColor()
                } else {
                    SVProgressHUD.dismiss()
                }
            }
        } else {
            SVProgressHUD.showWithStatus("Loading..")
            ref.child("posts").child((post?.key)!).child("FavUsers").child(MyUserID).removeValueWithCompletionBlock({ (error, ref) in
                CommonUtils.sharedUtils.hideProgress()
                if error == nil {
                    SVProgressHUD.showSuccessWithStatus("Unlikes successfully!")
                    self.btnLike.backgroundColor = UIColor.clearColor()
                } else {
                    SVProgressHUD.dismiss()
                }
            })
        }
    }
}
