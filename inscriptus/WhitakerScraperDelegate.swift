//
//  WhitakerScraperDelegate.swift
//  Latin Companion swift
//
//  Created by Daniel A. Weiner on 2/3/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import Foundation

protocol WhitakerScraperDelegate: class {
    
    func whitakerScraper(scraper: WhitakerScraper, didLoadResult: WhitakerResult)
    
    func whitakerScraper(scraper: WhitakerScraper, didFailWithError error: NSError)
    
}