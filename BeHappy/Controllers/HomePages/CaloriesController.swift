//
//  CaloriesController.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 1/27/21.
//

import UIKit
import FirebaseFirestore

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
    
    func setLabels() {
        summeryLabel.text = "\( UserService.user.name)'s Calorie Summery"
        
        
        var caloriesToday = 0
        var caloriesThisWeek = 0

        for calorie in UserService.user.calories{
            let dateStr = calorie["date"] as! String
            let date = dateStr.toDate()
            if date.recivedUnderOneDayAgo {
                caloriesToday += calorie["numCalories"] as! Int
            }
        }
        
        for calorie in UserService.user.calories {
            let dateStr = calorie["date"] as! String
            let date = dateStr.toDate()
            if !date.isOverOneWeekOld {
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
        let docRef = db.collection("User").document(UserService.user.email)
        dg.enter()
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let docData = document.data() ?? [:]
                print("docData \n\n\n \(docData) \n\n\n")
                self.calorieData = docData["calories"] as! [[String : Any]]
                dg.customLeave()
            }
            else {
                self.displayError(title: "Error", message: "Document dose not exist")
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
        
        let dg = DispatchGroup()
        self.getData(dg: dg)
        
        dg.notify(queue: .main, execute: {
            let quanity = self.quantityField.text
            let food = self.foodField.text
            let numCalories = self.numCaloriesField.text
            
            let data: [String : Any] = [
                "quantity": Int(quanity!),
                "food": food!,
                "numCalories": Int(numCalories!),
                "date": Date().toString()
            ]
            
            self.calorieData.append(data)
            self.db.collection("User").document(UserService.user.email).setData(["calories": self.calorieData] , merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            self.clearTextFields()
            self.setLabels()
        })
    }
}


