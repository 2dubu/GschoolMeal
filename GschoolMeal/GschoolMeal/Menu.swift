//
//  Menu.swift
//  GschoolMeal
//
//  Created by 이건우 on 2022/03/14.
//

import Foundation
import FirebaseFirestore

class MenuData {
    static let shared = MenuData()
    
    var lunchMenuData = [String : String]()
    var dinnerMenuData = [String : String]()
    
    private init() {}
}

let db = Firestore.firestore()
var lunchMenuData: [String : String] = [:]

func getMenuData(completion: @escaping () -> Void) {
    let lunchDocRef = db.collection("mealData").document("lunchData")
    let dinnerDocRef = db.collection("mealData").document("dinnerData")
    
    lunchDocRef.getDocument { (document, error) in
        if let document = document, document.exists {
            for (key, value) in document.data()! {
                // lunchMenuData.updateValue(value as! String, forKey: key)
                MenuData.shared.lunchMenuData[key] = value as? String
            }
        } else {
            print("Document does not exist")
        }
        
        dinnerDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                for (key, value) in document.data()! {
                    MenuData.shared.dinnerMenuData[key] = value as? String
                }
            } else {
                print("Document does not exist")
            }
            completion()
        }
    }
}
