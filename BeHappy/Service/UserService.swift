//
//  UserService.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 1/26/21.
//
import Firebase
import FirebaseAuth
import FirebaseFirestore

let UserService = _UserService()

final class _UserService {
    var user: User!
    var userListener: ListenerRegistration? = nil // our database listener
    
    func getCurrentUser(email: String, dispatchGroup: DispatchGroup) {
        // if user is logged in
        let db = Firestore.firestore()
        let userRef = db.collection("User").document(email)

        // if user changes something in document, it will always be up to date in our app
        userListener = userRef.addSnapshotListener({ (snap, error) in
            
            if let error = error {
                print("could not add snapShotListener :/")
                debugPrint(error.localizedDescription)
                dispatchGroup.customLeave()
            }
            
//          if we can get user info from db
            guard let data = snap?.data() else {
                print("no data")
                dispatchGroup.customLeave()
                return
            }
            // add it to out user so we can access it globally
//            print("Data is \(data)")
            self.user = User.init(data: data)
//            print("user info has been updated")
            dispatchGroup.customLeave()
        })
        
        dispatchGroup.notify(queue: .main) {
            UserService.updateFirebaseWithUpdatedVars()
        }
    }
    
    func updateFirebaseWithUpdatedVars() {
        let db = Firestore.firestore()
        let docRef = db.collection("User").document(user.email)
        let userInfo = User.modelToData(user: user)
        docRef.setData(userInfo, merge: true)
    }
}
