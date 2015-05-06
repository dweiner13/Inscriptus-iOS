//
//  WhitakerScraperDelegate.swift
//  Latin Companion swift
//
//  Created by Daniel A. Weiner on 2/3/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import Foundation

protocol WhitakerScraperDelegate: class {
    
    func whitakerScraper(scraper: WhitakerScraper, didLoadDefinitions definitions: [WhitakerDefinition], forWord word: String, withTargetLanguage targetLanguage: WhitakerScraper.TargetLanguage, rawResult result: String)
    
    func whitakerScraper(scraper: WhitakerScraper, didFailWithError error: NSError)
    
}