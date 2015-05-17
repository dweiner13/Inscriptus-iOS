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
    
    @IBOutlet weak var actionCoachBox: UIView!
    @IBOutlet weak var actionCoachView: UIView!
    @IBOutlet weak var lookupCoachBox: UIView!
    @IBOutlet weak var lookupCoachArrow: UIView!
    @IBOutlet weak var favoriteCoachBox: UIView!
    @IBOutlet weak var favoriteCoachArrow: UIView!
    
    var mostRecentViewTapped: UIView?
    var whitakers = WhitakerScraper()
    
    var coachTips: [(box: UIView!, arrow: UIView!)]?
    
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
            if !MFMailComposeViewController.canSendMail() {
                self.navigationItem.rightBarButtonItem = nil
            }
            self.whitakers.delegate = self
            self.definesPresentationContext = true
            self.abbreviationBackgroundView.layer.cornerRadius = 5
            self.abbreviationBackgroundView.layer.borderColor = INSCRIPTUS_TINT_COLOR.CGColor
            self.abbreviationBackgroundView.layer.borderWidth = 1
            
            self.coachTips = [
                (box: self.actionCoachBox, arrow: self.actionCoachView),
                (box: self.lookupCoachBox, arrow: self.lookupCoachArrow),
                (box: self.favoriteCoachBox, arrow: self.favoriteCoachArrow)
            ]
            for coachTip in self.coachTips! {
                coachTip.box.layer.cornerRadius = 5
                coachTip.box.alpha = 0
                coachTip.arrow.alpha = 0
                coachTip.box.hidden = true
                coachTip.arrow.hidden = true
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        for coachTip in self.coachTips! {
            coachTip.box.hidden = false
            coachTip.arrow.hidden = false
        }
        UIView.animateWithDuration(0.5, animations: {
            for coachTip in self.coachTips! {
                coachTip.box.alpha = 1
                coachTip.arrow.alpha = 1
            }
        })
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
            displayStr = "<span style=\"font-size: 200%\"><b>\(self.detailItem.displayText!)</b></span>"
        }
        else {
            let imageData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(self.detailItem.displayImage!, ofType: ".png")!)!
            let base64String: String = imageData.base64EncodedStringWithOptions(nil)
            displayStr = "<img height=\"30\" src=\"data:image/png;base64,\(base64String)\" />"
            println(displayStr)
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
    
    //MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
        self.defineButton.hidden = false
        
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