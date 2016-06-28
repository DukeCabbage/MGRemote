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
    
    // MARK: Properties
    private let LOGTAG : String = "NetworkManager: "
    static let mInstance = NetworkManager()
    
    let defaultSession : NSURLSession!
    var simulatorDataTask: NSURLSessionDataTask?
    var setTripStateDataTask: NSURLSessionDataTask?
    
    private init() {
        let defaultConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        defaultConfig.timeoutIntervalForRequest = 30
        print(LOGTAG + "timeout for request " + "\(defaultConfig.timeoutIntervalForRequest)")
        print(LOGTAG + "timeout for resource " + "\(defaultConfig.timeoutIntervalForResource)")
        defaultSession = NSURLSession(configuration: defaultConfig)
    }
    
    // MARK: Common utilities
    private func buildEmptySoapBody() -> AEXMLDocument {
        let soapRequest = AEXMLDocument()
        let attributes = ["xmlns:xsi" : "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" : "http://www.w3.org/2001/XMLSchema", "xmlns:soap" : "http://schemas.xmlsoap.org/soap/envelope/"]
        let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: attributes)
        envelope.addChild(name: "soap:Body")
        return soapRequest
    }
    
    func sendSimulatorControlRequest(urlRequest: NSMutableURLRequest, completionHandler : ((NSData?, NSURLResponse?, NSError?) -> Void)? = nil) {
        simulatorDataTask?.cancel()
        if completionHandler == nil {
            simulatorDataTask = defaultSession.dataTaskWithRequest(urlRequest)
        } else {
            simulatorDataTask = defaultSession.dataTaskWithRequest(urlRequest, completionHandler: completionHandler!)
        }
        
        simulatorDataTask!.resume()
    }
    
    func sendSetTripRequest(urlRequest: NSMutableURLRequest, completionHandler : ((NSData?, NSURLResponse?, NSError?) -> Void)?) {
        setTripStateDataTask?.cancel()
        if completionHandler == nil {
            setTripStateDataTask = defaultSession.dataTaskWithRequest(urlRequest)
        } else {
            setTripStateDataTask = defaultSession.dataTaskWithRequest(urlRequest, completionHandler: completionHandler!)
        }
        
        setTripStateDataTask!.resume()
    }
    
    private func parseXMLData(data: NSData?) -> AEXMLDocument? {
        do {
            let xmlDoc = try AEXMLDocument(xmlData: data!)
            print(xmlDoc.xmlString)
            return xmlDoc
        } catch {
            print("\(error)")
            return nil
        }
    }
    
    private func parseXMLBody(doc: AEXMLDocument?) -> AEXMLElement? {
        guard case let envelope = doc?["soap:Envelope"] where envelope?.error == nil,
            case let body = envelope?["soap:Body"] where body?.error == nil else {
                print("Error: wrong format, could not parse body tag")
                return nil
        }
        return body
    }
    
    func parseXMLBody(data: NSData?) -> AEXMLElement? {
        return parseXMLBody(parseXMLData(data))
    }
}

// MARK: Simulator control
extension NetworkManager {
    func buildSimulatorRequest(option : String) -> NSMutableURLRequest? {
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
        let body = soapRequest["soap:Envelope"]["soap:Body"]
        body.addChild(name: requestName, attributes: ["xmlns" : "http://iis.com.dds.osp.itaxi.interface/"])
        print(soapRequest.xmlString)
        
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
}

// MARK: Set trip state
extension NetworkManager {
    func buildSetTripStateRequest(options : [String : String]) -> NSMutableURLRequest? {
        for (key, value) in options {
            print("\(key): \(value)")
        }
        
        let requestName : String = "SetTripState"
        let action : String = "http://iis.com.dds.osp.itaxi.interface/SetTripState"
        
        // Build body
        let soapRequest = buildEmptySoapBody()
        let body = soapRequest["soap:Envelope"]["soap:Body"]
        let setTripState = body.addChild(name: requestName, attributes: ["xmlns" : "http://iis.com.dds.osp.itaxi.interface/"])
        setTripState.addChild(name: "jobId", value: options["jobId"])
        setTripState.addChild(name: "destId", value: options["destId"])
        setTripState.addChild(name: "newState", value: options["newState"])
        setTripState.addChild(name: "amount", value: options["amount"])
        setTripState.addChild(name: "meterFare", value: options["meterFare"])
        setTripState.addChild(name: "expense", value: options["expense"])
        print(soapRequest.xmlString)
        
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
}













