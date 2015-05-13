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
    
    override init() {
        let defaults = NSUserDefaults.standardUserDefaults()
        self.scopeIndex = defaults.integerForKey(scopeIndexKey)
        super.init()
    }
    
    static func sharedApplicationState() -> ApplicationState {
        return _SingletonSharedInstance
    }
    
    func saveApplicationState() {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(self.scopeIndex, forKey: self.scopeIndexKey)
        defaults.synchronize()
    }
    
}
