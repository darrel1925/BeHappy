//
//  HealthKitController.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 3/3/21.
//

import UIKit

class HealthKitController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: RoundedView!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var bloodTypeLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    
    var userHealthProfile: UserHealthProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGestures()
        animateViewDownward()
        setLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateViewUpwards()
    }
    
    func setUpGestures() {
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        let swipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipe.direction = .down
        backgroundView.addGestureRecognizer(swipe)
    }
    
    func setLabels() {
        
        if let age = userHealthProfile.age {
          ageLabel.text = "\(age)"
        }

        if let biologicalSex = userHealthProfile.biologicalSex {
          sexLabel.text = "\(biologicalSex.rawValue)"
        }

        if let bloodType = userHealthProfile.bloodType {
            bloodTypeLabel.text = "O-"
        }
        
        if let weight = userHealthProfile.weightInKilograms {
          let weightFormatter = MassFormatter()
          weightFormatter.isForPersonMassUse = true
          weightLabel.text = weightFormatter.string(fromKilograms: weight)
        }
            
        if let height = userHealthProfile.heightInMeters {
          let heightFormatter = LengthFormatter()
          heightFormatter.isForPersonHeightUse = true
          heightLabel.text = heightFormatter.string(fromMeters: height)
        }
           
        if let bodyMassIndex = userHealthProfile.bodyMassIndex {
            bmiLabel.text = String(format: "%.02f", bodyMassIndex)
        }
        
    }
    
    func animateViewUpwards() {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let height: CGFloat = containerView.frame.height
        let y = window.frame.height - height
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.backgroundView.alpha = 0.3
            self.containerView.frame = CGRect(x: 0, y: y, width: window.frame.width, height: height)
            
        }, completion: nil)
    }
    
    func animateViewDownward() {
        backgroundView.alpha = 0
        guard let window = UIApplication.shared.keyWindow else { return }
        containerView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 0)
    }
    
    @objc func handleDismiss() {
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.backgroundView.alpha = 0
            
        }, completion: {_ in
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.dismiss(animated: true, completion: nil)
                
            }, completion: nil)
        })
    }
    @IBAction func dismissTapped(_ sender: Any) {
        handleDismiss()
    }
    
}
