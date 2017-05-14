//
//  DateSettings.swift
//  CapGemini_Weather
//
//  Created by Charles AUBERT on 14/05/2017.
//  Copyright © 2017 Charles. All rights reserved.
//

import Foundation
import UIKit

class DateSettingsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var fromLabel: UITextField!
    @IBOutlet weak var toLabel: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fromLabel.delegate = self
        self.toLabel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let dateFromtext = UserDefaults.standard.object(forKey: "dateFrom") as? String {
            fromLabel.text = dateFromtext
        } else {
            fromLabel.text = "2000-01-01:00-00-00"
        }
        if let dateTotext = UserDefaults.standard.object(forKey: "dateTo") as? String {
            toLabel.text = dateTotext
        } else {
            toLabel.text = "2000-01-01:00-00-00"
        }
    }
    
    //Modify the color of the status bar to light content
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        let tmpFrom = self.fromLabel.text
        let tmpTo = self.toLabel.text

        
        UserDefaults.standard.set(tmpFrom, forKey: "dateFrom")
        UserDefaults.standard.set(tmpTo, forKey: "dateTo")
        UserDefaults.standard.synchronize()
        return false
    }
    
    //Dismiss the current view controller
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.view.endEditing(true)
    }
}
