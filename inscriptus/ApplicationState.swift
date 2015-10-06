//
//  ApplicationState.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 5/12/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

private let _SingletonSharedInstance = ApplicationState()

class ApplicationState: NSObject {
    
    // MARK: - Properties
    
    let NSDEFAULTS_KEY = "applicationState"
    
    // The selected index of the scope button control for the search
    var scopeIndex: Int
    let scopeIndexKey = "allScopeIndex"
    
    // Coach that tells the user to tap and hold to copy
    var holdCoachHidden: Bool
    let holdCoachHiddenKey = "holdCoachHidden"
    
    // Coach that tells the user to click definition button
    var lookupCoachHidden: Bool
    let lookupCoachHiddenKey = "lookupCoachHidden"
    
    // Coach that shows info about special chars screen
    var specialCoachHidden: Bool
    let specialCoachHiddenKey = "specialCoachHidden"
    
    // MARK: - Methods
    
    override init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        self.scopeIndex = defaults.integerForKey(scopeIndexKey)
        self.holdCoachHidden = defaults.boolForKey(holdCoachHiddenKey)
        self.lookupCoachHidden = defaults.boolForKey(lookupCoachHiddenKey)
        self.specialCoachHidden = defaults.boolForKey(specialCoachHiddenKey)
        super.init()
    }
    
    static func sharedApplicationState() -> ApplicationState {
        return _SingletonSharedInstance
    }
    
    func saveApplicationState() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(self.scopeIndex, forKey: self.scopeIndexKey)
        defaults.setBool(self.holdCoachHidden, forKey: self.holdCoachHiddenKey)
        defaults.setBool(self.lookupCoachHidden, forKey: self.lookupCoachHiddenKey)
        defaults.setBool(self.specialCoachHidden, forKey: self.specialCoachHiddenKey)
        defaults.synchronize()
    }
    
    func resetApplicationState() {
        self.scopeIndex = 0
        self.holdCoachHidden = false
        self.lookupCoachHidden = false
        self.specialCoachHidden = false
    }
}
