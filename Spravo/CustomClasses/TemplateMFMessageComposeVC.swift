//
//  TemplateMFMessageComposeVC.swift
//  Spravo
//
//  Created by Onix on 12/1/19.
//  Copyright © 2019 Home. All rights reserved.
//

import UIKit
import MessageUI
import CallKit

class TemplateMFMessageComposeVC: UIViewController, MFMessageComposeViewControllerDelegate, CXCallObserverDelegate {
    
    var addToRecent: ((Recent?) -> ())?
    var phoneCallObserver: CXCallObserver? = nil
    var currentCall: Recent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startObserver()
    }
    
    private func startObserver() {
        guard phoneCallObserver == nil else { return }
        phoneCallObserver = CXCallObserver()
        phoneCallObserver?.setDelegate(self, queue: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        guard let returnResult = addToRecent else { return }
        if result != .sent {
            controller.dismiss(animated: true, completion: nil)
            returnResult(nil)
            return
        }
        currentCall?.completionDate = Date()
        controller.dismiss(animated: true, completion: nil)
        returnResult(currentCall)
    }
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        guard call.isOutgoing else { return }
        if call.hasConnected == true && call.hasEnded == false && currentCall?.beganTalkDate == nil {
            currentCall?.beganTalkDate = Date()
        }
        if call.hasEnded && currentCall?.completionDate == nil {
            currentCall?.completionDate = Date()
            guard let returnResult = addToRecent else { return }
            returnResult(currentCall)
            currentCall = nil
        }
    }
}
