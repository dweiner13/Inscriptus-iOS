//
//  WhitakerResult.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 5/6/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class WhitakerResult: NSObject {
   
    let definitions: [WhitakerDefinition]
    let targetLanguage: WhitakerScraper.TargetLanguage
    let rawResult: String
    let word: String
    
    init(definitions: [WhitakerDefinition], targetLanguage: WhitakerScraper.TargetLanguage, rawResult: String, word: String) {
        self.definitions = definitions
        self.targetLanguage = targetLanguage
        self.rawResult = rawResult
        self.word = word
    }
    
}
