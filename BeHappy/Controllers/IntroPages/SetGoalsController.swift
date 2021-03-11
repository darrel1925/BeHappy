//
//  SetGoalsController.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 1/26/21.
//

import UIKit

class SetGoalsController: UIViewController {

    var userInfo: [String: String] = [:]
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var caloriesField: UITextField!
    @IBOutlet weak var minOfExerciseField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(userInfo)
    }
    
    func credentialsAreValid() -> Bool {
        if weightField.text!.isEmpty {
            let message = "Looks like you didn't enter a weight."
            self.displayError(title: "Invalid Weight", message: message)
            return false
        }
        else if caloriesField.text!.isOnlyNumeric {
            let message = "Your age should be a number of calories."
            self.displayError(title: "Invalid Calories/day", message: message)
            return false
        }
        else if minOfExerciseField.text!.isEmpty {
            let message = "Looks like you didn't enter your minutes of exercise."
            self.displayError(title: "Invalid Minues of Exercise", message: message)
            return false
        }
        return true
    }
    
    func presentRegisterController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegisterController") as! RegisterController
        
        userInfo.updateValue(weightField.text!, forKey: "activityGoal")
        userInfo.updateValue(caloriesField.text!, forKey: "calorieGoal")
        userInfo.updateValue("8", forKey: "sleepGoal")
        vc.userInfo = userInfo
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func completeTapped(_ sender: Any) {
        if !credentialsAreValid() { return }
        self.presentRegisterController()
    }
    
}
