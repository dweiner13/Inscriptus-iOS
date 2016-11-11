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
    
    var coachTips: [(box: UIView?, arrows: [UIView?])]?
    
    let shouldShowCoachTips = true
    
    let coachDelay: TimeInterval = 0.5
    
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
            self.abbreviationBackgroundView.layer.borderColor = INSCRIPTUS_TINT_COLOR.cgColor
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
                coachTip.box?.layer.cornerRadius = 5
                coachTip.box?.alpha = 0
                coachTip.box?.isHidden = true
                for arrow in coachTip.arrows {
                    arrow?.isHidden = true
                    arrow?.alpha = 0
                }
            }
        }
    }
    
    func showLookupCoach(_ showCoach: Bool, delay: Double) {
        if showCoach {
            self.lookupCoachBox.isHidden = false
            self.lookupCoachArrow.isHidden = false
            self.lookupCoachTip.isHidden = false
            UIView.animate(withDuration: coachDelay, delay: delay, options: [], animations: {
                self.lookupCoachBox.alpha = 1
                self.lookupCoachArrow.alpha = 1
                self.lookupCoachTip.alpha = 1
            },
                completion: nil)
        }
        else {
            UIView.animate(withDuration: coachDelay, delay: delay, options: [], animations: {
                self.lookupCoachBox.alpha = 0
                self.lookupCoachArrow.alpha = 0
                self.lookupCoachTip.alpha = 0
                },
                completion: {
                    (b) -> Void in
                    self.lookupCoachBox.isHidden = true
                    self.lookupCoachArrow.isHidden = true
            })
        }
    }
    
    func showHoldCoach(_ showCoach: Bool, delay: Double) {
        if showCoach {
            self.holdCoachBox.isHidden = false
            self.holdCoachArrow1.isHidden = false
            self.holdCoachArrow2.isHidden = false
            UIView.animate(withDuration: coachDelay, delay: delay, options: [], animations: {
                self.holdCoachBox.alpha = 1
                self.holdCoachArrow1.alpha = 1
                self.holdCoachArrow2.alpha = 1
            },
                completion: nil)
        }
        else {
            UIView.animate(withDuration: coachDelay, delay: delay, options: [], animations: {
                self.holdCoachBox.alpha = 0
                self.holdCoachArrow1.alpha = 0
                self.holdCoachArrow2.alpha = 0
                },
                completion: {
                    (b) -> Void in
                    self.holdCoachBox.isHidden = true
                    self.holdCoachArrow1.isHidden = true
                    self.holdCoachArrow2.isHidden = true
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
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
            let defaultView = Bundle.main.loadNibNamed("DefaultDetailView", owner: self, options: nil)?[0] as! UIView
            self.view = defaultView
        }
        else {
            if let displayText = self.detailItem.displayText {
                self.imageView.isHidden = true
                self.abbreviationLabel.text = displayText.replacingOccurrences(of: "·", with: "")
                self.abbreviationLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyle.body.rawValue, scaleFactor: 1.9)
            }
            else if let displayImage = self.detailItem.displayImage {
                self.abbreviationLabel.isHidden = true
                self.imageView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: displayImage, ofType: ".png")!)!
                self.imageView.contentMode = UIViewContentMode.scaleAspectFit
            }
            self.longTextLabel.text = self.detailItem.longText
            self.longTextLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyle.body.rawValue, scaleFactor: 1.2)
            if AbbreviationCollection.sharedAbbreviationCollection.favorites.contains(self.detailItem) {
                self.favoriteButton.setTitle("Remove from favorites", for: UIControlState())
                self.favoriteButton.tintColor = UIColor.white
                self.favoriteButtonBackgroundView.backgroundColor = INSCRIPTUS_TINT_COLOR
            }
            else {
                self.favoriteButton.setTitle("Add to favorites", for: UIControlState())
                self.favoriteButtonBackgroundView.backgroundColor = UIColor.clear
            }
            self.favoriteButtonBackgroundView.layer.cornerRadius = 7
        }
    }
    
    @IBAction func tappedHoldCoachBox(_ sender: AnyObject) {
        self.abbreviationBackgroundView.animateBounce(0.4, minScale: 0.9, maxScale: 1.3)
        self.longTextLabel.animateBounce(0.4, minScale: 0.9, maxScale: 1.3)
    }
    
    @IBAction func tappedLookupCoachBox(_ sender: AnyObject) {
        self.defineButton.animateBounce(0.4, minScale: 0.9, maxScale: 1.8)
    }
    
    @IBAction func tappedAbbreviation(_ sender: AnyObject) {
        let controller = UIMenuController.shared
        if controller.isMenuVisible == false {
            self.mostRecentViewTapped = self.abbreviationBackgroundView
            controller.setTargetRect(self.abbreviationBackgroundView.frame, in: self.view)
            controller.setMenuVisible(true, animated: true)
            self.abbreviationBackgroundView.animateBounce(0.3, minScale: 0.93, maxScale: 1.05)
        }
        
        if ApplicationState.sharedApplicationState().holdCoachHidden == false {
            ApplicationState.sharedApplicationState().holdCoachHidden = true
            showHoldCoach(false, delay: 0.5)
        }
    }
    
    @IBAction func tappedLongText(_ sender: AnyObject) {
        let controller = UIMenuController.shared
        if controller.isMenuVisible == false {
            self.mostRecentViewTapped = self.longTextLabel
            controller.setTargetRect(self.longTextLabel.frame, in: self.view)
            controller.setMenuVisible(true, animated: true)
            self.longTextLabel.animateBounce(0.3, minScale: 0.93, maxScale: 1.05)
        }
        if ApplicationState.sharedApplicationState().holdCoachHidden == false {
            ApplicationState.sharedApplicationState().holdCoachHidden = true
            showHoldCoach(false, delay: 0.5)
        }
    }
    
    @IBAction func tappedFavoriteButton(_ sender: UIButton) {
        if AbbreviationCollection.sharedAbbreviationCollection.favorites.contains(self.detailItem) {
            AbbreviationCollection.sharedAbbreviationCollection.removeFavorite(self.detailItem)
            self.favoriteButton.setTitle("Add back to favorites", for: UIControlState())
            self.favoriteButton.tintColor = INSCRIPTUS_TINT_COLOR
            UIView.animate(withDuration: 0.2, animations: {
                () -> Void in
                self.favoriteButtonBackgroundView.backgroundColor = UIColor.clear
                self.favoriteButtonBackgroundView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
                },
                completion: {
                    (b) -> Void in
                    self.favoriteButtonBackgroundView.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
        else {
            AbbreviationCollection.sharedAbbreviationCollection.addFavorite(self.detailItem)
            self.favoriteButton.setTitle("Remove from favorites", for: UIControlState())
            self.favoriteButton.tintColor = UIColor.white
            self.favoriteButtonBackgroundView.backgroundColor = INSCRIPTUS_TINT_COLOR
            UIView.animate(withDuration: 0.05, animations: {
                () -> Void in
                self.favoriteButtonBackgroundView.backgroundColor = INSCRIPTUS_TINT_COLOR
                self.favoriteButtonBackgroundView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                },
                completion: {
                    (b) -> Void in
                    UIView.animate(withDuration: 0.12, animations: {
                        self.favoriteButtonBackgroundView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
                        },
                        completion: {
                            (b) -> Void in
                            UIView.animate(withDuration: 0.12, animations: {
                                self.favoriteButtonBackgroundView.transform = CGAffineTransform(scaleX: 1, y: 1)
                            })
                    })
            })
        }
    }
    
    @IBAction func tappedShareButton(_ sender: UIBarButtonItem) {
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setSubject("Check out this abbreviation")
        composer.setMessageBody(makeHTML(), isHTML: true)
        self.present(composer, animated: true, completion: nil)
    }
    
    func makeHTML() -> String {
        let displayStr: String
        if let displayText = self.detailItem.displayText {
            displayStr = "<span style=\"font-size: 200%\"><b>\(displayText)</b></span>"
        }
        else {
            let imageData = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: self.detailItem.displayImage!, ofType: ".png")!))
            let base64String: String = imageData.base64EncodedString(options: [])
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
    
    @IBAction func defineButtonPressed(_ sender: UIButton) {
        self.lookupDefinitions(sender)
        if ApplicationState.sharedApplicationState().lookupCoachHidden == false {
            ApplicationState.sharedApplicationState().lookupCoachHidden = true
            showLookupCoach(false, delay: 0.5)
        }
    }
    
    func lookupDefinitions(_ button: UIButton) {
        self.defineButton.isHidden = true
        self.activityIndicator.startAnimating()
        self.whitakers.beginDefinitionRequestForWord(self.detailItem.longText, targetLanguage: .english)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWords" {
            let def = segue.destination as! DefinitionViewController
            def.result = sender as! WhitakerResult
            def.transitioningDelegate = self
            def.modalPresentationStyle = .custom
            def.delegate = self
            self.showHoldCoach(false, delay: 0)
        }
    }
    
    //MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UIMenuController
    
    override func copy(_ sender: Any?) {
        if self.mostRecentViewTapped == self.abbreviationBackgroundView {
            let pasteboard = UIPasteboard.general
            if let displayText = self.detailItem.displayText {
                pasteboard.string = displayText
            }
            else if let _ = self.detailItem.displayImage {
                pasteboard.image = self.imageView.image
            }
        }
        else if self.mostRecentViewTapped == self.longTextLabel {
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.detailItem.longText
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return true
        }
        else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    //MARK: - WhitakerScraperDelegate
    
    func whitakerScraper(_ scraper: WhitakerScraper, didLoadResult result: WhitakerResult) {
        self.activityIndicator.stopAnimating()
        self.performSegue(withIdentifier: "showWords", sender: result)
    }
    
    func whitakerScraper(_ scraper: WhitakerScraper, didFailWithError error: NSError) {
        self.activityIndicator.stopAnimating()
        self.defineButton.isHidden = false
        
        var message = error.localizedDescription
        if error.code == -1001 || error.code == -1004 {
            message = "\(message)\n\nIf this keeps happening, Whitaker's Words may be offline. Try again later."
        }
        let alert = UIAlertController(title: "Could not load definitions", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let frame = self.longTextLabel!.frame
        let rect = CGRect(x: frame.origin.x, y: frame.origin.y - 8, width: frame.width, height: frame.height + 23)
        let animator = foldOutAnimator(presenting: true, foldOutBelowRect: rect)
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = foldOutAnimator(presenting: false, foldOutBelowRect: self.longTextLabel.frame)
        return animator
    }
    
    //MARK: - DefinitionViewControllerDelegate
    
    func didDismissDefinitionViewController(_ viewController: DefinitionViewController) {
        if !ApplicationState.sharedApplicationState().holdCoachHidden {
            self.showHoldCoach(true, delay: 0)
        }
        self.defineButton.isHidden = false
    }
}
