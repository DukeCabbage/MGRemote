//
//  SetTripStateViewController.swift
//  MGRemote
//
//  Created by DDS Dev on 2016-06-22.
//  Copyright © 2016 Digital dispatch system. All rights reserved.
//

import UIKit

class SetTripStateViewController : UIViewController {
    
    // MARK: Properties
    private let LOGTAG : String = "SetTripStateViewController: "
    
    // MARK: Outlets
//    @IBOutlet weak var textFieldJobId: UITextField!
//    @IBOutlet weak var textFieldDestId: UITextField!
//    @IBOutlet weak var textFieldNewState: UITextField!
//    @IBOutlet weak var textFieldTotalAmount: UITextField!
//    @IBOutlet weak var textFieldTripFare: UITextField!
//    @IBOutlet weak var textFieldExtraFare: UITextField!
    
    @IBOutlet var textFields : Array<UITextField>!
    
    // MARK: Actions
    @IBAction func sendOnClick(sender: UIBarButtonItem) {
        if let validParam = getValidParam() {
            if let mRequest = NetworkManager.mInstance.buildSetTripStateRequest(validParam) {
                Utils.showNetworkIndicator(self.view, withLoadingView: true)
                NetworkManager.mInstance.sendSimulatorControlRequest(mRequest, completionHandler: setTripStateCallback)
            } else {
                print("Error building request")
            }
            
        } else {
            print(LOGTAG + "Invalid input")
        }
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        for textField in textFields {
            textField.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getValidParam() -> [String : String]? {
        var param = [String : String]()
        param["jobId"] = textFields[0].text
        param["destId"] = textFields[1].text
        param["newState"] = textFields[2].text
        param["amount"] = textFields[3].text
        param["meterFare"] = textFields[4].text
        param["expense"] = textFields[5].text
        return param
    }
    
    lazy var setTripStateCallback: (NSData?, NSURLResponse?, NSError?) -> Void = {[weak self] (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
        dispatch_async(dispatch_get_main_queue()) {
            Utils.hideNetworkIndicator(self?.view)
            
            if let error = error {
                print(error.localizedDescription)

            } else if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let body = NetworkManager.mInstance.parseXMLBody(data)
                    
                }
            }
        }
    }
}

extension SetTripStateViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let id = textField.accessibilityIdentifier {
            print(id + ": " + textField.text!)
        } else {
            print(textField.text!)
        }
    }
}