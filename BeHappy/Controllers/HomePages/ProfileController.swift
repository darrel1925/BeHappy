//
//  ProfileController.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 2/24/21.
//

import UIKit
import FirebaseAuth
import HealthKit

class ProfileController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let userHealthProfile = UserHealthProfile()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = "Profile Summery"
        setUpTableView()
        authorizeHealthKit()
        loadAndDisplayAgeSexAndBloodType()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadAndDisplayAgeSexAndBloodType()
    }
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func presentSignOut() {
        let alert = UIAlertController(title: "Sign Out", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Sign Out", style: .default, handler: {_ in
            self.logOut()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {_ in
            
        })
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func presentHomePage() {
        let tabViewController = storyboard!.instantiateViewController(withIdentifier: "SplashScreenController") as! SplashScreenController   
        tabViewController.modalPresentationStyle = .fullScreen
        present(tabViewController, animated: true, completion: nil)
    }
    
    func presentBMIHeathInfo() {
        let healthKitVC = HealthKitController()
        healthKitVC.modalPresentationStyle = .overFullScreen
        healthKitVC.userHealthProfile = self.userHealthProfile
        self.present(healthKitVC, animated: true, completion: nil)
    }
    
    func logOut() {
        do
           {
               try Auth.auth().signOut()
                
                self.presentHomePage()
           }
           catch let error as NSError
           {
               print(error.localizedDescription)
           }
    }
    
    
}

extension ProfileController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return 1
        case 1:
            return 5
        case 2:
            return 1
        case 3:
            return 2
        case 4:
            return 1
        default:
            return 10
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTitleCell") as! ProfileTitleCell
            cell.titleLabel.text = "Darrel's Info"
            return cell
        case 1:
            switch row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePlainSubTitleCell") as! ProfilePlainSubTitleCell
                cell.nameLabel.text = "Email"
                cell.valueLabel.text = UserService.user.email
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePlainSubTitleCell") as! ProfilePlainSubTitleCell
                cell.nameLabel.text = "Gender"
                cell.valueLabel.text = UserService.user.gender
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePlainSubTitleCell") as! ProfilePlainSubTitleCell
                cell.nameLabel.text = "Age"
                cell.valueLabel.text = UserService.user.age
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePlainSubTitleCell") as! ProfilePlainSubTitleCell
                cell.nameLabel.text = "DOB"
                cell.valueLabel.text = UserService.user.dob
                return cell
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePlainSubTitleCell") as! ProfilePlainSubTitleCell
                cell.nameLabel.text = "Weight"
                cell.valueLabel.text = "\(UserService.user.weight) lbs"
                return cell
                
            default:
                UITableViewCell()
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTitleCell") as! ProfileTitleCell
            cell.titleLabel.text = "Additional Info"
            return cell
        case 3:
            switch row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePlainSubTitleCell") as! ProfilePlainSubTitleCell
                cell.nameLabel.text = "Favorite Places"
                cell.valueLabel.text = "None"
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSubTitleCell") as! ProfileSubTitleCell
                cell.nameLabel.text = "BMI & Health Info"
                cell.nameLabel.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
                cell.valueLabel.text = ""
                return cell
            default:
                return UITableViewCell()
            }
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileSubTitleCell") as! ProfileSubTitleCell
            cell.nameLabel.text = "Sign Out"
            cell.valueLabel.text = ""
            cell.nameLabel.textColor = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
            return cell
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 3:
            if row == 1 { presentBMIHeathInfo() }
        case 4:
            presentSignOut()
        default:
            print("Error")
        }
            
    }
    
}

extension ProfileController {
    

    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        //1. Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HKError.init(.errorHealthDataUnavailable) )
          return
        }
        
        //2. Prepare the data types that will interact with HealthKit
        guard   let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
                let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
                let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
                let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
                let height = HKObjectType.quantityType(forIdentifier: .height),
                let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
                let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
                
                completion(false, HKError.init(.errorHealthDataUnavailable))
                return
        }
        //3. Prepare a list of types you want HealthKit to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                        activeEnergy,
                                                        HKObjectType.workoutType()]
            
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       bodyMassIndex,
                                                       height,
                                                       bodyMass,
                                                       HKObjectType.workoutType()]

        //4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) in
          completion(success, error)
        
        }
    }
    
    
    
    func authorizeHealthKit() {
        authorizeHealthKit { (authorized, error) in
              
          guard authorized else {
                
            let baseMessage = "HealthKit Authorization Failed"
                
            if let error = error {
              print("\(baseMessage). Reason: \(error.localizedDescription)")
            } else {
              print(baseMessage)
            }
                
            return
          }
              
          print("HealthKit Successfully Authorized.")
        }
    }
    
    
    
    func getAgeSexAndBloodType() throws -> (age: Int,
                                                  biologicalSex: HKBiologicalSex,
                                                  bloodType: HKBloodType
                                                        ) {
        
      let healthKitStore = HKHealthStore()
        
      do {

        //1. This method throws an error if these data are not available.
        let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
        let biologicalSex =       try healthKitStore.biologicalSex()
        let bloodType =           try healthKitStore.bloodType()

    
          
        //2. Use Calendar to calculate age.
        let today = Date()
        let calendar = Calendar.current
        let todayDateComponents = calendar.dateComponents([.year],
                                                            from: today)
        let thisYear = todayDateComponents.year!
        let age = thisYear - birthdayComponents.year!
         
        //3. Unwrap the wrappers to get the underlying enum values.
        let unwrappedBiologicalSex = biologicalSex.biologicalSex
        let unwrappedBloodType = bloodType.bloodType
//          
//        print(age)
//        print(unwrappedBiologicalSex)
//        print(unwrappedBloodType)
//
        if let weight = userHealthProfile.weightInKilograms {
          let weightFormatter = MassFormatter()
          weightFormatter.isForPersonMassUse = true
          print(weightFormatter.string(fromKilograms: weight))
        }
            
        if let height = userHealthProfile.heightInMeters {
          let heightFormatter = LengthFormatter()
          heightFormatter.isForPersonHeightUse = true
          print(heightFormatter.string(fromMeters: height))
        }
           
        if let bodyMassIndex = userHealthProfile.bodyMassIndex {
          print(String(format: "%.02f", bodyMassIndex))
        }
        
        return (age, unwrappedBiologicalSex, unwrappedBloodType)
      }
    }

    func loadAndDisplayAgeSexAndBloodType() {
        do {
            let userAgeSexAndBloodType = try getAgeSexAndBloodType()
          userHealthProfile.age = userAgeSexAndBloodType.age
          userHealthProfile.biologicalSex = userAgeSexAndBloodType.biologicalSex
          userHealthProfile.bloodType = userAgeSexAndBloodType.bloodType
          
        } catch let error {
            print(error.localizedDescription)
        }
        self.getWeightInfo()
        self.getHeightInfo()
        
        if let age = userHealthProfile.age {
          print("\(age)")
        }

        if let biologicalSex = userHealthProfile.biologicalSex {
            print(biologicalSex.rawValue)
        }

        if let bloodType = userHealthProfile.bloodType {
            print(bloodType.rawValue)
        }
    }
    
    
    
    func getMostRecentSample(for sampleType: HKSampleType,
                                   completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
          
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
            
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
            
        let limit = 1
            
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            //2. Always dispatch to the main thread when complete.
            DispatchQueue.main.async {
                
              guard let samples = samples,
                    let mostRecentSample = samples.first as? HKQuantitySample else {
                        
                    completion(nil, error)
                    return
              }
                
              completion(mostRecentSample, nil)
            }
          }
         
        HKHealthStore().execute(sampleQuery)
    }
    
    func getHeightInfo() {
        //1. Use HealthKit to create the Height Sample Type
        guard var heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
          print("Height Sample Type is no longer available in HealthKit")
          return
        }
        print(heightSampleType)
            
        getMostRecentSample(for: heightSampleType) { (sample, error) in
              
          guard let sample = sample else {
              
            if let error = error {
                print(error.localizedDescription)
            }
                
            return
          }
            
//        print(sample)
          //2. Convert the height sample to meters, save to the profile model,
          //   and update the user interface.
          let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
          self.userHealthProfile.heightInMeters = heightInMeters
            print("done \n\n\n")
            print(heightInMeters)
        }
    }
    
    func getWeightInfo(){
        
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
          print("Body Mass Sample Type is no longer available in HealthKit")
          return
        }
        print(weightSampleType)
        getMostRecentSample(for: weightSampleType) { (sample, error) in
              
          guard let sample = sample else {
                
            if let error = error {
                print(error.localizedDescription)
            }
            return
          }
            print(sample)
          let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
          self.userHealthProfile.weightInKilograms = weightInKilograms
            print("continue \n\n\n")
            print(weightInKilograms)
        }
    }
}
