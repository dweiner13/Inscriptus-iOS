//
//  DetailViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    
    
    var detailItem: Abbreviation? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var sections: [[String: String]]!

    func configureView() {
        // Update the user interface for the detail item
//        if let abb: Abbreviation = self.detailItem {
//            self.sections = [
//                [
//                    "header": "Abbreviation",
//                    "content": abb.displayText!
//                ],
//                [
//                    "header": "Long text",
//                    "content": abb.longText
//                ]
//            ]
//            if let readableSearchStrings = abb.searchStringsAsReadableString() {
//                self.sections.append([
//                    "header": "Search for with",
//                    "content": readableSearchStrings
//                ]);
//            }
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
//        let leftConstraint = NSLayoutConstraint(item: self.contentView,
//                                           attribute: NSLayoutAttribute.Leading,
//                                           relatedBy: NSLayoutRelation.Equal,
//                                              toItem: self.view,
//                                           attribute: NSLayoutAttribute.Left,
//                                          multiplier: 1.0,
//                                            constant: 0)
//        let rightConstraint = NSLayoutConstraint(item: self.contentView,
//                                            attribute: NSLayoutAttribute.Trailing,
//                                            relatedBy: NSLayoutRelation.Equal,
//                                               toItem: self.view,
//                                            attribute: NSLayoutAttribute.Right,
//                                           multiplier: 1.0,
//                                             constant: 0)
//        self.view.addConstraint(leftConstraint)
//        self.view.addConstraint(rightConstraint)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}