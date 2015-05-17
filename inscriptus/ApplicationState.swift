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
    
    let NSDEFAULTS_KEY = "applicationState"
    
    var scopeIndex: Int
    let scopeIndexKey = "allScopeIndex"
    
    var holdCoachHidden: Bool
    let holdCoachHiddenKey = "holdCoachHidden"
    
    var lookupCoachHidden: Bool
    let lookupCoachHiddenKey = "lookupCoachHidden"
    
    var specialCoachHidden: Bool
    let specialCoachHiddenKey = "specialCoachHidden"
    
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
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(self.scopeIndex, forKey: self.scopeIndexKey)
        defaults.setBool(self.holdCoachHidden, forKey: self.holdCoachHiddenKey)
        defaults.setBool(self.lookupCoachHidden, forKey: self.lookupCoachHiddenKey)
        defaults.setBool(self.specialCoachHidden, forKey: self.specialCoachHiddenKey)
        defaults.synchronize()
    }
    
}
