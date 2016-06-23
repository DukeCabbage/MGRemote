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
    var dataTask: NSURLSessionDataTask?
    
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
        if sender.on {
            tvNoSimulator.text = "Simulator is on"
        } else {
            tvNoSimulator.text = "Simulator is off"
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
        
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        if let mRequest = NetworkManager.mInstance.sendSimulatorRequest("checkState") {
            Utils.showNetworkIndicator(self.view, withLoadingView: true)
            dataTask = NetworkManager.mInstance.defaultSession.dataTaskWithRequest(mRequest, completionHandler: { (data, response, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    Utils.hideNetworkIndicator(self.view)
                    
                    if let error = error {
                        print(error.localizedDescription)
                        self.disableSimulationSwitch(error.localizedDescription)
                    } else if let httpResponse = response as? NSHTTPURLResponse {
                        // print(httpResponse)
                        if httpResponse.statusCode == 200 {
                            let xmlData = NetworkManager.mInstance.parseXMLData(data)!
                            print(xmlData.xmlString + "\n")
                            
                            guard case let envelope = xmlData["soap:Envelope"] where envelope.error == nil,
                                case let body = envelope["soap:Body"] where body.error == nil else {
                                    print("Error: wrong format of soap object")
                                    self.disableSimulationSwitch(nil)
                                    return
                            }
                            
                            guard case let response = body["IsSimulationRunningResponse"] where response.error == nil else {
                                print("Error: no matching response found")
                                self.disableSimulationSwitch(nil)
                                return
                            }
                            
                            let result = response["IsSimulationRunningResult"].stringValue
                            self.tvNoSimulator.text = result
                            
                            if result == "Simulation is running" {
                                self.switchSimulator.enabled = true
                                self.switchSimulator.setOn(true, animated: true)
                            } else if result == "Simulation is not running" {
                                self.switchSimulator.enabled = true
                                self.switchSimulator.setOn(false, animated: true)
                            } else  {
                                self.disableSimulationSwitch("Simulation not supported")
                            }
                        }
                    }
                }
            })
            
            dataTask?.resume()
        } else {
            disableSimulationSwitch("Error sending request")
        }
    }
    
    func disableSimulationSwitch(withMessage : String?) {
        switchSimulator.setOn(false, animated: false)
        switchSimulator.enabled = false
        tvNoSimulator.text = withMessage ?? "Network unavailable"
    }
}
