//
//  DashboardController.swift
//  MGRemote
//
//  Created by DDS Dev on 2016-06-20.
//  Copyright © 2016 Digital dispatch system. All rights reserved.
//

import UIKit
import MBProgressHUD
import AEXML

class DashboardController: UIViewController {
    
    // MARK: Properties
    private let LOGTAG : String = "DashboardController: "
    
    // MARK: Outlets
    @IBOutlet weak var tvCurrentUrl: UILabel!
    @IBOutlet weak var tvNoSimulator: UILabel!
    @IBOutlet weak var switchSimulator: UISwitch!
    
    // MARK: Actions
    @IBAction func buttonOnClick(sender: UIButton) {
        if let identifier = sender.accessibilityIdentifier {
            print(identifier)
            self.performSegueWithIdentifier("showPicker", sender: self)
        }
    }
    
    @IBAction func toggleSimulator(sender: UISwitch) {
        if sender.on {
            tvNoSimulator.text = "Simulator is on"
        } else {
            tvNoSimulator.text = "Simulator is off"
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPicker" {
            print(LOGTAG + "prepareForSegue")
        }
    }
    
    @IBAction func unwindToDashboard(sender: UIStoryboardSegue) {
        if sender.sourceViewController as? EndpointPickerController != nil {
            print(LOGTAG + "unwind from picker")
            refreshData()
        }
    }

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        print(LOGTAG + "viewDidLoad")
        refreshData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshData() {
        print(LOGTAG + "refreshData")
        tvCurrentUrl.text = Config.getUrl()
    }
}
