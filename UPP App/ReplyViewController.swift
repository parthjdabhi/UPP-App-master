//
//  ReplyViewController.swift
//  UPP App
//
//  Created by iParth on 9/9/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class ReplyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dbRef:FIRDatabaseReference!
    
    var post:Post?
    var user: FIRUser!
    var imgTaken = false
    var imagePickerController: UIImagePickerController!
    //var replies:Array<Dictionary<String,AnyObject>>?
    var replies = [Post]()
    
    @IBOutlet var txtReply: UITextView!
    @IBOutlet var tblReplies: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference()
        startObservingDB()
        
        txtReply.text = "@\(post?.username ?? "Reply to tweet")"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBackButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func startObservingDB ()
    {
        dbRef.child("posts").child(post?.key ?? "").child("reply").observeEventType(.Value, withBlock: {
            (snapshot:FIRDataSnapshot) in
            var newPosts:Array<Post> = []
            
            for post in snapshot.children {
                print(( post as! FIRDataSnapshot).valueInExportFormat())
                let postObject = Post(snapshot: post as! FIRDataSnapshot)
                newPosts.insert(postObject, atIndex: 0)
            }

            self.replies = newPosts
            self.tblReplies.reloadData()
            
        }) { (error:NSError) in
            print(error.description)
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
//        cell.textLabel?.text = "test"
//        cell.detailTextLabel?.text = "details"
        
        let post = replies[indexPath.row]
        let cell: TweetViewTableViewCell = tableView.dequeueReusableCellWithIdentifier("TweetViewTableViewCell", forIndexPath: indexPath) as! TweetViewTableViewCell
        cell.configure(forPost: post)
        
        return cell
    }
    
    
    @IBAction func actionReply(sender: AnyObject)
    {
        let userID = FIRAuth.auth()?.currentUser?.uid
        if let replyText = self.txtReply.text {
            //self.dbRef.childByAutoId().updateChildValues(["Text": postText, "userID": userID!])
            CommonUtils.sharedUtils.showProgress(self.view, label: "Loading..")
            self.dbRef.child("posts").child(post?.key ?? "").child("reply").childByAutoId().updateChildValues(["Text": replyText, "userID": userID!]) { (error, ref) in
                CommonUtils.sharedUtils.hideProgress()
                if error == nil {
                    CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Your reply posted successfully!")
                    self.txtReply.text = ""
                }
            }
            
            //let post = Post(content: postText, addedByUser: "MyUID")
            //let postRef = self.dbRef.child(postText.lowercaseString)
            //postRef.setValue(post.toAnyObject())
        }
    }
}
