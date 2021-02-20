//
//  User.swift
//  BeHappy
//
//  Created by Darrel Muonekwu on 1/26/21.
//
import FirebaseAuth
import FirebaseFirestore

class User {
    var age: String

    var id: String
    var name: String
    var email: String
    var height: String
    var homeAddress: String
    var workAddress: String
    var weight: String
    var dob: String
    var gender: String
    var favoritePlace: String
    
    var dailyActivity: [String: Int]
    var activity: [[String: Any]]
    var calories: [[String: Any]]
    var dailyLife: [[String: Any]]
    var sleep: [[String: Any]]
    
    
    
    // User is Signing Up
    init(id: String = "", name: String = "", email: String = "",
         height: String = "", homeAddress: String = "", workAddress: String = "",
         weight: String = "", dob: String = "", gender: String = "", age: String = "",
         favoritePlace: String = "", activity: [[String: Any]] = [], calories: [[String: Any]] = [],
         dailyLife: [[String: Any]] = [], sleep: [[String: Any]] = [], dailyActivity: [String:Int] = [:]) {
        
        self.age = age
        self.id = id
        self.name = name
        self.email = email
        self.height = height
        self.homeAddress = homeAddress
        self.workAddress = workAddress
        self.weight = weight
        self.dob = dob
        self.gender = gender
        self.favoritePlace = favoritePlace
        self.dailyActivity = dailyActivity
        
        self.activity = activity
        self.calories = calories
        self.dailyLife = dailyLife
        self.sleep = sleep

    }
    
    // User is Logging In
    init(data: [String: Any]) {
        self.age = data["age"] as? String ?? ""
        self.id = data["id"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.height = data["height"] as? String ?? ""
        self.homeAddress = data["homeAddress"] as? String ?? ""
        self.workAddress = data["workAddress"] as? String ?? ""
        self.weight = data["weight"] as? String ?? ""
        self.dob = data["dob"] as? String ?? ""
        self.gender = data["gender"] as? String ?? ""
        self.favoritePlace = data["favoritePlace"] as? String ?? ""
        self.dailyActivity = data["dailyActivity"] as? [String: Int] ?? [:]
        
        self.activity = data["activity"] as? [[String: Any]] ?? []
        self.calories = data["calories"] as? [[String: Any]] ?? []
        self.dailyLife = data["dailyLife"] as? [[String: Any]] ?? []
        self.sleep = data["sleep"] as? [[String: Any]] ?? []
    }
    
    // Sending user data to Firebase
    static func modelToData(user: User) -> [String: Any] {
        let data : [String: Any] = [
            "age": user.age,
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "height": user.height,
            "homeAddress": user.homeAddress,
            "workAddress": user.workAddress,
            "weight": user.weight,
            "dob": user.dob,
            "gender": user.gender,
            "favoritePlace": user.favoritePlace,
            "dailyActivity": user.dailyActivity,
            
            "activity": user.activity,
            "calories": user.calories,
            "dailyLife": user.dailyLife,
            "sleep": user.sleep
        ]
        
        return data
    }
}
