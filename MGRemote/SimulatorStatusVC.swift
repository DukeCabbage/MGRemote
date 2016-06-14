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
//    var mutableData: NSMutableData = NSMutableData()
    
    // Session way
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var dataTask: NSURLSessionDataTask?
    
    // MARK: Outlets
    @IBOutlet weak var labelSimulatorStatus: UILabel!

    // MARK: Actions
    @IBAction func isSimulatorRunning(sender: UIButton) {
        print("buton hit");
        let request = buildSoapRequest()
        print(request.xmlString)
        sendRequest2(request.xmlString)
        
//        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
//        hud.labelText = "Loading..."
//        
//        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 2 * Int64(NSEC_PER_SEC))
//        dispatch_after(time, dispatch_get_main_queue()) {
//            self.labelSimulatorStatus.text = "This is the result"
//            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
//        }
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
    
//    func sendRequest(requestMsg: String) {
//        let theRequest = NSMutableURLRequest(URL: url!)
//        let msgLength = requestMsg.characters.count
//        theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
//        theRequest.addValue(String(msgLength), forHTTPHeaderField: "Content-Length")
//        theRequest.addValue("http://iis.com.dds.osp.itaxi.interface/IsSimulationRunning", forHTTPHeaderField:"SOAPAction")
//        theRequest.HTTPMethod = "POST"
//        theRequest.HTTPBody = requestMsg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) // or false
//        
//        let connection = NSURLConnection(request: theRequest, delegate: self, startImmediately: true)
//        connection!.start()
//        
//        if (connection == true) {
//            var mutableData : Void = NSMutableData.initialize()
//        }
//    }
    
    func sendRequest2(requestMsg: String) {
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
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        dataTask = defaultSession.dataTaskWithRequest(theRequest, completionHandler: { (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? NSHTTPURLResponse {
                print(httpResponse)
                if httpResponse.statusCode == 200 {
                    let meow = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print(meow)
                    
                    let xmlParser = NSXMLParser(data: data!)
                    xmlParser.delegate = self
                    xmlParser.parse()
                    xmlParser.shouldResolveExternalEntities = true
                }
            }
        })
        
        dataTask?.resume()
    }
}

extension SimulatorStatusVC: NSXMLParserDelegate {
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributesDict: [String : String]) {
        currentElement = elementName
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        print(currentElement)
    }
}

//extension SimulatorStatusVC: NSURLConnectionDelegate {
//    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
//        print(response)
//        mutableData.length = 0;
//    }
//    
//    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
//        mutableData.appendData(data)
//    }
//    
//    func connectionDidFinishLoading(connection: NSURLConnection!) {
//        let response = NSString(data: mutableData, encoding: NSUTF8StringEncoding)
//        print(response)
//        
//        let xmlParser = NSXMLParser(data: mutableData)
//        xmlParser.delegate = self
//        xmlParser.parse()
//        xmlParser.shouldResolveExternalEntities = true
//    }
//}








