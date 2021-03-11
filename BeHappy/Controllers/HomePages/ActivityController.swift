//
//  ActivityController.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 1/27/21.
//

import UIKit
import FirebaseFirestore
import Firebase

class ActivityController: UIViewController {
    @IBOutlet weak var todaysActivityLabel: UILabel!
    @IBOutlet weak var todaysCalorieLabel: UILabel!
    @IBOutlet weak var yesterdaysActivityLabel: UILabel!
    @IBOutlet weak var yseterdaysCalorieLabel: UILabel!
    @IBOutlet weak var activityNameField: UITextField!
    @IBOutlet weak var numCaloriesField: UITextField!
    @IBOutlet weak var summeryLabel: UILabel!
    
    let db = Firestore.firestore()
    var activityData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
    }

    override func viewDidAppear(_ animated: Bool) {
        setLabels()
    }
    
    
    func setTextFields() {
        activityNameField.delegate = self
        numCaloriesField.delegate = self
    }
    
    func setLabels() {
        summeryLabel.text = "\( UserService.user.name)'s Activity Summery"
        
        if UserService.user.activity.count == 0 {
            todaysActivityLabel.text = "---"
            todaysCalorieLabel.text = "---"
            
            yesterdaysActivityLabel.text = "---"
            yseterdaysCalorieLabel.text = "---"
        }
        else if UserService.user.activity.count == 1 {
            let activity = UserService.user.activity[0]
            todaysActivityLabel.text = activity["name"] as? String
            todaysCalorieLabel.text = "\(activity["numCalories"] as! Int)"
            
            yesterdaysActivityLabel.text = "---"
            yseterdaysCalorieLabel.text = "---"
        }
        else {
            let activity = UserService.user.activity[0]
            todaysActivityLabel.text = activity["name"] as? String
            todaysCalorieLabel.text = "\(activity["numCalories"] as! Int)"
            
            let activity2 = UserService.user.activity[1]
            yesterdaysActivityLabel.text = activity2["name"] as? String
            yseterdaysCalorieLabel.text = "\(activity2["numCalories"] as! Int)"
        }
    }
    
    
    func clearTextFields() {
        activityNameField.text = ""
        numCaloriesField.text = ""
    }
    
    func credentialsAreValid() -> Bool {
        if (activityNameField.text!.isEmpty) {
            let message = "Must enter a value"
            self.displayError(title: "Whoops.", message: message)
            return false
        }
        else if (numCaloriesField.text!.isEmpty) {
            let message = "Must enter how many calories were consumed"
            self.displayError(title: "Whoops.", message: message)
            return false
        }
        return true
    }
    
    func getData(dg: DispatchGroup) {
        let docRef = db.collection("User").document(UserService.user.email)
        dg.enter()
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let docData = document.data() ?? [:]
                print("docData \n\n\n \(docData) \n\n\n")
                self.activityData = docData["activity"] as! [[String : Any]]
                dg.customLeave()
            }
            else {
                self.displayError(title: "Error", message: "Document dose not exist")
                dg.customLeave()
            }
        }
    }
    
    func presentActivityHistoryController() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ActivityHistoryController") as! ActivityHistoryController
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func viewHistoryTapped(_ sender: Any) {
        presentActivityHistoryController()
    }
    
    
    @IBAction func addTapped(_ sender: Any) {
        if !credentialsAreValid() { return }
        
        let dg = DispatchGroup()
        self.getData(dg: dg)

        dg.notify(queue: .main, execute: {
            let activityName = self.activityNameField.text
            let numCalories = self.numCaloriesField.text

            let data: [String : Any] = [
                "name": activityName!,
                "numCalories": Int(numCalories!)!,
                "date": Date().toString()
            ]

            let dg2 = DispatchGroup()
            dg2.enter()
            self.activityData.append(data)
            self.db.collection("User").document(UserService.user.email).setData(["activity": self.activityData] , merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    dg2.customLeave()
                } else {
                    print("Document successfully written!")
                    dg2.customLeave()
                }
            }
            dg2.notify(queue: .main, execute: {
                self.clearTextFields()
                self.setLabels()
            })
        })
    }
}

extension ActivityController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

   /**
    * Called when the user click on the view (outside the UITextField).
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
