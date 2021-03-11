//
//  RegisterController.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 1/26/21.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var userInfo: [String: String] = [:]
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func presentHomePage() {
        
        let tabViewController = storyboard!.instantiateViewController(withIdentifier: "tabController") as! UITabBarController
        tabViewController.modalPresentationStyle = .fullScreen

        present(tabViewController, animated: true, completion: nil)
    }
    
    func credentialsAreValid() -> Bool {
        if emailField.text!.isEmpty {
            let message = "Email that was entered is invalid."
            self.displayError(title: "Invalid School Email.", message: message)
            return false
        }
        else if (passwordField.text!.count < 6 || passwordField.text!.containsWhitespace) {
            print(passwordField.text!.count < 6)
            print(passwordField.text!.containsWhitespace)
            let message = "Password must be at least 6 charaters and contain no spaces."
            self.displayError(title: "Weak Password.", message: message)
            return false
        }
        else if !(passwordField.text! == confirmPasswordField.text) {
            let message = "Looks like your passwords don't match. Let's give it another shot."
            self.displayError(title: "Passwords don't match.", message: message)
            return false
        }
        return true
    }

    func createFireStoreUser(user: User, fireUser: FirebaseAuth.User) {
        // Add a new document with a generated ID
        let ref = db.collection("User").document(user.email)
        let user_dict = User.modelToData(user: user)
        print("here3")
        ref.setData(user_dict, merge: true) { err in
            if let err = err {
                print("Error adding document: \(err)")
                self.displayError(error: err)
                self.activityIndicator.stopAnimating()
                return
            }
            self.activityIndicator.stopAnimating()
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            UserService.getCurrentUser(email: user.email, dispatchGroup: dispatchGroup)
            print("here4")
            dispatchGroup.notify(queue: .main, execute: {
                print("heading to home page")
                self.presentHomePage()
            })
        }
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
//        if !credentialsAreValid() { return }
        
        let email = emailField.text!.lowercased()
        let password = passwordField.text!
        
        activityIndicator.startAnimating()
        print("here1")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil {
                if let error = AuthErrorCode(rawValue: error!._code) {
                    self.displayError(title: "Error", message: error.errorMessage)
                    self.activityIndicator.stopAnimating()
                    return
                }
            }
            
            guard let fireUser = result?.user else { return }
            
            let user = User.init(id: fireUser.uid,
                                 name: self.userInfo["name"]!,
                                 email: email,
                                 height: self.userInfo["height"]!,
                                 homeAddress: self.userInfo["homeAddress"]!,
                                 workAddress: self.userInfo["workAddress"]!,
                                 weight: self.userInfo["favoritePlace"]!,
                                 dob: self.userInfo["dob"]!,
                                 gender: self.userInfo["gender"]!,
                                 age: self.userInfo["age"]!,
                                 activityGoal:Int(self.userInfo["activityGoal"]!)!,
                                 calorieGoal:Int(self.userInfo["calorieGoal"]!)!,
                                 sleepGoal: Int(self.userInfo["sleepGoal"]!)!
                                 )
            print("here2")
            self.createFireStoreUser(user: user, fireUser: fireUser)
        }
    }
    

}
