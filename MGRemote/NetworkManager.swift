//
//  NetworkManager.swift
//  MGRemote
//
//  Created by DDS Dev on 2016-06-23.
//  Copyright © 2016 Digital dispatch system. All rights reserved.
//

import Foundation
import AEXML

class NetworkManager {
    
    static let mInstance = NetworkManager()
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    private init() {}
    
    func sendSimulatorRequest(option : String) -> NSMutableURLRequest? {
        print("Simulator request: " + option)
        // Switch option
        var requestName : String
        var action : String
        switch option {
        case "turnOn":
            print("turning on simulator")
            requestName = "StartDispatchSimulation"
            action = "http://iis.com.dds.osp.itaxi.interface/StartDispatchSimulation"
        case "turnOff":
            print("turning off simulator")
            requestName = "EndDispatchSimulation"
            action = "http://iis.com.dds.osp.itaxi.interface/EndDispatchSimulation"
        case "checkState":
            print("checking state")
            requestName = "IsSimulationRunning"
            action = "http://iis.com.dds.osp.itaxi.interface/IsSimulationRunning"
        default:
            return nil
        }
        
        // Build body
        let soapRequest = buildEmptySoapBody()
        print(soapRequest.xmlString)
        let body = soapRequest["soap:Envelope"]["soap:Body"]
        body.addChild(name: requestName, attributes: ["xmlns" : "http://iis.com.dds.osp.itaxi.interface/"])
        
        // Build header
        if let url = NSURL(string: Config.getUrl()) {
            let theRequest = NSMutableURLRequest(URL: url)
            theRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            theRequest.addValue(String(soapRequest.xmlString.characters.count), forHTTPHeaderField: "Content-Length")
            theRequest.addValue(action, forHTTPHeaderField:"SOAPAction")
            theRequest.HTTPMethod = "POST"
            theRequest.HTTPBody = soapRequest.xmlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            return theRequest
        } else {
            return nil
        }
    }
    
    private func buildEmptySoapBody() -> AEXMLDocument {
        let soapRequest = AEXMLDocument()
        let attributes = ["xmlns:xsi" : "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" : "http://www.w3.org/2001/XMLSchema", "xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: attributes)
        envelope.addChild(name: "soap:Body")
        return soapRequest
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
}