//
//  SleepController.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 1/27/21.
//

import UIKit
import FirebaseFirestore

class SleepController: UIViewController {

    @IBOutlet weak var summeryLabel: UILabel!
    @IBOutlet weak var sleepTodayLabel: UILabel!
    @IBOutlet weak var sleepThisWeekLabel: UILabel!
    @IBOutlet weak var hoursSleptField: UITextField!
    
    let db = Firestore.firestore()
    var sleepData: [[String: Any]] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        setTextFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setLabels()
    }
    
    func setTextFields() {
        hoursSleptField.delegate = self
    }
    
    func setLabels() {
        summeryLabel.text = "\( UserService.user.name)'s Sleep Summery"
        
        
        var sleepToday = 0
        var sleepThisWeek = 0

        for slp in UserService.user.sleep{
            
            let dateStr = slp["date"] as! String
            let date = dateStr.toDate()
            if date.isToday {
                sleepToday += slp["quantity"] as! Int
            }
        }
        for slp in UserService.user.sleep {
            let dateStr = slp["date"] as! String
            let date = dateStr.toDate()
            if date.isDayInCurrentWeek {
                sleepThisWeek += slp["quantity"] as! Int
            }
        }
        
        self.sleepTodayLabel.text = "\(sleepToday) hours"
        self.sleepThisWeekLabel.text = "\(sleepThisWeek) hours"
    }
    
    func clearTextFields() {
        hoursSleptField.text = ""
    }
    
    func credentialsAreValid() -> Bool {
        if (hoursSleptField.text!.isEmpty) {
            let message = "Must enter a quantity"
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
                self.sleepData = docData["sleep"] as! [[String : Any]]
                dg.customLeave()
            }
            else {
                self.displayError(title: "Error", message: "Document dose not exist")
                dg.customLeave()
            }
        }
    }
    
    func presentSleepHistoryController() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SleepHistoryController") as! SleepHistoryController
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func viewHistoryTapped(_ sender: Any) {
        presentSleepHistoryController()
    }

    @IBAction func addTapped(_ sender: Any) {
        if !credentialsAreValid() { return }
        
        let dg = DispatchGroup()
        self.getData(dg: dg)
        
        dg.notify(queue: .main, execute: {
            let quanity = self.hoursSleptField.text
            
            let data: [String : Any] = [
                "quantity": Int(quanity!),
                "date": Date().toString()
            ]
            
            let dg2 = DispatchGroup()
            dg2.enter()
            self.sleepData.append(data)
            self.db.collection("User").document(UserService.user.email).setData(["sleep": self.sleepData] , merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
                dg2.customLeave()
            }
            dg2.notify(queue: .main, execute: {
                self.clearTextFields()
                self.setLabels()
            })
        })
    }
}

extension SleepController: UITextFieldDelegate {
    
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




