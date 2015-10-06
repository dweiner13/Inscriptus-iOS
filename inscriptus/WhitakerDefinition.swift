//
//  WhitakerScraperDefinition.swift
//  Latin Companion iOS
//
//  Created by Daniel A. Weiner on 2/7/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

private let DEFAULTS_WORD_KEY = "word"
private let DEFAULTS_TEXT_KEY = "text"
private let DEFAULTS_MEANINGS_KEY = "meanings"
private let DEFAULTS_TEXTWITHOUTMEANINGS_KEY = "textWithoutMeanings"
private let DEFAULTS_ISALTERNATESPELLING_KEY = "isAlternateSpelling"
private let DEFAULTS_PARTOFSPEECH_KEY = "partOfSpeech"

class WhitakerDefinition: NSObject, NSCoding {
    // the word typed in the text field to find this definition
    var word: String
    
    // the complete definition, including possible parts of speech,
    // declensions, conjugations, and the meanings
    var text: String
    
    // just the meanings
    var meanings: String?
    
    // the complete definition except the meanings
    var textWithoutMeanings: String
    
    // indicates whether this definition is an alternate spelling for the previous definition
    // e.g. "arcs, arcis" vs. "arx, arcis"
    var isAlternateSpelling: Bool
    
    var partOfSpeech: WhitakerScraper.PartOfSpeech
    
    var lightColor: UIColor {
        get {
            switch partOfSpeech {
            case .Noun:
                //red
                return UIColor(red: 1.000, green: 0.893, blue: 0.890, alpha: 1.000)
            case .Pronoun:
                // orange
                return UIColor(red: 1.000, green: 0.935, blue: 0.866, alpha: 1.000)
            case .Adjective:
                // purple
                return UIColor(red: 1.000, green: 0.888, blue: 0.980, alpha: 1.000)
            case .Verb:
                // blue
                return UIColor(red: 0.863, green: 0.891, blue: 1.000, alpha: 1.000)
            case .Adverb:
                // green
                return UIColor(red: 0.909, green: 1.000, blue: 0.936, alpha: 1.000)
            case .Preposition:
                // yellow
                return UIColor(red: 1.000, green: 0.984, blue: 0.883, alpha: 1.000)
            case .Conjunction:
                // teal
                return UIColor(red: 0.873, green: 1.000, blue: 0.963, alpha: 1.000)
            case .Interjection:
                // brown
                return UIColor(red: 1.000, green: 0.912, blue: 0.828, alpha: 1.000)
            default:
                // white
                return UIColor.whiteColor()
            }
        }
    }
    
    var darkColor: UIColor {
        get {
            switch partOfSpeech {
            case .Noun:
                //red
                return UIColor(red: 1.000, green: 0.80, blue: 0.80, alpha: 1.000)
            case .Pronoun:
                // orange
                return UIColor(red: 1.000, green: 0.88, blue: 0.71, alpha: 1.000)
            case .Adjective:
                // purple
                return UIColor(red: 1.000, green: 0.79, blue: 0.96, alpha: 1.000)
            case .Verb:
                // blue
                return UIColor(red: 0.72, green: 0.80, blue: 1.000, alpha: 1.000)
            case .Adverb:
                // green
                return UIColor(red: 0.80, green: 1.00, blue: 0.85, alpha: 1.000)
            case .Preposition:
                // yellow
                return UIColor(red: 1.000, green: 0.97, blue: 0.76, alpha: 1.000)
            case .Conjunction:
                // teal
                return UIColor(red: 0.74, green: 1.000, blue: 0.92, alpha: 1.000)
            case .Interjection:
                // brown
                return UIColor(red: 1.000, green: 0.82, blue: 0.66, alpha: 1.000)
            default:
                // grey
                return UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.000)
            }
        }
    }
    
    init(word: String, text: String, meanings: String?, textWithoutMeanings: String, partOfSpeech: WhitakerScraper.PartOfSpeech, isAlternateSpelling: Bool) {
        self.word = word
        self.text = text
        self.meanings = meanings
        self.partOfSpeech = partOfSpeech
        self.textWithoutMeanings = textWithoutMeanings
        self.isAlternateSpelling = isAlternateSpelling
        
        super.init()
    }
    
    convenience init(word: String, text: String, meanings: String?, textWithoutMeanings: String, partOfSpeech: WhitakerScraper.PartOfSpeech) {
        self.init(word: word, text: text, meanings: meanings, textWithoutMeanings: textWithoutMeanings, partOfSpeech: partOfSpeech, isAlternateSpelling: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.word = aDecoder.decodeObjectForKey(DEFAULTS_WORD_KEY) as! String
        self.text = aDecoder.decodeObjectForKey(DEFAULTS_TEXT_KEY) as! String
        self.meanings = aDecoder.decodeObjectForKey(DEFAULTS_MEANINGS_KEY) as! String?
        self.textWithoutMeanings = aDecoder.decodeObjectForKey(DEFAULTS_TEXTWITHOUTMEANINGS_KEY) as! String
        self.isAlternateSpelling = aDecoder.decodeBoolForKey(DEFAULTS_ISALTERNATESPELLING_KEY)
        self.partOfSpeech = WhitakerScraper.PartOfSpeech(rawValue: aDecoder.decodeIntegerForKey(DEFAULTS_PARTOFSPEECH_KEY))!
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.word, forKey: DEFAULTS_WORD_KEY)
        aCoder.encodeObject(self.text, forKey: DEFAULTS_TEXT_KEY)
        aCoder.encodeObject(self.meanings, forKey: DEFAULTS_MEANINGS_KEY)
        aCoder.encodeObject(self.textWithoutMeanings, forKey: DEFAULTS_TEXTWITHOUTMEANINGS_KEY)
        aCoder.encodeBool(self.isAlternateSpelling, forKey: DEFAULTS_ISALTERNATESPELLING_KEY)
        aCoder.encodeInteger(self.partOfSpeech.rawValue, forKey: DEFAULTS_PARTOFSPEECH_KEY)
    }
}
