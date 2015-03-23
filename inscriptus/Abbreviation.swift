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
    let displayImageName: String?
    let searchableStringsList: String?
    
    init(searchableText: String, displayText: String?, id: Int, longText: String, displayImageName: String?, searchableStringsList: String?) {
        self.searchableText = searchableText
        self.displayText = displayText
        self.id = id
        self.longText = longText
        
        self.displayImageName = displayImageName
        
        self.searchableStringsList = searchableStringsList
        
        super.init()
    }
    
    convenience init(JSONDict: NSDictionary) {
        var abbrSearch = JSONDict["abbrSearch"] as! NSString
        let abbrDisplay = JSONDict["abbrDisplay"] as? NSString
        let id = (JSONDict["id"] as! String?)!.toInt()!
        let phrase = JSONDict["phrase"] as! NSString
        let displayImage = JSONDict["displayImage"] as! NSString?
        let abbrSearchList = JSONDict["abbrSearchList"] as! NSString?

        self.init(searchableText: abbrSearch as String, displayText: abbrDisplay as String?, id: id, longText: phrase as String, displayImageName: displayImage as String?, searchableStringsList: abbrSearchList as String?)
    }
}