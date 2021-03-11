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
    var dg = DispatchGroup()
    
    func getCurrentUser(email: String, dispatchGroup: DispatchGroup) {
        // if user is logged in
        let db = Firestore.firestore()
        let userRef = db.collection("User").document(email)

        // if user changes something in document, it will always be up to date in our app
        userListener = userRef.addSnapshotListener({ (snap, error) in
            
            if let error = error {
                print("could not add snapShotListener")
                debugPrint(error.localizedDescription)
                dispatchGroup.customLeave()
            }
            
//          if we can get user info from db
            guard let data = snap?.data() else {
                dispatchGroup.customLeave()
                return
            }
            // add it to out user so we can access it globally
            self.user = User.init(data: data)
            dispatchGroup.customLeave()
        })
        
        dispatchGroup.notify(queue: .main) {
            UserService.updateFirebaseWithUpdatedVars()
            self.dg.customLeave()
        }
    }
    
    func updateFirebaseWithUpdatedVars() {
        let db = Firestore.firestore()
        let docRef = db.collection("User").document(user.email)
        let userInfo = User.modelToData(user: user)
        docRef.setData(userInfo, merge: true)
    }
}
