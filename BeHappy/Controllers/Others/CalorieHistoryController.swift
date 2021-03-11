//
//  CalorieHistoryController.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 2/17/21.
//

import UIKit

class CalorieHistoryController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var containerView: RoundedView!
    
    var segmentIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentControl.selectedSegmentIndex = 2
        self.segmentIndex = 2
        
        setUpGestures()
        animateViewDownward()
        setUpTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateViewUpwards()
    }
    
    func setUpTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func setUpGestures() {
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipe.direction = .down
        backgroundView.addGestureRecognizer(swipe)
    }
    
    func animateViewUpwards() {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let height: CGFloat = containerView.frame.height
        let y = window.frame.height - height
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.backgroundView.alpha = 0.1
            self.containerView.frame = CGRect(x: 0, y: y, width: window.frame.width, height: height)
            
        }, completion: nil)
    }
    
    func animateViewDownward() {
        backgroundView.alpha = 0
        guard let window = UIApplication.shared.keyWindow else { return }
        containerView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 0)
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                print("case 0")
                self.segmentIndex = 0
            case 1:
                print("case 1")
                self.segmentIndex = 1
            case 2:
                print("case 2")
                self.segmentIndex = 2
            default:
                break;
        }
        self.tableView.reloadData()
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.backgroundView.alpha = 0
            
        }, completion: {_ in
            UIView.animate(withDuration: 0.15, delay: 1, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.dismiss(animated: true, completion: nil)
                
            }, completion: nil)
        })
    }
}

extension CalorieHistoryController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if self.segmentIndex == 0 {
            for calorie in UserService.user.calories {
                let dateStr = calorie["date"] as! String
                let date = dateStr.toDate()
                
                if date.isToday {
                    count = count + 1
                }
            }
            return count
        }
        else if self.segmentIndex == 1 {
            for calorie in UserService.user.calories {
                let dateStr = calorie["date"] as! String
                let date = dateStr.toDate()
                
                if date.isDayInCurrentWeek {
                    count = count + 1
                }
            }
            return count
        }
        else {
            return UserService.user.calories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var calories: [[String: Any]] = []
        
        if self.segmentIndex == 0 {
            for calorie in UserService.user.calories.reversed() {
                let dateStr = calorie["date"] as! String
                let date = dateStr.toDate()
                
                if date.isToday {
                    calories.append(calorie)
                }
            }
        }
        else if self.segmentIndex == 1 {
            for calorie in UserService.user.calories.reversed() {
                let dateStr = calorie["date"] as! String
                let date = dateStr.toDate()
                
                if date.isDayInCurrentWeek {
                    calories.append(calorie)
                }
            }
        }
        else {
            calories = UserService.user.calories.reversed()
        }
        
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalorieHistoryCell") as! CalorieHistoryCell
        let calorie = calories[row]

        print(calorie["food"])
        cell.selectionStyle = .none
        cell.nameLabel.text = calorie["food"] as? String
        cell.quantityLabel.text = "Quantity: \(calorie["quantity"] ?? "error")"
        cell.calorieLabel.text = "Cal: \(calorie["numCalories"] ?? "error")"
        
        let dateStr = calorie["date"] as! String
        let date = dateStr.toDate()
        
        if date.isDayInCurrentWeek {
            cell.dateLabel.text = date.toStringDayMonthMiunutes()
        }
        else {
            cell.dateLabel.text = date.toStringInWords()
        }
        
        return cell
    }
    
}
