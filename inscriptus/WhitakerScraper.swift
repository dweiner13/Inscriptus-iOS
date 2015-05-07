//
//  WhitakerScraper.swift
//  Latin Companion Swift
//
//  Created by Daniel A. Weiner on 2/3/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import Foundation

class WhitakerScraper: NSObject {
    
    enum TargetLanguage: Int {
        case English = 0
        case Latin = 1
    }
    
    enum PartOfSpeech: Int {
        case Noun
        case Pronoun
        case Adjective
        case Verb
        case Adverb
        case Preposition
        case Conjunction
        case Interjection
        case Enclitic
        case Unknown
        
        func description() -> String {
            switch self {
            case Noun:
                return "Noun"
            case Pronoun:
                return "Pronoun"
            case Adjective:
                return "Adjective"
            case Verb:
                return "Verb"
            case Adverb:
                return "Adverb"
            case Preposition:
                return "Preposition"
            case Conjunction:
                return "Conjunction"
            case Interjection:
                return "Interjection"
            case Enclitic:
                return "Enclitic"
            case Unknown:
                return "Unknown"
            }
        }
    }
    
    var word: String?
    weak var delegate: WhitakerScraperDelegate?
    var targetLanguage: WhitakerScraper.TargetLanguage?
    
    internal var receivedData: NSMutableData?
    internal var currentConnection: NSURLConnection?
    
    func beginDefinitionRequestForWord(word: String, targetLanguage: TargetLanguage) {
        println("began definition request for word \(word)")
        
        if let connection = self.currentConnection {
            connection.cancel()
            self.currentConnection = nil
            self.receivedData = nil
            self.word = nil
            self.targetLanguage = nil
        }
        
        self.word = word;
        self.targetLanguage = targetLanguage
        
        var wordURLEncoded = word.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        
        var baseURL = String()
        
        if targetLanguage==TargetLanguage.English {
            baseURL = "http://www.archives.nd.edu/cgi-bin/wordz.pl?keyword="
        }
        else {
            baseURL = "http://www.archives.nd.edu/cgi-bin/wordz.pl?english="
        }
        
        var requestURL = NSURL(string: "\(baseURL)\(wordURLEncoded)")
        
        var request = NSURLRequest(URL: requestURL!)
        
        self.receivedData = NSMutableData()
        
        self.currentConnection = NSURLConnection(request: request, delegate: self)
        
        if let connection = self.currentConnection {
        }
        else {
            NSLog("connection nil after creation")
            
            self.receivedData = nil
            self.word = nil
            self.currentConnection = nil
            self.targetLanguage = nil
        }
    }
    
    class func findPartOfSpeech(forDefinition definition: String) -> PartOfSpeech {
        if count(definition) <= 26 {
            return PartOfSpeech.Unknown
        }
        
        var posAbbreviation = definition[21...26]
        
        return partOfSpeechForAbbreviation(posAbbreviation)
    }
    
    class func partOfSpeechForAbbreviation(abbreviation: String) -> PartOfSpeech {
        switch abbreviation {
        case "N     ":
            return .Noun
        case "PRON  ":
            return .Pronoun
        case "ADJ   ":
            return .Adjective
        case "V     ":
            return .Verb
        case "VPAR  ":
            return .Verb
        case "ADV   ":
            return .Adverb
        case "PREP  ":
            return .Preposition
        case "CONJ  ":
            return .Conjunction
        case "INTERJ":
            return .Interjection
        case "TACKON":
            return .Enclitic
        default:
            return .Unknown
        }
    }
    
    class func definitionsInResult(result: String, forWord word: String) -> [WhitakerDefinition] {
        var lines = result.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        
        var definitionStrings = [""]
        var meaningStrings = [""]
        var definitionStringsWithoutMeanings = [""]
        var i = 0
        
        // pull out definition strings
        for line in lines {
            if line.stringByTrimmingCharactersInSet(.whitespaceCharacterSet()) == "*" {
                i++
                continue
            }
            else if line.rangeOfString(";") != nil {
                definitionStrings[definitionStrings.count - 1] += "\(line)\n"
                meaningStrings[meaningStrings.count - 1] += "\(line)\n"
                
                if i != lines.count - 1 && lines[i+1].rangeOfString(";") == nil {
                    meaningStrings.append(String())
                    definitionStrings.append(String())
                    definitionStringsWithoutMeanings.append(String())
                }
            }
            else {
                definitionStrings[definitionStrings.count - 1] += "\(line)\n"
                definitionStringsWithoutMeanings[definitionStringsWithoutMeanings.count - 1] += "\(line)\n"
            }
            i++
        }
        
        // combine those strings into definition objects
        var definitions = [WhitakerDefinition]()
        for index in 0..<definitionStrings.count {
            var definition = definitionStrings[index].stringByTrimmingCharactersInSet(.newlineCharacterSet())
            var meanings: String? = meaningStrings[index].stringByTrimmingCharactersInSet(.newlineCharacterSet())
            
            if definition=="" {
                continue
            }
            var textWithoutMeanings = definitionStringsWithoutMeanings[index].stringByTrimmingCharactersInSet(.newlineCharacterSet())
            if meanings=="" {
                meanings = nil
            }
            
            var partOfSpeech = findPartOfSpeech(forDefinition: definition)
            var isAlternateSpelling = false;
            if partOfSpeech == .Unknown && index > 0 {
                partOfSpeech = definitions[index-1].partOfSpeech
            }
            
            var def = WhitakerDefinition(word: word, text: definition, meanings: meanings, textWithoutMeanings: textWithoutMeanings, partOfSpeech: partOfSpeech, isAlternateSpelling: isAlternateSpelling)
            definitions.append(def)
        }
        
        return definitions
    }
    
    class func combinedStringForDefinitions(definitions: [WhitakerDefinition]) -> String {
        var combinedString = ""
        for definition in definitions {
            combinedString += "\(definition.text)\n\n"
        }
        return combinedString.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
    }
}


extension WhitakerScraper: NSURLConnectionDataDelegate {
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.receivedData!.length = 0
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.receivedData!.appendData(data)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        if let delegate = self.delegate {
            delegate.whitakerScraper(self, didFailWithError: error)
        }
        
        self.receivedData = nil
        self.word = nil
        self.currentConnection = nil
        self.targetLanguage = nil
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        var resultParser = TFHpple(HTMLData: self.receivedData!)
        var resultXpathQueryString = "//pre"
        var resultNodes = resultParser.searchWithXPathQuery(resultXpathQueryString)
        var resultElement: TFHppleElement = resultNodes.first! as! TFHppleElement
        var rawResult = resultElement.content.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        var definitions = WhitakerScraper.definitionsInResult(rawResult, forWord: self.word!)
        let result = WhitakerResult(definitions: definitions, targetLanguage: self.targetLanguage!, rawResult: rawResult, word: self.word!)
        
        if let delegate = self.delegate {
            delegate.whitakerScraper(self, didLoadResult: result)
        }
        
        self.receivedData = nil
        self.word = nil
        self.currentConnection = nil
        self.targetLanguage = nil
    }
}