//
//  WhitakerResult.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 5/6/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

private let DEFAULTS_DEFINITIONS_KEY = "resultDefinition"
private let DEFAULTS_TARGETLANGUAGE_KEY = "resultTargetLanguage"
private let DEFAULTS_RAWRESULT_KEY = "resultRaw"
private let DEFAULTS_WORD_KEY = "resultWord"

class WhitakerResult: NSObject, NSCoding {
   
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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.definitions, forKey: DEFAULTS_DEFINITIONS_KEY)
        aCoder.encode(self.targetLanguage.rawValue, forKey: DEFAULTS_TARGETLANGUAGE_KEY)
        aCoder.encode(self.rawResult, forKey: DEFAULTS_RAWRESULT_KEY)
        aCoder.encode(self.word, forKey: DEFAULTS_WORD_KEY)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.definitions = aDecoder.decodeObject(forKey: DEFAULTS_DEFINITIONS_KEY) as! [WhitakerDefinition]
        self.targetLanguage = WhitakerScraper.TargetLanguage(rawValue: aDecoder.decodeInteger(forKey: DEFAULTS_TARGETLANGUAGE_KEY))!
        self.rawResult = aDecoder.decodeObject(forKey: DEFAULTS_RAWRESULT_KEY) as! String
        self.word = aDecoder.decodeObject(forKey: DEFAULTS_WORD_KEY) as! String

        super.init()
    }
}
