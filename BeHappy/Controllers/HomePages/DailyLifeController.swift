//
//  DailyLifeController.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 1/27/21.
//

import UIKit

class DailyLifeController: UIViewController {

    @IBOutlet weak var happinessScoreLabel: UILabel!
    @IBOutlet weak var calorieIntakeLabel: UILabel!
    @IBOutlet weak var hoursSleptLabel: UILabel!
    @IBOutlet weak var caloriesBurnedLabel: UILabel!
    @IBOutlet weak var suggestionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setLabels()
    }
    
    func setLabels() {
        calorieIntakeLabel.text = "\(todaysCalorieIntake()) cals"
        hoursSleptLabel.text = "\(todaysSleepIntake()) hours"
        caloriesBurnedLabel.text = "\(todaysCaloriesBurned()) burned"
        happinessScoreLabel.text = "\(happinessScore())"
        
        if happinessScore() > 90 {
            suggestionLabel.text = "Your doing great, keep up the great work by maintiaing a good diet and regular exercise!"
            return
        }
        else if happinessScore() < 20 {
            suggestionLabel.text = "Your score is lower than expected! Try to focus of achieving your set goals this week!"
            return
        }
        else {
            if getCalorieScore() < 20 {
                suggestionLabel.text = "Your calorie intake is over your goal. Try to cut back on calories this week!"
                return
            }
            if getSleepScore() < 20 {
                suggestionLabel.text = "Your sleep is under your goal. Try to get to bed early!"
                return
            }
            if getActivityScore() < 20 {
                suggestionLabel.text = "Your activity is is under your goal. Try to get in some exrta exercise this week!"
                return
            }
        }
    }
    
    func todaysCalorieIntake() -> Int {
        var caloriesToday = 0

        for calorie in UserService.user.calories{
            let dateStr = calorie["date"] as! String
            let date = dateStr.toDate()
            if date.isToday {
                caloriesToday += calorie["numCalories"] as! Int
            }
        }
        return caloriesToday
    }
    
    func todaysSleepIntake() -> Int {
        var sleepToday = 0

        for slp in UserService.user.sleep{
            
            let dateStr = slp["date"] as! String
            let date = dateStr.toDate()
            if date.isToday {
                sleepToday += slp["quantity"] as! Int
            }
        }
        return sleepToday
    }
    
    func todaysCaloriesBurned() -> Int {
            var avticityLabel = 0
        if UserService.user.activity.count == 0 {
            return 0
        }
        else {
            return UserService.user.activity[0]["numCalories"] as! Int
        }
    }
    
    func getCalorieScore() -> Double{
        var total = Double(0)
        
        for val in UserService.user.calories{
            
            let dateStr = val["date"] as! String
            let date = dateStr.toDate()
            if date.isDayInCurrentWeek {
                total += Double(val["numCalories"] as! Int)
            }
        }
        let avg_calories = Double(total)/Double(7)
        print("total  \(total)")
        print("avg_calories  \(avg_calories)")
        let diff_in_goal = abs(Double(avg_calories) - Double(UserService.user.calorieGoal))
        print("diff_in_goal  \(diff_in_goal) : \(UserService.user.calorieGoal)")

        let percentage_difference = 1 - (diff_in_goal/Double(UserService.user.calorieGoal))
        print("percentage_difference  \(percentage_difference)")
        let score = (percentage_difference * 33)
            
        return score
    }
    
    func getSleepScore() -> Double{
        var total = Double(0)
        
        
        for val in UserService.user.sleep{
            
            let dateStr = val["date"] as! String
            let date = dateStr.toDate()
            if date.isDayInCurrentWeek {
                total += Double(val["quantity"] as! Int)
            }
        }
        let avg_calories = Double(total)/Double(7)
        let diff_in_goal = abs(Double(avg_calories) - Double(UserService.user.sleepGoal))

        let percentage_difference = 1 - (diff_in_goal/Double(UserService.user.sleepGoal))
        let score = (percentage_difference * 33)
        
        return score
    }
    
    
    func getActivityScore() -> Double{
        var total = Double(0)
        
        
        for val in UserService.user.activity{
            
            let dateStr = val["date"] as! String
            let date = dateStr.toDate()
            if date.isDayInCurrentWeek {
                total += Double(val["numCalories"] as! Int)
            }
        }
        let avg_calories = Double(total)/Double(7)
        let diff_in_goal = abs(Double(avg_calories) - Double(UserService.user.activityGoal))

        let percentage_difference = (diff_in_goal/Double(UserService.user.activityGoal))
        let score = (percentage_difference * 33)
//        print("Act \(percentage_difference)  || \(()" )
        if score > 30 {
            return 16
        }
        return score
    }
    
    func happinessScore() -> Int{
        print("Cal Score      \(getCalorieScore())")
        print("Sleep Score    \(getSleepScore())")
        print("Activity Score \(getActivityScore())")
        return Int(getCalorieScore() + getSleepScore() + getActivityScore() + 1)
    }
    
    func presentBMIHeathInfo() {
        let vc = HappinessCalController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func scoreButtonTapped(_ sender: Any) {
        presentBMIHeathInfo()
    }
}
