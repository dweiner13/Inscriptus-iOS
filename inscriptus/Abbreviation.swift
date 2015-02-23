//
//  Abbreviation.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class Abbreviation: NSObject {
    
    var searchableText: String
    var displayText: String?
    var id: Int
    var longText: String
    
    var displayImageName: String?
    
    init(searchableText: String, displayText: String?, id: Int, longText: String, displayImageName: String?) {
        self.searchableText = searchableText
        self.displayText = displayText
        self.id = id
        self.longText = longText
        
        self.displayImageName = displayImageName
        
        super.init()
    }
}