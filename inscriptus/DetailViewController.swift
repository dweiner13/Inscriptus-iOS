//
//  DetailViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, WhitakerScraperDelegate, UIViewControllerTransitioningDelegate, DefinitionViewControllerDelegate {
    @IBOutlet weak var abbreviationLabel: UILabel!
    @IBOutlet weak var longTextLabel: UILabel!
    @IBOutlet weak var defineButton: UIButton!
    @IBOutlet weak var abbreviationBackgroundView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteButtonBackgroundView: UIView!
    @IBOutlet weak var favoriteButtonBackgroundViewWidthEqualToConstraint: NSLayoutConstraint!
    
    var mostRecentViewTapped: UIView?
    var whitakers = WhitakerScraper()
    
    var detailItem: Abbreviation! {
        didSet {
            if oldValue != nil {
                self.configureView()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        if self.detailItem != nil {
            self.whitakers.delegate = self
            self.definesPresentationContext = true
            self.abbreviationBackgroundView.layer.cornerRadius = 5
            self.abbreviationBackgroundView.layer.borderColor = INSCRIPTUS_TINT_COLOR.CGColor
            self.abbreviationBackgroundView.layer.borderWidth = 1
        }
    }
    
    // MARK: - UI Stuff
    
    
    
    func configureView() {
        if self.detailItem == nil {
            var defaultView = NSBundle.mainBundle().loadNibNamed("DefaultDetailView", owner: self, options: nil)[0] as! UIView
            self.view = defaultView
        }
        else {
            if let displayText = self.detailItem.displayText {
                self.imageView.hidden = true
                self.abbreviationLabel.text = displayText.stringByReplacingOccurrencesOfString("·", withString: "")
                self.abbreviationLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody, scaleFactor: 1.9)
            }
            else if let displayImage = self.detailItem.displayImage {
                self.abbreviationLabel.hidden = true
                self.imageView.image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource(displayImage, ofType: ".png")!)!
                self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
            }
            self.longTextLabel.text = self.detailItem.longText
            self.longTextLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody, scaleFactor: 1.2)
            if AbbreviationCollection.sharedAbbreviationCollection.favorites.containsObject(self.detailItem) {
                self.favoriteButton.setTitle("Remove from favorites", forState: UIControlState.Normal)
                self.favoriteButton.tintColor = UIColor.whiteColor()
                self.favoriteButtonBackgroundView.backgroundColor = INSCRIPTUS_TINT_COLOR
            }
            else {
                self.favoriteButton.setTitle("Add to favorites", forState: UIControlState.Normal)
                self.favoriteButtonBackgroundView.backgroundColor = UIColor.clearColor()
            }
            self.favoriteButtonBackgroundView.layer.cornerRadius = 7
        }
    }
    
    @IBAction func tappedAbbreviation(sender: AnyObject) {
        var controller = UIMenuController.sharedMenuController()
        if controller.menuVisible == false {
            self.mostRecentViewTapped = self.abbreviationBackgroundView
            controller.setTargetRect(self.abbreviationBackgroundView.frame, inView: self.view)
            controller.setMenuVisible(true, animated: true)
            self.abbreviationBackgroundView.animateBounce(0.3, minScale: 0.93, maxScale: 1.05)
        }
    }
    
    @IBAction func tappedLongText(sender: AnyObject) {
        var controller = UIMenuController.sharedMenuController()
        if controller.menuVisible == false {
            self.mostRecentViewTapped = self.longTextLabel
            controller.setTargetRect(self.longTextLabel.frame, inView: self.view)
            controller.setMenuVisible(true, animated: true)
            self.longTextLabel.animateBounce(0.3, minScale: 0.93, maxScale: 1.05)
        }
    }
    
    @IBAction func tappedFavoriteButton(sender: UIButton) {
        if AbbreviationCollection.sharedAbbreviationCollection.favorites.containsObject(self.detailItem) {
            AbbreviationCollection.sharedAbbreviationCollection.removeFavorite(self.detailItem)
            self.favoriteButton.setTitle("Add back to favorites", forState: UIControlState.Normal)
            self.favoriteButton.tintColor = INSCRIPTUS_TINT_COLOR
            UIView.animateWithDuration(0.2, animations: {
                () -> Void in
                self.favoriteButtonBackgroundView.backgroundColor = UIColor.clearColor()
                self.favoriteButtonBackgroundView.transform = CGAffineTransformMakeScale(0.05, 0.05)
                },
                completion: {
                    (b) -> Void in
                    self.favoriteButtonBackgroundView.transform = CGAffineTransformMakeScale(1, 1)
            })
        }
        else {
            AbbreviationCollection.sharedAbbreviationCollection.addFavorite(self.detailItem)
            self.favoriteButton.setTitle("Remove from favorites", forState: UIControlState.Normal)
            self.favoriteButton.tintColor = UIColor.whiteColor()
            self.favoriteButtonBackgroundView.backgroundColor = INSCRIPTUS_TINT_COLOR
            UIView.animateWithDuration(0.2, animations: {
                () -> Void in
                self.favoriteButtonBackgroundView.backgroundColor = INSCRIPTUS_TINT_COLOR
                self.favoriteButtonBackgroundView.transform = CGAffineTransformMakeScale(1.3, 1.3)
                },
                completion: {
                    (b) -> Void in
                    UIView.animateWithDuration(0.12, animations: {
                        self.favoriteButtonBackgroundView.transform = CGAffineTransformMakeScale(0.94, 0.94)
                        },
                        completion: {
                            (b) -> Void in
                            UIView.animateWithDuration(0.12, animations: {
                                self.favoriteButtonBackgroundView.transform = CGAffineTransformMakeScale(1, 1)
                            })
                    })
            })
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
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showWords" {
            let def = segue.destinationViewController as! DefinitionViewController
            def.result = sender as! WhitakerResult
            def.transitioningDelegate = self
            def.modalPresentationStyle = .Custom
            def.delegate = self
        }
    }
    
    //MARK: - UIMenuController
    
    override func copy(sender: AnyObject?) {
        if self.mostRecentViewTapped == self.abbreviationBackgroundView {
            var pasteboard = UIPasteboard.generalPasteboard()
            if let displayText = self.detailItem.displayText {
                pasteboard.string = self.detailItem.displayText
            }
            else if let displayImage = self.detailItem.displayImage {
                pasteboard.image = self.imageView.image
            }
        }
        else if self.mostRecentViewTapped == self.longTextLabel {
            var pasteboard = UIPasteboard.generalPasteboard()
            pasteboard.string = self.detailItem.longText
        }
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == "copy:" {
            return true
        }
        else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    //MARK: - WhitakerScraperDelegate
    
    func whitakerScraper(scraper: WhitakerScraper, didLoadResult result: WhitakerResult) {
        self.activityIndicator.stopAnimating()
        self.performSegueWithIdentifier("showWords", sender: result)
    }
    
    func whitakerScraper(scraper: WhitakerScraper, didFailWithError error: NSError) {
        self.activityIndicator.stopAnimating()
        
        var alert = UIAlertController(title: "Oops!", message: error.description, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let frame = self.longTextLabel!.frame
        let rect = CGRect(x: frame.origin.x, y: frame.origin.y - 8, width: frame.width, height: frame.height + 23)
        var animator = foldOutAnimator(presenting: true, foldOutBelowRect: rect)
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var animator = foldOutAnimator(presenting: false, foldOutBelowRect: self.longTextLabel.frame)
        return animator
    }
    
    //MARK: - DefinitionViewControllerDelegate
    
    func didDismissDefinitionViewController(viewController: DefinitionViewController) {
        self.defineButton.hidden = false
    }
}