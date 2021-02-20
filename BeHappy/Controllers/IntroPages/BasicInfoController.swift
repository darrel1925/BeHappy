//
//  BasicInfoController.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 1/26/21.
//

import UIKit

class BasicInfoController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var favoritePlaceField: UITextField!
    @IBOutlet weak var homeAddressField: UITextField!
    @IBOutlet weak var workAddressField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    func credentialsAreValid() -> Bool {
        if nameField.text!.isEmpty {
            let message = "Looks like you didn't enter a name."
            self.displayError(title: "Invalid Name", message: message)
            return false
        }
        else if ageField.text!.isOnlyNumeric {
            let message = "Your age should be a number."
            self.displayError(title: "Invalid Age", message: message)
            return false
        }
        else if heightField.text!.isEmpty {
            let message = "Looks like you didn't enter your height."
            self.displayError(title: "Invalid height", message: message)
            return false
        }
        else if dobField.text!.isEmpty {
            let message = "Invalid Date of Birth."
            self.displayError(title: "Invalid DOB", message: message)
            return false
        }
        else if genderField.text!.isEmpty {
            let message = "Gender is missing!."
            self.displayError(title: "Invalid home gender", message: message)
            return false
        }
        else if homeAddressField.text!.isEmpty {
            let message = "Home address field is missing!"
            self.displayError(title: "Invalid home address", message: message)
            return false
        }
        else if workAddressField.text!.isEmpty {
            let message = "Looks like you forgot to enter a work address"
            self.displayError(title: "Invalid work address", message: message)
            return false
        }
        return true
    }
    
    func presentSetGoalsController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SetGoalsController") as! SetGoalsController
        
        vc.userInfo = [
            "name" : nameField.text!,
            "age" : ageField.text!,
            "height" : heightField.text!,
            "dob" : dobField.text!,
            "gender": genderField.text!,
            "favoritePlace": favoritePlaceField.text ?? "",
            "homeAddress" : homeAddressField.text!,
            "workAddress" : workAddressField.text!,
        ]
        
         navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func nextBtnTapped(_ sender: Any) {
//        if !credentialsAreValid() { return }
        
        presentSetGoalsController()
    }
    
}
