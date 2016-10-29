//
//  SpecialCoachController.swift
//  inscriptus
//
//  Created by Daniel A. Weiner on 5/16/15.
//  Copyright (c) 2015 Daniel Weiner. All rights reserved.
//

import UIKit

class SpecialCoachController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.cornerRadius = 10
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedInView(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        ApplicationState.sharedApplicationState().specialCoachHidden = true
    }
    
    func tappedOutsideModal(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        ApplicationState.sharedApplicationState().specialCoachHidden = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
