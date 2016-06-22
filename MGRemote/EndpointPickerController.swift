//
//  EndpointPickerController.swift
//  MGRemote
//
//  Created by DDS Dev on 2016-06-21.
//  Copyright © 2016 Digital dispatch system. All rights reserved.
//

import UIKit

class EndpointPickerController : UIViewController {
    
    // MARK: Properties
    private let LOGTAG : String = "EndpointPickerController: "
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var picker: UIPickerView!
    
    var pickerData : [Config.Endpoint] = []
    
    // MARK: Actions
    @IBAction func confirmOnClick(sender: UIButton) {
        let pickedIndex = picker.selectedRowInComponent(0)
        Config.switchUrl(pickerData[pickedIndex])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        print(LOGTAG + "prepareForSegue")
//    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        print(LOGTAG + "viewDidLoad")
        popupView.layer.cornerRadius = 10
        setupPicker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension EndpointPickerController : UIPickerViewDelegate, UIPickerViewDataSource {
    private func setupPicker() {
        picker.delegate = self
        picker.dataSource = self
        
        pickerData = Config.Endpoint.allValues
        picker.selectRow(pickerData.indexOf(Config.getEndpoint()) ?? 0, inComponent: 0, animated: false)
    }
    
    // Protocol
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row])"
    }
}