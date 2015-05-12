//
//  DetailViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, WhitakerScraperDelegate, UIViewControllerTransitioningDelegate {
    @IBOutlet weak var abbreviationLabel: UILabel!
    @IBOutlet weak var longTextLabel: UILabel!
    @IBOutlet weak var defineButton: UIButton!
    @IBOutlet weak var abbreviationBackgroundView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var whitakers = WhitakerScraper()
    
    var detailItem: Abbreviation! {
        didSet {
            if oldValue != nil {
                self.configureView()
            }
        }
    }

    func configureView() {
        if self.detailItem == nil {
            var defaultView = NSBundle.mainBundle().loadNibNamed("DefaultDetailView", owner: self, options: nil)[0] as! UIView
            self.view = defaultView
        }
        else {
            if let displayText = self.detailItem.displayText {
                self.abbreviationLabel.text = displayText
            }
            else {
                self.abbreviationLabel.text = "[image]"
            }
            self.longTextLabel.text = self.detailItem.longText
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        if self.detailItem != nil {
            self.whitakers.delegate = self
            self.definesPresentationContext = true
            self.abbreviationBackgroundView.layer.cornerRadius = 5
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showWords" {
            let def = segue.destinationViewController as! DefinitionViewController
            def.result = sender as! WhitakerResult
            def.transitioningDelegate = self
            def.modalPresentationStyle = .Custom
        }
    }
    
    override func shouldAutorotate() -> Bool {
        println("Calling shouldAutorotate() in DetailViewController")
        if self.presentedViewController != nil {
            return false
        }
        else {
            return true
        }
    }
    
    @IBAction func defineButtonPressed(sender: UIButton) {
        self.lookupDefinitions(sender)
    }
    
    func lookupDefinitions(button: UIButton) {
        self.whitakers.beginDefinitionRequestForWord(self.detailItem.longText, targetLanguage: .English)
        self.defineButton.hidden = true
        self.activityIndicator.startAnimating()
    }
    
    //MARK: - WhitakerScraperDelegate
    
    func whitakerScraper(scraper: WhitakerScraper, didLoadResult result: WhitakerResult) {
        self.activityIndicator.stopAnimating()
        self.defineButton.hidden = false
        self.performSegueWithIdentifier("showWords", sender: result)
    }
    
    func whitakerScraper(scraper: WhitakerScraper, didFailWithError error: NSError) {
        self.activityIndicator.stopAnimating()
        self.defineButton.hidden = false
        
        var alert = UIAlertController(title: "Oops!", message: error.description, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var rect = self.longTextLabel!.frame.rectByInsetting(dx: 0, dy: -15)
        var animator = foldOutAnimator(presenting: true, foldOutBelowRect: rect)
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var animator = foldOutAnimator(presenting: false, foldOutBelowRect: self.longTextLabel.frame)
        return animator
    }
}