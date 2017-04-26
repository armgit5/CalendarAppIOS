//
//  NetworkOperation.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/1/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//

import Foundation

class NetworkOperation {
    
    lazy var config: URLSessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = URLSession(configuration: self.config)
    var queryURL: URL

    typealias JSONDictionaryCompletion = ([[String: AnyObject]]?) -> Void
    
    init(url: URL) {
        self.queryURL = url
    }

    func downloadJSONFromURL(_ idString: String?, completion: @escaping JSONDictionaryCompletion) {
        if idString != nil {
            queryURL = URL(string: idString!, relativeTo: queryURL)!
            print(queryURL)
        }
        var request = URLRequest(url: queryURL)
        let username = User.email
        let password = User.password
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString =  loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let dataTask = session.dataTask(with: request, completionHandler: {
            data, response, error in
            
            // Check http response for successful GET request
            if let httpResponse = response as? HTTPURLResponse {
                
                switch(httpResponse.statusCode) {
                case 200:
                    // create json object
                    let jsonDictionary = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [[String: AnyObject]]
                    completion(jsonDictionary)
                    print("jsondic")
                    print(jsonDictionary as Any)
                case 401:
                    let jsonDictionary = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [[String: AnyObject]]
                    completion(jsonDictionary)
                default:
                    print("GET request not successful. HTTP status code: \(httpResponse.statusCode)")
                }
                
            } else {
                print("error no valid http request response")
                completion([["user_id": -1 as AnyObject, "message": "Not successfully login" as AnyObject]])
            }
        }) 
        
        dataTask.resume()
    }
    
    func postBodyToURL(_ postBody: String, postId: String?, postMethod: String, completion: @escaping (String?) -> Void) {
        
        if postId != nil {
            queryURL = URL(string: postId!, relativeTo: queryURL)!
            print(queryURL)
        }
        
        var request = URLRequest(url: queryURL)
        let username = User.email
        let password = User.password
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString =  loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let body = postBody
        request.httpMethod = postMethod
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: String.Encoding.utf8);
        let dataTask = session.dataTask(with: request, completionHandler: {
            data, response, error in
            
            // Check http response for successful GET request
            if let httpResponse = response as? HTTPURLResponse {
                
                switch(httpResponse.statusCode) {
                case 200:
                    // create json object
                    do {
                        let parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                    
                        /* 6. Use the data! */
                        if let status = parsedResult?["message"] as? String {
                            completion(status)
                        }
                    } catch {
                        print(error)
                    }
                case 401:
                    do {
                        let parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                        
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
                print("error no valid http post response")
            }
        }) 
        
        dataTask.resume()
    }
}
