//
//  Abbreviation.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class Abbreviation: NSObject {
    
    let searchableText: String
    let displayText: String?
    let id: Int
    let longText: String
    let displayImage: String?
    let searchableStringsList: String?
    
    init(searchableText: String, displayText: String?, id: Int, longText: String, displayImageName: String?, searchableStringsList: String?) {
        self.searchableText = searchableText
        self.displayText = displayText
        self.id = id
        self.longText = longText
        
        if let imageName = displayImageName {
            self.displayImage = NSBundle.mainBundle().pathForResource(imageName, ofType: "png")
        }
        else {
            self.displayImage = nil
        }
        
        self.searchableStringsList = searchableStringsList
        
        super.init()
    }
    
    convenience init(JSONDict: NSDictionary) {
        var abbrSearch = JSONDict["abbrSearch"] as! NSString
        let abbrDisplay = JSONDict["abbrDisplay"] as? NSString
        let id = (JSONDict["id"] as! String?)!.toInt()!
        let phrase = JSONDict["phrase"] as! NSString
        let displayImage = JSONDict["abbrDisplayImage"] as! NSString?
        let abbrSearchList = JSONDict["abbrSearchList"] as! NSString?

        self.init(searchableText: abbrSearch as String, displayText: abbrDisplay as String?, id: id, longText: phrase as String, displayImageName: displayImage as String?, searchableStringsList: abbrSearchList as String?)
    }
    
    // Returns the range in the display text that matches the given string, accounting
    // for interpuncts and spaces.
    // E.g. Will return the range in "S . P . Q . R" that matches, e.g. "SP" (0..<5)
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