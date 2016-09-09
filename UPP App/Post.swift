
import Foundation
import FirebaseDatabase


struct Post {
    
    let key:String!
    let userID:String!
    let Text:String!
    let itemRef:FIRDatabaseReference?
    var FavUsers:Dictionary<String,AnyObject>?
    var originPost:String?
    var username:String?
    
    
    init (ref:FIRDatabaseReference?, key:String = "", Text:String, userID:String, FavUsers:Dictionary<String,AnyObject>?) {
        self.key = key
        self.Text = Text
        self.userID = userID
        self.itemRef = ref
        self.FavUsers = FavUsers
    }
    
    init(snapshot:FIRDataSnapshot)
    {
        key = snapshot.key
        itemRef = snapshot.ref
        
        print(snapshot)
        
        if let postContent = snapshot.value!["Text"] as? String {
            Text = postContent
        } else {
            Text = ""
        }
        
        if let postUser = snapshot.value!["userID"] as? String {
            userID = postUser
        } else {
            userID = ""
        }
        
        if let FavUsers = snapshot.value!["FavUsers"] as? Dictionary<String,AnyObject> {
            self.FavUsers = FavUsers
            //Can check is Liked
            
        }
        
    }
    
    func toAnyObject() -> AnyObject {
        return ["Text":Text, "userID":userID]
    }
    
    
}
