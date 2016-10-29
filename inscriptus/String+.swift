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
            let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.characters.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            
            return self[(startIndex ..< endIndex)]
        }
    }
    
    // Allow multiline strings
    // see http://stackoverflow.com/questions/24091233/swift-split-string-over-multiple-lines
    init(sep:String, _ lines:String...){
        self = ""
        for (idx, item) in lines.enumerated() {
            self += "\(item)"
            if idx < lines.count-1 {
                self += sep
            }
        }
    }
    init(_ lines:String...){
        self = ""
        for (idx, item) in lines.enumerated() {
            self += "\(item)"
            if idx < lines.count-1 {
                self += "\n"
            }
        }
    }
    
    func lastCharacterAsString() -> String {
        return self[self.characters.count-1..<self.characters.count]
    }
    
    func numberOfOccurrencesOfString(_ str: String) -> Int {
        let strCount = str.characters.count
        var totalCount = 0
        
        if(strCount > self.characters.count || strCount == 0) {
            return 0
        }
        
        for i in 0...self.characters.count-strCount {
            let startIndex = self.characters.index(self.startIndex, offsetBy: i)
            let endIndex = self.characters.index(startIndex, offsetBy: strCount)
            let substr: String = self.substring(with: (startIndex ..< endIndex))
            
            if substr == str {
                totalCount += 1
            }
        }
        
        return totalCount
    }
}
