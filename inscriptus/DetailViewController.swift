//
//  DetailViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class DetailViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var detailItem: Abbreviation? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var sections: [[String: String]]!

    func configureView() {
        // Update the user interface for the detail item
        if let abb: Abbreviation = self.detailItem {
            self.sections = [
                [
                    "header": "Abbreviation",
                    "content": abb.displayText!
                ],
                [
                    "header": "Long text",
                    "content": abb.longText
                ]
            ]
            if let readableSearchStrings = abb.searchStringsAsReadableString() {
                self.sections.append([
                    "header": "Search for with",
                    "content": readableSearchStrings
                ]);
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        self.collectionView?.registerClass(TextCollectionViewCell.self, forCellWithReuseIdentifier: "TextCell")
        self.collectionView?.registerClass(HeaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderCell")
        
        var contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
        self.collectionView!.contentInset = contentInset
        
        let flow = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        flow.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 20, right: 20)
        flow.headerReferenceSize = CGSize(width: 100, height: 25)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func wordsInSection(section: Int) -> [String] {
        let content = self.sections[section]["content"]!
        let whitespaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        return content.componentsSeparatedByCharactersInSet(whitespaceSet)
    }

    //MARK: - UICollectionView
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return count(self.sections)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count(self.wordsInSection(section))
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let words = self.wordsInSection(indexPath.section)
        let cell: TextCollectionViewCell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("TextCell", forIndexPath: indexPath) as! TextCollectionViewCell
        cell.maxWidth = self.collectionView?.bounds.size.width
        cell.text = words[indexPath.row];
        return cell;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let words = self.wordsInSection(indexPath.section)
        return TextCollectionViewCell.sizeForContentString(words[indexPath.row], forMaxWidth: collectionView.bounds.size.width, forFont: UIFont.preferredFontForTextStyle(UIFontTextStyleBody))
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            var cell: HeaderCollectionViewCell = self.collectionView!.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HeaderCell", forIndexPath: indexPath) as! HeaderCollectionViewCell
            cell.maxWidth = collectionView.bounds.size.width
            cell.text = self.sections[indexPath.section]["header"]!
            return cell
        }
        else {
            fatalError("wrong kind for supplementary collection view cell")
        }
    }
}