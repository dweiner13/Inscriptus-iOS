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
        let defaults = NSUserDefaults.standardUserDefaults()
        let storedCache: NSData? = defaults.objectForKey(DEFAULTS_CACHE_KEY) as! NSData?
        if let savedData = storedCache {
            self.items = NSKeyedUnarchiver.unarchiveObjectWithData(savedData) as! Set<WhitakerResult>
        }
        else {
            self.items = Set<WhitakerResult>()
        }
    }
    
    class var sharedCache : WhitakerCache {
        return _SingletonSharedInstance
    }
    
    func saveCache() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(self.items), forKey: DEFAULTS_CACHE_KEY)
        defaults.synchronize()
    }
    
    func addItem(item: WhitakerResult) {
        self.items.insert(item)
    }
    
    func clear() {
        self.items.removeAll(keepCapacity: false)
    }
    
    func containsResultForWord(word: String) -> Bool {
        for item: WhitakerResult in self.items {
            if item.word == word {
                return true
            }
        }
        return false
    }
    
    func resultForWord(word: String) -> WhitakerResult! {
        for item: WhitakerResult in self.items {
            if item.word == word {
                return item
            }
        }
        
        return nil
    }
    
}
