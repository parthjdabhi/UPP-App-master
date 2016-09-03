
import Foundation
import FirebaseDatabase


struct Post {
    
    let key:String!
    let content:String!
    let addedByUser:String!
    let itemRef:FIRDatabaseReference?
    
    
    init (content:String, addedByUser:String, key:String = "") {
        self.key = key
        self.content = content
        self.addedByUser = addedByUser
        self.itemRef = nil
    }
    
    
    init(snapshot:FIRDataSnapshot) {
        key = snapshot.key
        itemRef = snapshot.ref
        
        print(snapshot)
        
        if let postContent = snapshot.value!["Text"] as? String {
            content = postContent
        }
        else {
            content = ""
        }
        
        if let postUser = snapshot.value!["userID"] as? String {
            addedByUser = postUser
        } else {
            addedByUser = ""
        }
    }
    
    
    func toAnyObject() -> AnyObject {
        return ["Text":content, "userID":addedByUser]
    }
    
}
