//
//  UserRepositories.swift
//  together
//
//  Created by ASda Bogasd on 16.01.17.
//  Copyright © 2017 Attractive Products. All rights reserved.
//

import Foundation
import Firebase

class UserRepositories {
    var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    var storageRef: FIRStorageReference!
 
    
    func addnewUser(user: User, ref: FIRDatabaseReference!, storageRef: FIRStorageReference, type:String=""){
        //find actual count of users
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let count = value?["count"] as? NSInteger
            if (user.id == 0){
                if (count != nil){
                    user.id = count!+1
                    } else{
                        user.id = 1
                            }
            }
            let newUser: NSDictionary = UserMaper.userToDictionary(user: user)
            //Store UserId
  
            
            //Put image
            // Data in memory
            let data = UIImagePNGRepresentation(user.photo)
            
            // Create a reference to the file you want to upload
            let riversRef = storageRef.child("avatars/"+String(describing: user.id)+".jpg")
            
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef.put(data!, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL
            }
            //Put data to dataBase
            self.ref.child("users").child(String(user.id)).setValue(newUser)
            if(type == "standart"){self.ref.child("users").child("count").setValue(count!+1)}
                    
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func loadUserImage(id:UInt64, storage: FIRStorage, storageRef: FIRStorageReference, withh: @escaping (UIImage)->Void){
        var image :UIImage = UIImage()
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        let riversRef = storageRef.child("avatars/"+String(id)+".jpg")
        riversRef.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                image = UIImage(data: data!)!
                
            }
            withh(image)
        }
    }

    func loadLogin(id:Int, withh: @escaping (String)->Void){
        var name:String = ""
        ref.child("users/"+String(id)).observeSingleEvent(of: .value, with: { (snapshot) in
            if(snapshot.exists()){
                name = snapshot.childSnapshot(forPath: "name").value as! String
            } else {
                self.loadLogin(id: id, withh: {(namee) in
                    var name: String = ""
                   name=namee
                    withh(name)
                })
                            }
            withh(name)
        })
    }
    
    func loadUser(userId: UInt64, withh: @escaping (User)->Void){
        let userRef = ref.child("users/" + String(userId)).observe(.value, with:{ (snapshot) in
        let userDictionary = snapshot.value as! NSDictionary
        let storage = FIRStorage.storage()
        self.storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
            self.loadUserImage(id: userId, storage: storage, storageRef: self.storageRef, withh:{ (image) in
                var user: User = User()
                user = UserMaper.dictionaryToUser(userDictionary: userDictionary, image: image)
                withh(user)
            })
        })
    
    }
    
    func uploadUserImage(userId: UInt64,image: UIImage){
        ref = FIRDatabase.database().reference()
        let storage = FIRStorage.storage()
        storageRef = storage.reference(forURL: "gs://together-df2ce.appspot.com")
        let data = UIImagePNGRepresentation(image)
        let riversRef = storageRef.child("avatars/"+String(describing: userId)+".jpg")
        let uploadTask = riversRef.put(data!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL
        }
    }
    
    func withdrawReguest(){
        
    }
}
