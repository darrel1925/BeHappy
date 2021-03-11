//
//  CaloriesController.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 1/27/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class CaloriesController: UIViewController {

    @IBOutlet weak var summeryLabel: UILabel!
    @IBOutlet weak var caloriesTodayLabel: UILabel!
    @IBOutlet weak var caloriesThisWeekLabel: UILabel!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var foodField: UITextField!
    @IBOutlet weak var numCaloriesField: UITextField!
    
    let db = Firestore.firestore()
    var calorieData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
    }

    override func viewDidAppear(_ animated: Bool) {
        setLabels()
    }
    
    func setTextFields() {
        quantityField.delegate = self
        numCaloriesField.delegate = self
    }
    
    func setLabels() {
        summeryLabel.text = "\(UserService.user.name)'s Calorie Summery"
        
        
        var caloriesToday = 0
        var caloriesThisWeek = 0

        for calorie in UserService.user.calories{
            let dateStr = calorie["date"] as! String
            let date = dateStr.toDate()
            if date.isToday {
                caloriesToday += calorie["numCalories"] as! Int
            }
        }
        
        for calorie in UserService.user.calories {
            let dateStr = calorie["date"] as! String
            let date = dateStr.toDate()
            if date.isDayInCurrentWeek {
                caloriesThisWeek += calorie["numCalories"] as! Int
            }
        }
        
        self.caloriesTodayLabel.text = "\(caloriesToday) cals"
        self.caloriesThisWeekLabel.text = "\(caloriesThisWeek) cals"
        
    }
    
    
    func clearTextFields() {
        quantityField.text = ""
        foodField.text = ""
        numCaloriesField.text = ""
    }
    
    func credentialsAreValid() -> Bool {
        if (quantityField.text!.isEmpty) {
            let message = "Must enter a quantity"
            self.displayError(title: "Whoops.", message: message)
            return false
        }
        else if (foodField.text!.isEmpty) {
            let message = "Must enter a food name"
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
        // make a reference to the portion of the data base we want to query
        let docRef = db.collection("User").document(UserService.user.email)
        // lock the dispatch group
        dg.enter()
        
        // request the data from the above-referenced portion of the database
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let docData = document.data() ?? [:]
                // save data if we are able to query it
                self.calorieData = docData["calories"] as! [[String : Any]]
                // unlock the dispatch group
                dg.customLeave()
            }
            else {
                // print error is we are not able to query the data base
                self.displayError(title: "Error", message: "Document dose not exist")
                
                // unlock the dispatch group
                dg.customLeave()
            }
        }
    }
    
    func presentCalorieHistoryController() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CalorieHistoryController") as! CalorieHistoryController
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func viewHistoryTapped(_ sender: Any) {
        presentCalorieHistoryController()
    }
    
    
    @IBAction func addTapped(_ sender: Any) {
        if !credentialsAreValid() { return }
        
        // used for synchronous requests
        let dg = DispatchGroup()
        self.getData(dg: dg)
        
        // wait to fetch calorie info from database
        dg.notify(queue: .main, execute: {
            let quanity = self.quantityField.text
            let food = self.foodField.text
            let numCalories = self.numCaloriesField.text
            
            // format new dictionary for database
            let data: [String : Any] = [
                "quantity": Int(quanity!),
                "food": food!,
                "numCalories": Int(numCalories!),
                "date": Date().toString()
            ]
            
            // used for synchronous requests
            let dg2 = DispatchGroup()
            dg2.enter()
            self.calorieData.append(data)
            
            // Send updated calori info to database
            self.db.collection("User").document(UserService.user.email).setData(["calories": self.calorieData] , merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                    dg2.customLeave()
                } else {
                    print("Document successfully written!")
                    dg2.customLeave()
                }
            }
            
            // Wait for data to be sent to database
            dg2.notify(queue: .main, execute: {
                self.clearTextFields()
                self.setLabels()
            })
        })
    }
}

extension CaloriesController: UITextFieldDelegate {
    
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
