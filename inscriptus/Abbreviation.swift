//
//  Abbreviation.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class Abbreviation: NSObject, CustomDebugStringConvertible {
    
    // MARK: - Properties
    
    // The text to display (the abbreviation itself, e.g. SPQR). Null if image.
    let displayText: String?
    
    // The definition (the long version, e.g. senatus populusque romanus")
    let longText: String
    
    // The name of the image file to display if it exists
    let displayImage: String?
    
    // A set of plaintext, searchable representations of the abbreviation
    // May not exist if the abbreviation, like SPQR, is already searchable
    let searchStrings: Set<String>?
    
    // True if it's a special character or image abbreviation
    let isSpecial: Bool
    
    // not really useful, in fact completely useless
    let id: Int
    
    // Unique string used to compare abbreviations
    var uniqueString: String {
        get {
            var str: String = ""
            if let displayText = self.displayText {
                str += displayText
            }
            if let displayImage = self.displayImage {
                str += displayImage
            }
            return str + self.longText
        }
    }
    
    // MARK: - Methods
    
    // TODO: can this just compare IDs? is the unique string necessary?
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? Abbreviation {
            return self.uniqueString.compare(object.uniqueString) == .OrderedSame
        } else {
            return false
        }
    }
    
    // Get a debug description of this object
    override var description: String {
        get {
            var outputString = "<"
            if let displayText = self.displayText {
                outputString += "displayText: " + displayText + ", "
            }
            outputString += "id: " + String(self.id) + ", "
            outputString += "longText: " + self.longText + ", "
            if let displayImage = self.displayImage {
                outputString += "displayImage: " + displayImage + ", "
            }
            outputString += "searchStrings: \(self.searchStrings) , "
            outputString += ">"
            return outputString
        }
    }
    
    init(displayText: String?, id: Int, longText: String, displayImageName: String?, searchStrings: Array<String>, isSpecial: Bool) {
        self.displayText = displayText
        self.id = id
        self.longText = longText
        self.isSpecial = isSpecial
        
        if let imageName = displayImageName {
            self.displayImage = imageName
        }
        else {
            self.displayImage = nil
        }
        
        if !(searchStrings[0].compare("") == .OrderedSame) {
            self.searchStrings = Set(searchStrings)
        }
        else {
            self.searchStrings = nil
        }
        
        super.init()
    }
    
    convenience init(JSONDict: NSDictionary) {
        var abbrDisplay: NSString?
        if JSONDict["iosDisplay"] != nil {
            abbrDisplay = JSONDict["iosDisplay"] as? NSString
        }
        else {
            abbrDisplay = JSONDict["abbrDisplay"] as? NSString
        }
        
        let id = Int((JSONDict["id"] as! String?)!)!
        let phrase = JSONDict["phrase"] as! NSString
        let displayImage = JSONDict["abbrDisplayImage"] as! NSString?
        let isSpecial = JSONDict["isSpecial"] as! Bool
        
        // Get array from abbrSearchList
        let abbrSearchList = JSONDict["abbrSearchList"] as! NSArray

        self.init(displayText: abbrDisplay as String?, id: id, longText: phrase as String, displayImageName: displayImage as String?, searchStrings: abbrSearchList as! Array<String>, isSpecial: isSpecial)
    }
    
    // Turn the array of search strings into a UI-ready human-redable string
    func searchStringsAsReadableString() -> String? {
        if let searchStrs = self.searchStrings {
            var str = ""
            var i = 0
            for searchString in searchStrs {
                if i == searchStrs.count - 1 {
                    str += searchString
                }
                else {
                    str += "\(searchString), "
                }
                i += 1
            }
            return str
        }
        else {
            return nil
        }
    }
}