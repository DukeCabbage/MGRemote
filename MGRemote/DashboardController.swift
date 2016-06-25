//
//  DashboardController.swift
//  MGRemote
//
//  Created by DDS Dev on 2016-06-20.
//  Copyright © 2016 Digital dispatch system. All rights reserved.
//

import UIKit
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
            print(identifier + "on click")
            switch identifier {
            case "btnChangeUrl":
                self.performSegueWithIdentifier("showPicker", sender: self)
            case "btnSetTripState":
                self.performSegueWithIdentifier("setTripState", sender: self)
                break
            default: break
            }
            
        }
    }
    
    @IBAction func toggleSimulator(sender: UISwitch) {
        if let mRequest = NetworkManager.mInstance.buildSimulatorRequest(sender.on ? "turnOff" : "turnOn") {
            Utils.showNetworkIndicator(self.view, withLoadingView: true)
            NetworkManager.mInstance.sendRequest(mRequest, completionHandler: simulatorStatusCallback)
        } else {
            disableSimulationSwitch("Error sending request")
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(LOGTAG + "prepareForSegue \(segue.identifier!)")
    }
    
    @IBAction func unwindToDashboard(sender: UIStoryboardSegue) {
        if sender.sourceViewController as? EndpointPickerController != nil {
            print(LOGTAG + "unwind from picker")
            refreshAfterEndpointChanged()
        }
    }

    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        print(LOGTAG + "viewDidLoad")
        refreshAfterEndpointChanged()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refreshAfterEndpointChanged() {
        print(LOGTAG + "refreshData")
        tvCurrentUrl.text = Config.getUrl()
        
        if let mRequest = NetworkManager.mInstance.buildSimulatorRequest("checkState") {
            Utils.showNetworkIndicator(self.view, withLoadingView: true)
            NetworkManager.mInstance.sendRequest(mRequest, completionHandler: simulatorStatusCallback)
        } else {
            disableSimulationSwitch("Error sending request")
        }
    }
    
    func toggleSimulatorSwitch(on : Bool, withMessage : String? = nil) {
        switchSimulator.enabled = true
        switchSimulator.setOn(on, animated: true)
        tvNoSimulator.text = withMessage ?? (on ? "Simulator is turned on" : "Simulator is turned off")
    }
    
    func disableSimulationSwitch(withMessage : String? = nil) {
        switchSimulator.setOn(false, animated: false)
        switchSimulator.enabled = false
        tvNoSimulator.text = withMessage ?? "Network unavailable"
    }
    
    lazy var simulatorStatusCallback: (NSData?, NSURLResponse?, NSError?) -> Void = {[weak self] (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
        dispatch_async(dispatch_get_main_queue()) {
            Utils.hideNetworkIndicator(self?.view)
            
            if let error = error {
                print(error.localizedDescription)
                self?.disableSimulationSwitch(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let body = NetworkManager.mInstance.parseXMLBody(data)
                    
                    guard case let response = body?.children[0].children[0] where response?.error == nil else {
                        print("Error: no matching response found")
                        self?.disableSimulationSwitch()
                        return
                    }
                    
                    let result = response?.stringValue
                    
                    if result == "Simulation is running" {
                        self?.toggleSimulatorSwitch(true, withMessage: result)
                    } else if result == "Simulation is not running" {
                        self?.toggleSimulatorSwitch(false, withMessage: result)
                    } else  {
                        self?.disableSimulationSwitch(result)
                    }
                }
            }
        }
    }
}












