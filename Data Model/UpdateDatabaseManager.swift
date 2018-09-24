//
//  UpdateDbManager.swift
//  Story
//
//  Created by Niraj Jha on 24/09/18.
//  Copyright © 2018 home. All rights reserved.
//

import UIKit

class UpdateDatabaseManager: NSObject {
    static let shared = UpdateDatabaseManager()
    private let defaults = UserDefaults.standard
    
    func checkIfLoadRequired()->Bool {
        if isUpdateNeeded() {
            defaults.set(Date(), forKey: "LASTUPDATE")
            return true
        }
        else {
            return false
        }
    }
    
    private func isUpdateNeeded() -> Bool {
        guard let lastUpdateDate = defaults.object(forKey: "LASTUPDATE") as? Date else {
            return true
        }
       
        if let diff = Calendar.current.dateComponents([.hour], from: lastUpdateDate, to: Date()).hour, diff > 24 {
            return true
        }
        else {
            return false
        }
    }
}
