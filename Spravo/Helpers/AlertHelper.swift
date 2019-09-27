//
//  AlertHelper.swift
//  Spravo
//
//  Created by Onix on 9/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import Foundation
import UIKit

class AlertHelper {
    
    class func showAlert(_ error: String?) {
        showAlert(msg: error)
    }
    
    class func getTopController(from: UIViewController? = nil) -> UIViewController? {
        if let controller = from {
            return controller
        } else if var controller = UIApplication.shared.keyWindow?.rootViewController {
            while let presented = controller.presentedViewController {
                controller = presented
            }
            return controller
        }
        return nil
    }
    
    class func showAlert(_ title: String? = nil, msg: String?, from: UIViewController? = nil, leftBtnTitle: String? = nil, rightBtnTitle: String? = nil, completion: SimpleClosure<Bool>? = nil) {
        let alertTitle = title ?? "Common.Error".localized
        let alertMsg = msg ?? ""
        let alertLeftBtnTitle = leftBtnTitle ?? "Common.OK".localized
        DispatchQueue.main.async {
            HUDRenderer.hideHUD()
            guard let root = getTopController(from: from) else { return }
            let alertVC = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
            let ok = UIAlertAction(title: alertLeftBtnTitle, style: .default, handler: { _ in
                alertVC.dismiss(animated: true, completion: nil)
                completion?(false)
            })
            alertVC.addAction(ok)
            if let alertRightBtnTitle = rightBtnTitle {
                let action = UIAlertAction(title: alertRightBtnTitle, style: .default, handler: { _ in
                    alertVC.dismiss(animated: true, completion: nil)
                    completion?(true)
                })
                alertVC.addAction(action)
                alertVC.preferredAction = action
            }
            root.present(alertVC, animated: true, completion: nil)
        }
    }
    
    class func showAlert(msg: String?, from: UIViewController? = nil, leftBtnTitle: String? = nil, rightBtnTitle: String? = nil, completion: SimpleClosure<Bool>? = nil) {
        let alertMsg = msg ?? ""
        let alertLeftBtnTitle = leftBtnTitle ?? "Common.OK".localized
        DispatchQueue.main.async {
            HUDRenderer.hideHUD()
            guard let root = getTopController(from: from) else { return }
            let alertVC = UIAlertController(title: nil, message: alertMsg, preferredStyle: .alert)
            let ok = UIAlertAction(title: alertLeftBtnTitle, style: .default, handler: { _ in
                alertVC.dismiss(animated: true, completion: nil)
                completion?(false)
            })
            alertVC.addAction(ok)
            if let alertRightBtnTitle = rightBtnTitle {
                let action = UIAlertAction(title: alertRightBtnTitle, style: .default, handler: { _ in
                    alertVC.dismiss(animated: true, completion: nil)
                    completion?(true)
                })
                alertVC.addAction(action)
            }
            root.present(alertVC, animated: true, completion: nil)
        }
    }
    
    class func createAlert(_ from: String) -> Error {
        let error = NSError(domain: "domain", code: 400, userInfo: [NSLocalizedDescriptionKey : from])
        return error
    }
}
