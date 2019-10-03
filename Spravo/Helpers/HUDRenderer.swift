//
//  HUDRenderer.swift
//  Spravo
//
//  Created by Onix on 9/27/19.
//  Copyright © 2019 Home. All rights reserved.
//

import MBProgressHUD

class HUDRenderer {
    
    class func showHUD() {
        updateUIonMainThread {
            guard let view = UIApplication.shared.keyWindow else { return }
            MBProgressHUD.hide(for: view, animated: false)
            MBProgressHUD.showAdded(to: view, animated: true)
        }
    }
    
    class func hideHUD() {
        updateUIonMainThread {
            guard let view = UIApplication.shared.keyWindow else { return }
            MBProgressHUD.hide(for: view, animated: true)
        }
    }
}
