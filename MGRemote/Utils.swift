//
//  Utils.swift
//  MGRemote
//
//  Created by DDS Dev on 2016-06-23.
//  Copyright © 2016 Digital dispatch system. All rights reserved.
//

import UIKit
import MBProgressHUD

class Utils {
    static func showNetworkIndicator(rootView : UIView, withLoadingView : Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if withLoadingView {
            let hud = MBProgressHUD.showHUDAddedTo(rootView, animated: true)
            hud.labelText = "Loading..."
        }
    }
    
    static func hideNetworkIndicator(rootView : UIView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        MBProgressHUD.hideAllHUDsForView(rootView, animated: true)
    }
}

