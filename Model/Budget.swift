//
//  Budget.swift
//  ispentmoney
//
//  Created by Kyle Stokes on 7/7/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import Foundation

// MARK: Properties

struct Budget {
    var id: String?
    var name: String?
    var setAmount: Double?
    var spent: Double?
    var left: Double?
    var createdBy: String?
    var sharedWith: [String]?
    var hiddenFrom: [String]?
    var isShared: Bool?
    var history: [String]?
    var userDate: [String]?
    
    static func from(firebase dictionary: [String:AnyObject], uid: String) -> Budget {
        var budget = Budget()
        budget.id = uid
        
        if let budgetName = dictionary["name"] as? String {
            budget.name = budgetName
        }
        
        if let budgetSetAmount = dictionary["setAmount"] as? Double {
            budget.setAmount = budgetSetAmount
        }
        
        if let spentAmount = dictionary["spent"] as? Double {
            budget.spent = spentAmount
        }
        
        if let amountLeft = dictionary["left"] as? Double {
            budget.left = amountLeft
        }
        
        if let budgetCreatedBy = dictionary["createdBy"] as? String {
            budget.createdBy = budgetCreatedBy
        }
        
        if let budgetSharedWith = dictionary["sharedWith"] as? [String] {
            budget.sharedWith = budgetSharedWith
        }
        
        if let budgetHiddenFrom = dictionary["hiddenFrom"] as? [String] {
            budget.hiddenFrom = budgetHiddenFrom
        }
        
        if let budgetIsShared = dictionary["isShared"] as? Bool {
            budget.isShared = budgetIsShared
        }
        
        if let budgetHistory = dictionary["history"] as? [String] {
            budget.history = budgetHistory
        }
        
        if let budgetUserDate = dictionary["userDate"] as? [String] {
            budget.userDate = budgetUserDate
        }
        
        return budget
    }
}
