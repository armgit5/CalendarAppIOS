//
//  NetworkOperation.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/1/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//

import Foundation

class NetworkOperation {
    
    lazy var config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var session: NSURLSession = NSURLSession(configuration: self.config)
    let queryURL: NSURL
    
    typealias JSONDictionaryCompletion = ([[String: AnyObject]]?) -> Void
    
    init(url: NSURL) {
        self.queryURL = url
    }

    func downloadJSONFromURL(completion: JSONDictionaryCompletion) {
        
        let request: NSURLRequest = NSURLRequest(URL: queryURL)
        let dataTask = session.dataTaskWithRequest(request) {
            data, response, error in
            
            // Check http response for successful GET request
            if let httpResponse = response as? NSHTTPURLResponse {
                
                switch(httpResponse.statusCode) {
                case 200:
                    // create json object
                    let jsonDictionary = (try? NSJSONSerialization.JSONObjectWithData(data!, options: [])) as? [[String: AnyObject]]
                    completion(jsonDictionary)
                default:
                    print("GET request not successful. HTTP status code: \(httpResponse.statusCode)")
                }
                
            } else {
                print("error no valid http response")
            }
        }
        
        dataTask.resume()
    }
    
    func postBodyToURL(postBody: String, completion: String? -> Void) {
        
        let request = NSMutableURLRequest(URL: queryURL)
        let body = postBody
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding);
        let dataTask = session.dataTaskWithRequest(request) {
            data, response, error in
            
            // Check http response for successful GET request
            if let httpResponse = response as? NSHTTPURLResponse {
                
                switch(httpResponse.statusCode) {
                case 200:
                    // create json object
                    do {
                        let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
                    
                        /* 6. Use the data! */
                        if let status = parsedResult?["message"] as? String {
                            completion(status)
                        }
                    } catch {
                        print(error)
                    }
                default:
                    print("POST request not successful. HTTP status code: \(httpResponse.statusCode)")
                }
                
            } else {
                print("error no valid http response")
            }
        }
        
        dataTask.resume()
    }

    
    
    
}