//
//  Abbreviation.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class Abbreviation: NSObject, Printable, DebugPrintable {
    
    let displayText: String?
    let longText: String
    let displayImage: String?
    let searchStrings: Set<String>?
    let isSpecial: Bool
    
    // not really useful, in fact completely useless
    let id: Int
    
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
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? Abbreviation {
            return self.uniqueString.compare(object.uniqueString) == .OrderedSame
        } else {
            return false
        }
    }
    
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
        
        let id = (JSONDict["id"] as! String?)!.toInt()!
        let phrase = JSONDict["phrase"] as! NSString
        let displayImage = JSONDict["abbrDisplayImage"] as! NSString?
        let isSpecial = JSONDict["isSpecial"] as! Bool
        
        // Get array from abbrSearchList
        let abbrSearchList = JSONDict["abbrSearchList"] as! NSArray

        self.init(displayText: abbrDisplay as String?, id: id, longText: phrase as String, displayImageName: displayImage as String?, searchStrings: abbrSearchList as! Array<String>, isSpecial: isSpecial)
    }
    
    func searchStringsAsReadableString() -> String? {
        if let searchStrs = self.searchStrings {
            var str = ""
            var i = 0
            for searchString in searchStrs {
                if i == count(searchStrs) - 1 {
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
    
    // Returns the range in the display text that matches the given string, accounting
    // for interpuncts and spaces.
    // E.g. Will return the range in "S . P . Q . R" that matches, e.g. "SP" (0..<5)
    //
    // UNUSED because special characters make this very difficult to implement, maybe come
    // up with a list of replacements for special characters to regular characters to solve
    // the problem
    func rangeOfDisplayTextMatchingSearchText(search: String) -> NSRange? {
        if let str = self.displayText {
            let searchString = search.uppercaseString
            
            var startIndex = 0
            var endIndex = 0
            
            var searchStringIndex = 0
            var inMatch = false
            var i = 0
            while (i < count(str)) {
                if searchStringIndex == count(searchString) {
                    break
                }
                if inMatch {
                    if str[i...i] == searchString[searchStringIndex...searchStringIndex] {
                        endIndex = i + 1
                        searchStringIndex += 1
                    }
                    else if str[i...i] == " " || str[i...i] == "·" {
                        endIndex = i + 1
                    }
                    else {
                        endIndex = 0
                        startIndex = 0
                        searchStringIndex = 0
                        inMatch = false
                    }
                }
                else if str[i...i] == searchString[searchStringIndex...searchStringIndex] {
                    startIndex = i
                    searchStringIndex += 1
                    inMatch = true
                }
                i += 1
            }
            
            return NSMakeRange(startIndex, endIndex - startIndex)
            
//            let rangeStart = advance(str.startIndex, startIndex)
//            let rangeEnd = advance(rangeStart, endIndex - startIndex + 1)
//            
//            return Range(start: rangeStart, end: rangeEnd)
        }
        else {
            return nil
        }
    }
}