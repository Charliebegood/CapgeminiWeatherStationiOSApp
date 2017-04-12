//
//  AboutViewController.swift
//  CapGemini_Weather
//
//  Created by Aubert Charles on 08/02/2017.
//  Copyright © 2017 Charles. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class AboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    //# MARK: - Variables
    @IBOutlet weak var appInfoLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var iconImageView: UIImageView!
    let images = ["bugreport.png", "suggestion.png"]
    let titles = ["Encountering a problem?", "An idea?"]
    let descriptions = ["Click here to report an issue.", "Click here to send your suggestions."]
    let body = ["We're sorry to hear that you've encountered a problem while using our service. Although we're a very small structure, we will get back to you as soon as we can. Please decribe your issue here:", "We're opened to any king of suggestions, really! Although we're a very small structure, we will get back to you as soon as we can. Please decribe your sugestion here:"]
    let subject = ["Bug report :(", "Suggestion for WeatherBox :)"]
    //# MARK: End of variables
    
    
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iconImageView.layer.cornerRadius = 16.0
        iconImageView.layer.masksToBounds = true
        aboutTextView.isEditable = false
        contactTableView.delegate = self
        contactTableView.dataSource = self
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let systemVersion = UIDevice.current.systemVersion
            appInfoLabel.text = ("App version: \(version) | iOS version: \(systemVersion)")
        }
    }
    

    //Modify the color of the status bar to light content
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    
    
    
    
    //# MARK: - Email functions
    func sendEmail(subject: String, body: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["weather.box31@gmail.com"])
            mail.setSubject(subject)
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                let systemVersion = UIDevice.current.systemVersion
                mail.setMessageBody("\(body)\nApp version: \(version) | iOS version: \(systemVersion)", isHTML: false)
            }
            present(mail, animated: true)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could not send e-mail", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        
        
        sendMailErrorAlert.addAction(OKAction)
        self.present(sendMailErrorAlert, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        var title = "Title"
        var description = "Description"
        
        
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            title = "E-mail cancelled"
            description = "The e-mail was cancelled."
        case MFMailComposeResult.saved.rawValue:
            title = "E-mail saved"
            description = "The e-mail was saved."
        case MFMailComposeResult.sent.rawValue:
            title = "E-mail sent"
            description = "The e-mail was successfully sent."
        case MFMailComposeResult.failed.rawValue:
            print("Mail sent failure: %@", [error!.localizedDescription])
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
        let sendMailErrorAlert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        sendMailErrorAlert.addAction(OKAction)
        self.present(sendMailErrorAlert, animated: true)
    }
    //# MARK: - END of Email functions
    
    
    
    
    
    
    //# MARK: - TableViewProtocol
    //Function that counts the number of cells to be displayed
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    //Returns the height of each cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //Call the email sender function
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendEmail(subject: subject[indexPath.row], body: body[indexPath.row])
    }
    
    //Fill the tableView with content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId: String = "defaultCell"
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId)! as UITableViewCell
        let imagePlace = cell.contentView.viewWithTag(2) as! UIImageView
        let nameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let descriptionLabel = cell.contentView.viewWithTag(3) as! UILabel

        
        //Content views identified by tags to fill table view with proper content at the right place
        imagePlace.image = UIImage(named : images[indexPath.row])
        cell.selectionStyle = .none
        nameLabel.text = titles[indexPath.row]
        descriptionLabel.text = descriptions[indexPath.row]
        return cell
    }
    //# MARK: END of TableViewProtocol
    
    
    
    
    
    
    //Dismiss the current view controller on press of the cross button
    @IBAction func return_home(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
}
