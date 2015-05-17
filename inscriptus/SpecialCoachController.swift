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
    
    @IBAction func tappedInView(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
