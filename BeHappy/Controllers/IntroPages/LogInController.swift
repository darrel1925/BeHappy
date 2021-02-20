//
//  LogInController.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 1/26/21.
//

import UIKit
import FirebaseAuth

class LogInController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
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
        if (emailField.text!.isEmpty) {
            let message = "Email must be a valid school email address ending in 'edu' \n\nEx. panteatr@uci.edu, bbears@ucla.edu"
            self.displayError(title: "Whoops.", message: message)
            return false
        }
        return true
    }

    @IBAction func loginTapped(_ sender: Any) {
        if !credentialsAreValid() { return }
        
        activityIndicator.startAnimating()
        let email = emailField.text!
        let password = passwordField.text!
        print("entered")
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] user, error in
            
            if error != nil {
                if let error = AuthErrorCode(rawValue: error!._code) {
                    self?.displayError(title: "Error", message: error.errorMessage)
                    self?.activityIndicator.stopAnimating()
                    return
                }
            }
            
            user?.user.reload(completion: { (err) in // reloads user fields, like emailVerified:
                if let _ = err{ print("unable to reload user") ; return}
                print("user reloaded in log in")
            })
            
            self?.activityIndicator.stopAnimating()
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            UserService.getCurrentUser(email: email, dispatchGroup: dispatchGroup)
            
            dispatchGroup.notify(queue: .main, execute: {
                self?.presentHomePage()
            })
        }
    }


}
