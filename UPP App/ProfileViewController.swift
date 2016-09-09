//
//  ProfileViewController.swift
//  UPP App
//
//  Created by Dustin Allen on 8/27/16.
//  Copyright © 2016 Harloch. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var dbRef:FIRDatabaseReference!
    
    var user: FIRUser!
    var imgTaken = false
    var imagePickerController: UIImagePickerController!
    
    @IBOutlet var postField: UITextView!
    @IBOutlet var photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference().child("posts")
        user = FIRAuth.auth()?.currentUser
        
        self.photo.layoutIfNeeded()
        
        photo.layer.cornerRadius = max(photo.frame.size.width, photo.frame.size.height) / 2
        photo.layer.borderWidth = 3
        photo.layer.masksToBounds = true
        photo.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).CGColor

        photo.image = AppState.sharedInstance.myProfile ?? UIImage(named: "user.png")
        
        let imgTapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.onTapProfilePic(_:)) )
        imgTapGesture.numberOfTouchesRequired = 1
        imgTapGesture.cancelsTouchesInView = true
        photo.addGestureRecognizer(imgTapGesture)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onTapProfilePic(sender: UILongPressGestureRecognizer? = nil) {
        // 1
        view.endEditing(true)
        
        // 2
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                       message: nil, preferredStyle: .ActionSheet)
        
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .Default) { (alert) -> Void in
                                            self.imagePickerController = UIImagePickerController()
                                            self.imagePickerController.delegate = self
                                            self.imagePickerController.sourceType = .PhotoLibrary
                                            self.presentViewController(self.imagePickerController,
                                                                       animated: true,
                                                                       completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        // 5
        let cancelButton = UIAlertAction(title: "Cancel",
                                         style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        // 6
        presentViewController(imagePickerActionSheet, animated: true,
                              completion: nil)
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSizeMake(maxDimension, maxDimension)
        var scaleFactor:CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            photo.image = scaleImage(pickedImage, maxDimension: 300)
            AppState.sharedInstance.myProfile = photo.image
            
            let base64String = self.imgToBase64(photo.image!)
            let strProfile = base64String as String
            
            FIRDatabase.database().reference().child("users").child(MyUserID).setValue(strProfile, forKey: "image")
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        
    }
    
    func imgToBase64(image: UIImage) -> String {
        let imageData:NSData = UIImagePNGRepresentation(image)!
        let base64String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        print(base64String)
        
        return base64String
    }
    
    @IBAction func postButton(sender: AnyObject) {
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        if let postText = self.postField.text {
            //self.dbRef.childByAutoId().updateChildValues(["Text": postText, "userID": userID!])
            CommonUtils.sharedUtils.showProgress(self.view, label: "Loading..")
            self.dbRef.childByAutoId().updateChildValues(["Text": postText, "userID": userID!]) { (error, ref) in
                CommonUtils.sharedUtils.hideProgress()
                if error == nil {
                    CommonUtils.sharedUtils.showAlert(self, title: "Message", message: "Your tweet posted successfully!")
                    self.postField.text = ""
                }
            }
            
            //let post = Post(content: postText, addedByUser: "MyUID")
            //let postRef = self.dbRef.child(postText.lowercaseString)
            //postRef.setValue(post.toAnyObject())
        }
        
    }
    
    
    @IBAction func listTweetsButton(sender: AnyObject) {
        let Timeline = self.storyboard?.instantiateViewControllerWithIdentifier("TimelineViewController") as! TimelineViewController
        self.navigationController?.pushViewController(Timeline, animated: true)
    }
}
