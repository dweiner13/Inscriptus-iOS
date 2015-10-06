//
//  DetailViewController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 2/18/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController, WhitakerScraperDelegate, UIViewControllerTransitioningDelegate, DefinitionViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var abbreviationLabel: UILabel!
    @IBOutlet weak var longTextLabel: UILabel!
    @IBOutlet weak var defineButton: UIButton!
    @IBOutlet weak var abbreviationBackgroundView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteButtonBackgroundView: UIView!
    @IBOutlet weak var favoriteButtonBackgroundViewWidthEqualToConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var lookupCoachBox: UIView!
    @IBOutlet weak var lookupCoachArrow: UIView!
    @IBOutlet weak var lookupCoachTip: UIImageView!
    
    @IBOutlet weak var holdCoachBox: UIView!
    @IBOutlet weak var holdCoachArrow1: UIView!
    @IBOutlet weak var holdCoachArrow2: UIView!
    
    var mostRecentViewTapped: UIView?
    var whitakers = WhitakerScraper()
    
    var coachTips: [(box: UIView!, arrows: [UIView!])]?
    
    let shouldShowCoachTips = true
    
    let coachDelay: NSTimeInterval = 0.5
    
    var detailItem: Abbreviation! {
        didSet {
            if oldValue != nil {
                self.configureView()
            }
        }
    }

    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        if self.detailItem != nil {
            if !MFMailComposeViewController.canSendMail() {
                self.navigationItem.rightBarButtonItem = nil
            }
            self.whitakers.delegate = self
            self.definesPresentationContext = true
            self.abbreviationBackgroundView.layer.cornerRadius = 5
            self.abbreviationBackgroundView.layer.borderColor = INSCRIPTUS_TINT_COLOR.CGColor
            self.abbreviationBackgroundView.layer.borderWidth = 1
            
            self.coachTips = [
                (box: self.lookupCoachBox, arrows: [
                    self.lookupCoachArrow,
                    self.lookupCoachTip
                    ]),
                (box: self.holdCoachBox, arrows: [
                    self.holdCoachArrow1,
                    self.holdCoachArrow2
                    ])
            ]
            for coachTip in self.coachTips! {
                coachTip.box.layer.cornerRadius = 5
                coachTip.box.alpha = 0
                coachTip.box.hidden = true
                for arrow in coachTip.arrows {
                    arrow.hidden = true
                    arrow.alpha = 0
                }
            }
        }
    }
    
    func showLookupCoach(showCoach: Bool, delay: Double) {
        if showCoach {
            self.lookupCoachBox.hidden = false
            self.lookupCoachArrow.hidden = false
            self.lookupCoachTip.hidden = false
            UIView.animateWithDuration(coachDelay, delay: delay, options: [], animations: {
                self.lookupCoachBox.alpha = 1
                self.lookupCoachArrow.alpha = 1
                self.lookupCoachTip.alpha = 1
            },
                completion: nil)
        }
        else {
            UIView.animateWithDuration(coachDelay, delay: delay, options: [], animations: {
                self.lookupCoachBox.alpha = 0
                self.lookupCoachArrow.alpha = 0
                self.lookupCoachTip.alpha = 0
                },
                completion: {
                    (b) -> Void in
                    self.lookupCoachBox.hidden = true
                    self.lookupCoachArrow.hidden = true
            })
        }
    }
    
    func showHoldCoach(showCoach: Bool, delay: Double) {
        if showCoach {
            self.holdCoachBox.hidden = false
            self.holdCoachArrow1.hidden = false
            self.holdCoachArrow2.hidden = false
            UIView.animateWithDuration(coachDelay, delay: delay, options: [], animations: {
                self.holdCoachBox.alpha = 1
                self.holdCoachArrow1.alpha = 1
                self.holdCoachArrow2.alpha = 1
            },
                completion: nil)
        }
        else {
            UIView.animateWithDuration(coachDelay, delay: delay, options: [], animations: {
                self.holdCoachBox.alpha = 0
                self.holdCoachArrow1.alpha = 0
                self.holdCoachArrow2.alpha = 0
                },
                completion: {
                    (b) -> Void in
                    self.holdCoachBox.hidden = true
                    self.holdCoachArrow1.hidden = true
                    self.holdCoachArrow2.hidden = true
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let appState = ApplicationState.sharedApplicationState()
        if !appState.lookupCoachHidden {
            showLookupCoach(true, delay: 0)
        }
        if !appState.holdCoachHidden {
            showHoldCoach(true, delay: 0)
        }
    }
    
    // MARK: - UI Stuff

    func configureView() {
        if self.detailItem == nil {
            let defaultView = NSBundle.mainBundle().loadNibNamed("DefaultDetailView", owner: self, options: nil)[0] as! UIView
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
    
    @IBAction func tappedHoldCoachBox(sender: AnyObject) {
        self.abbreviationBackgroundView.animateBounce(0.4, minScale: 0.9, maxScale: 1.3)
        self.longTextLabel.animateBounce(0.4, minScale: 0.9, maxScale: 1.3)
    }
    
    @IBAction func tappedLookupCoachBox(sender: AnyObject) {
        self.defineButton.animateBounce(0.4, minScale: 0.9, maxScale: 1.8)
    }
    
    @IBAction func tappedAbbreviation(sender: AnyObject) {
        let controller = UIMenuController.sharedMenuController()
        if controller.menuVisible == false {
            self.mostRecentViewTapped = self.abbreviationBackgroundView
            controller.setTargetRect(self.abbreviationBackgroundView.frame, inView: self.view)
            controller.setMenuVisible(true, animated: true)
            self.abbreviationBackgroundView.animateBounce(0.3, minScale: 0.93, maxScale: 1.05)
        }
        
        if ApplicationState.sharedApplicationState().holdCoachHidden == false {
            ApplicationState.sharedApplicationState().holdCoachHidden = true
            showHoldCoach(false, delay: 0.5)
        }
    }
    
    @IBAction func tappedLongText(sender: AnyObject) {
        let controller = UIMenuController.sharedMenuController()
        if controller.menuVisible == false {
            self.mostRecentViewTapped = self.longTextLabel
            controller.setTargetRect(self.longTextLabel.frame, inView: self.view)
            controller.setMenuVisible(true, animated: true)
            self.longTextLabel.animateBounce(0.3, minScale: 0.93, maxScale: 1.05)
        }
        if ApplicationState.sharedApplicationState().holdCoachHidden == false {
            ApplicationState.sharedApplicationState().holdCoachHidden = true
            showHoldCoach(false, delay: 0.5)
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
            UIView.animateWithDuration(0.05, animations: {
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
    
    @IBAction func tappedShareButton(sender: UIBarButtonItem) {
        if MFMailComposeViewController.canSendMail() {
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setSubject("Check out this abbreviation")
            composer.setMessageBody(makeHTML(), isHTML: true)
            self.presentViewController(composer, animated: true, completion: nil)
        }
    }
    
    func makeHTML() -> String {
        let displayStr: String
        if let displayText = self.detailItem.displayText {
            displayStr = "<span style=\"font-size: 200%\"><b>\(displayText)</b></span>"
        }
        else {
            let imageData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(self.detailItem.displayImage!, ofType: ".png")!)!
            let base64String: String = imageData.base64EncodedStringWithOptions([])
            displayStr = "<img height=\"30\" src=\"data:image/png;base64,\(base64String)\" />"
            print(displayStr)
        }
        let appLink = "<span style=\"font-size: 80%; color: gray\">Sent from <a href=\"#\">Inscriptus</a> for iOS</span>"
        return String("<br /><br />",
            displayStr,
            "<br />",
            self.detailItem.longText,
            "<br /><br />",
            appLink)
    }
    
    @IBAction func defineButtonPressed(sender: UIButton) {
        self.lookupDefinitions(sender)
        if ApplicationState.sharedApplicationState().lookupCoachHidden == false {
            ApplicationState.sharedApplicationState().lookupCoachHidden = true
            showLookupCoach(false, delay: 0.5)
        }
    }
    
    func lookupDefinitions(button: UIButton) {
        self.defineButton.hidden = true
        self.activityIndicator.startAnimating()
        self.whitakers.beginDefinitionRequestForWord(self.detailItem.longText, targetLanguage: .English)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showWords" {
            let def = segue.destinationViewController as! DefinitionViewController
            def.result = sender as! WhitakerResult
            def.transitioningDelegate = self
            def.modalPresentationStyle = .Custom
            def.delegate = self
            self.showHoldCoach(false, delay: 0)
        }
    }
    
    //MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - UIMenuController
    
    override func copy(sender: AnyObject?) {
        if self.mostRecentViewTapped == self.abbreviationBackgroundView {
            let pasteboard = UIPasteboard.generalPasteboard()
            if let displayText = self.detailItem.displayText {
                pasteboard.string = displayText
            }
            else if let _ = self.detailItem.displayImage {
                pasteboard.image = self.imageView.image
            }
        }
        else if self.mostRecentViewTapped == self.longTextLabel {
            let pasteboard = UIPasteboard.generalPasteboard()
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
        self.defineButton.hidden = false
        
        var message = error.localizedDescription
        if error.code == -1001 || error.code == -1004 {
            message = "\(message)\n\nIf this keeps happening, Whitaker's Words may be offline. Try again later."
        }
        let alert = UIAlertController(title: "Could not load definitions", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let frame = self.longTextLabel!.frame
        let rect = CGRect(x: frame.origin.x, y: frame.origin.y - 8, width: frame.width, height: frame.height + 23)
        let animator = foldOutAnimator(presenting: true, foldOutBelowRect: rect)
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = foldOutAnimator(presenting: false, foldOutBelowRect: self.longTextLabel.frame)
        return animator
    }
    
    //MARK: - DefinitionViewControllerDelegate
    
    func didDismissDefinitionViewController(viewController: DefinitionViewController) {
        if !ApplicationState.sharedApplicationState().holdCoachHidden {
            self.showHoldCoach(true, delay: 0)
        }
        self.defineButton.hidden = false
    }
}