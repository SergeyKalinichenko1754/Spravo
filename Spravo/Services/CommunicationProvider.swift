//
//  CommunicationProvider.swift
//  Spravo
//
//  Created by Onix on 11/24/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import MessageUI

protocol CommunicationProviderType: Service {
    func callToNumber(_ number: String)
    func sendEmail(_ email: String)
    func sendSMS(_ to: String, inVC: UIViewController)
}
//TODO(Serhii K.) Fix class (fit observers for calling, message (catch status for adding to recent))
class CommunicationProvider: CommunicationProviderType {
    
    func callToNumber(_ number: String) {
        let shared = UIApplication.shared
        let clearNumber = number.filter { "0123456789".contains($0) }
        let phone = "tel://\(clearNumber)"
        let phoneFallback = "telprompt://\(clearNumber)"
        if let url = URL(string: phone), shared.canOpenURL(url) {
            shared.open(url, options: [:], completionHandler: nil)
        } else if let fallbackURl = URL(string: phoneFallback), shared.canOpenURL(fallbackURl) {
            shared.open(fallbackURl, options: [:], completionHandler: nil)
        } else {
            AlertHelper.showAlert(msg: "Enable to call")
        }
    }
    
    func sendEmail(_ email: String) {
        let shared = UIApplication.shared
        let mail = "mailto:\(email)"
        if let emailURl = URL(string: mail), shared.canOpenURL(emailURl) {
            shared.open(emailURl, options: [:], completionHandler: nil)
        } else {
            AlertHelper.showAlert(msg: "Unable to open url for send mail")
        }
    }
    
    func sendSMS(_ to: String, inVC: UIViewController) {
        if MFMessageComposeViewController.canSendText() {
            let messageController = MFMessageComposeViewController()
            let clearNumber = to.filter { "0123456789".contains($0) }
            messageController.messageComposeDelegate = inVC as? MFMessageComposeViewControllerDelegate
            messageController.recipients = [clearNumber]
            inVC.present(messageController, animated: true, completion: nil)
        } else {
            AlertHelper.showAlert(msg: "Unable to send SMS to \(to)")
        }
    }
}
