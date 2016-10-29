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
        case english = 0
        case latin = 1
    }
    
    enum PartOfSpeech: Int {
        case noun
        case pronoun
        case adjective
        case verb
        case adverb
        case preposition
        case conjunction
        case interjection
        case enclitic
        case unknown
        
        func description() -> String {
            switch self {
            case .noun:
                return "Noun"
            case .pronoun:
                return "Pronoun"
            case .adjective:
                return "Adjective"
            case .verb:
                return "Verb"
            case .adverb:
                return "Adverb"
            case .preposition:
                return "Preposition"
            case .conjunction:
                return "Conjunction"
            case .interjection:
                return "Interjection"
            case .enclitic:
                return "Enclitic"
            case .unknown:
                return "Unknown"
            }
        }
    }
    
    var word: String?
    weak var delegate: WhitakerScraperDelegate?
    var targetLanguage: WhitakerScraper.TargetLanguage?
    var cache = WhitakerCache.sharedCache
    
    
    internal var receivedData: NSMutableData?
    internal var currentConnection: NSURLConnection?
    
    func beginDefinitionRequestForWord(_ word: String, targetLanguage: TargetLanguage) {
        if cache.containsResultForWord(word) {
            print("found cached result for word \(word)")
            self.delegate?.whitakerScraper(self, didLoadResult: cache.resultForWord(word))
            return
        }
        
        if let connection = self.currentConnection {
            connection.cancel()
            self.currentConnection = nil
            self.receivedData = nil
            self.word = nil
            self.targetLanguage = nil
        }
        
        self.word = word;
        self.targetLanguage = targetLanguage
        
        let wordURLEncoded = word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        var baseURL = String()
        
        if targetLanguage==TargetLanguage.english {
            baseURL = "http://www.archives.nd.edu/cgi-bin/wordz.pl?keyword="
        }
        else {
            baseURL = "http://www.archives.nd.edu/cgi-bin/wordz.pl?english="
        }
        
        let requestURL = URL(string: "\(baseURL)\(wordURLEncoded)")
        
        let request = URLRequest(url: requestURL!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        self.receivedData = NSMutableData()
        
        self.currentConnection = NSURLConnection(request: request, delegate: self)
        
        if let _ = self.currentConnection {
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
        if definition.characters.count <= 26 {
            return PartOfSpeech.unknown
        }
        
        let start = definition.index(definition.startIndex, offsetBy: 21);
        let end = definition.index(definition.startIndex, offsetBy: 27);
        let range = start..<end;
        
        let posAbbreviation = definition.substring(with: range);
        
        return partOfSpeechForAbbreviation(posAbbreviation)
    }
    
    class func partOfSpeechForAbbreviation(_ abbreviation: String) -> PartOfSpeech {
        switch abbreviation {
        case "N     ":
            return .noun
        case "PRON  ":
            return .pronoun
        case "ADJ   ":
            return .adjective
        case "V     ":
            return .verb
        case "VPAR  ":
            return .verb
        case "ADV   ":
            return .adverb
        case "PREP  ":
            return .preposition
        case "CONJ  ":
            return .conjunction
        case "INTERJ":
            return .interjection
        case "TACKON":
            return .enclitic
        default:
            return .unknown
        }
    }
    
    class func definitionsInResult(_ result: String, forWord word: String) -> [WhitakerDefinition] {
        var lines = result.components(separatedBy: CharacterSet.newlines)
        
        var definitionStrings = [""]
        var meaningStrings = [""]
        var definitionStringsWithoutMeanings = [""]
        var i = 0
        
        // pull out definition strings
        for line in lines {
            if line.trimmingCharacters(in: .whitespaces) == "*" {
                i += 1
                continue
            }
            else if line.range(of: ";") != nil {
                definitionStrings[definitionStrings.count - 1] += "\(line)\n"
                meaningStrings[meaningStrings.count - 1] += "\(line)\n"
                
                if i != lines.count - 1 && lines[i+1].range(of: ";") == nil {
                    meaningStrings.append(String())
                    definitionStrings.append(String())
                    definitionStringsWithoutMeanings.append(String())
                }
            }
            else {
                definitionStrings[definitionStrings.count - 1] += "\(line)\n"
                definitionStringsWithoutMeanings[definitionStringsWithoutMeanings.count - 1] += "\(line)\n"
            }
            i += 1
        }
        
        // combine those strings into definition objects
        var definitions = [WhitakerDefinition]()
        for index in 0..<definitionStrings.count {
            let definition = definitionStrings[index].trimmingCharacters(in: .newlines)
            var meanings: String? = meaningStrings[index].trimmingCharacters(in: .newlines)
            
            if definition=="" {
                continue
            }
            let textWithoutMeanings = definitionStringsWithoutMeanings[index].trimmingCharacters(in: .newlines)
            if meanings=="" {
                meanings = nil
            }
            
            var partOfSpeech = findPartOfSpeech(forDefinition: definition)
            let isAlternateSpelling = false;
            if partOfSpeech == .unknown && index > 0 {
                partOfSpeech = definitions[index-1].partOfSpeech
            }
            
            let def = WhitakerDefinition(word: word, text: definition, meanings: meanings, textWithoutMeanings: textWithoutMeanings, partOfSpeech: partOfSpeech, isAlternateSpelling: isAlternateSpelling)
            definitions.append(def)
        }
        
        return definitions
    }
    
    class func combinedStringForDefinitions(_ definitions: [WhitakerDefinition]) -> String {
        var combinedString = ""
        for definition in definitions {
            combinedString += "\(definition.text)\n\n"
        }
        return combinedString.trimmingCharacters(in: CharacterSet.newlines)
    }
}


extension WhitakerScraper: NSURLConnectionDataDelegate {
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        self.receivedData!.length = 0
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        self.receivedData!.append(data)
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        if let delegate = self.delegate {
            delegate.whitakerScraper(self, didFailWithError: error as NSError)
        }
        
        self.receivedData = nil
        self.word = nil
        self.currentConnection = nil
        self.targetLanguage = nil
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        let resultParser = TFHpple(htmlData: self.receivedData! as Data!)
        let resultXpathQueryString = "//pre"
        let resultNodes = resultParser?.search(withXPathQuery: resultXpathQueryString)
        let resultElement: TFHppleElement = resultNodes!.first! as! TFHppleElement
        let rawResult = resultElement.content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        let definitions = WhitakerScraper.definitionsInResult(rawResult, forWord: self.word!)
        let result = WhitakerResult(definitions: definitions, targetLanguage: self.targetLanguage!, rawResult: rawResult, word: self.word!)
        
        if let delegate = self.delegate {
            delegate.whitakerScraper(self, didLoadResult: result)
        }
        
        cache.addItem(result)
        
        self.receivedData = nil
        self.word = nil
        self.currentConnection = nil
        self.targetLanguage = nil
    }
}
