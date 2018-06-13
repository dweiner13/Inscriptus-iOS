//
//  WhitakersCache.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 5/19/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

private let _SingletonSharedInstance = WhitakerCache()
private let DEFAULTS_CACHE_KEY = "whitakersCache"

class WhitakerCache {
   
    var items: Set<WhitakerResult>
    
    init() {
        let defaults = UserDefaults.standard
        let storedCache: Data? = defaults.object(forKey: DEFAULTS_CACHE_KEY) as! Data?
        if let savedData = storedCache {
            self.items = NSKeyedUnarchiver.unarchiveObject(with: savedData) as! Set<WhitakerResult>
        }
        else {
            self.items = Set<WhitakerResult>()
        }
    }
    
    class var sharedCache : WhitakerCache {
        return _SingletonSharedInstance
    }
    
    func saveCache() {
        let defaults = UserDefaults.standard
        defaults.set(NSKeyedArchiver.archivedData(withRootObject: self.items), forKey: DEFAULTS_CACHE_KEY)
        defaults.synchronize()
    }
    
    func addItem(_ item: WhitakerResult) {
        self.items.insert(item)
    }
    
    func clear() {
        self.items.removeAll(keepingCapacity: false)
    }
    
    func containsResultForWord(_ word: String) -> Bool {
        for item: WhitakerResult in self.items {
            if item.word == word {
                return true
            }
        }
        return false
    }
    
    func resultForWord(_ word: String) -> WhitakerResult! {
        for item: WhitakerResult in self.items {
            if item.word == word {
                return item
            }
        }
        
        return nil
    }
    
}
