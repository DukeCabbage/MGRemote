//
//  SimulatorStatusVC.swift
//  MGRemote
//
//  Created by DDS Dev on 2016-06-13.
//  Copyright © 2016 Digital dispatch system. All rights reserved.
//

import UIKit
import MBProgressHUD
import AEXML

class SimulatorStatusVC: UIViewController {
    
    let endPoint: String = "http://192.168.50.160:78/Service.asmx";
    var url: NSURL? {
        get {
            return NSURL(string: endPoint)
        }
    }
    var currentElement: String?

    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var dataTask: NSURLSessionDataTask?
    
    // MARK: Outlets
    @IBOutlet weak var labelSimulatorStatus: UILabel!

    // MARK: Actions
    @IBAction func isSimulatorRunning(sender: UIButton) {
        let request = buildSoapRequest()
        print(request.xmlString + "\n")
        sendRequest(request.xmlString)
    }
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buildSoapRequest() -> AEXMLDocument {
        let soapRequest = AEXMLDocument()
        let attributes = ["xmlns:xsi" : "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" : "http://www.w3.org/2001/XMLSchema", "xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: attributes)
        let body = envelope.addChild(name: "soap:Body")
        body.addChild(name: "IsSimulationRunning", attributes: ["xmlns" : "http://iis.com.dds.osp.itaxi.interface/"])
        
        return soapRequest
    }
    
    func sendRequest(requestMsg: String) {
        if dataTask != nil {
            dataTask?.cancel()
        }
        
        let theRequest = NSMutableURLRequest(URL: url!)
        let msgLength = requestMsg.characters.count
        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        theRequest.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
        theRequest.addValue("http://iis.com.dds.osp.itaxi.interface/IsSimulationRunning", forHTTPHeaderField:"SOAPAction")
        theRequest.HTTPMethod = "POST"
        theRequest.HTTPBody = requestMsg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) // or false
        
        showNetworkIndicator()
        dataTask = defaultSession.dataTaskWithRequest(theRequest, completionHandler: { (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.hideNetworkIndicator()
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
//                print(httpResponse)
                if httpResponse.statusCode == 200 {
//                    let meow = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                    print(meow)
                    
                    let xmlData = self.parseXMLData(data)!
                    print(xmlData.xmlString + "\n")

                    guard case let envelope = xmlData["soap:Envelope"] where envelope.error == nil,
                    case let body = envelope["soap:Body"] where body.error == nil else {
                        print("Error: wrong format of soap object")
                        return
                    }
                    
                    guard case let response = body["IsSimulationRunningResponse"] where response.error == nil else {
                        print("Error: no matching response found")
                        return
                    }
                    
                    print(response["IsSimulationRunningResult"].stringValue)
                    self.labelSimulatorStatus.text = response["IsSimulationRunningResult"].stringValue
                }
            }
        })
        
        dataTask?.resume()
    }
    
    func parseXMLData(data : NSData?) -> AEXMLDocument? {
        do {
            let xmlDoc = try AEXMLDocument(xmlData: data!)
            return xmlDoc
        } catch {
            print("\(error)")
            return nil
        }
    }
    
    func showNetworkIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Loading..."
    }
    
    func hideNetworkIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
}







