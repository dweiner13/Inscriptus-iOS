//
//  String+.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 5/5/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

extension String {
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(startIndex, r.endIndex - r.startIndex)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    func lastCharacterAsString() -> String {
        return self[count(self)-1..<count(self)]
    }
    
    func numberOfOccurrencesOfString(str: String) -> Int {
        let strCount = count(str)
        var totalCount = 0
        
        if(strCount > count(self) || strCount == 0) {
            return 0
        }
        
        for i in 0...count(self)-strCount {
            let startIndex = advance(self.startIndex, i)
            let endIndex = advance(startIndex, strCount)
            let substr: String = self.substringWithRange(Range(start: startIndex, end: endIndex))
            
            if substr == str {
                totalCount += 1
            }
        }
        
        return totalCount
    }
}