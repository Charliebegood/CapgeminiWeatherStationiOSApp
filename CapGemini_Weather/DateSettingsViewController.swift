//
//  DateSettings.swift
//  CapGemini_Weather
//
//  Created by Charles AUBERT on 14/05/2017.
//  Copyright © 2017 Charles. All rights reserved.
//

import Foundation
import UIKit

class DateSettingsViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    //Modify the color of the status bar to light content
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    //Dismiss the current view controller
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
