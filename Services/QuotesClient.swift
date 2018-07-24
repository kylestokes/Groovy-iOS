//
//  QuotesClient.swift
//  groovy
//
//  Created by Kyle Stokes on 7/23/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import Foundation
import UIKit

class QuotesClient: NSObject  {
    
    // shared session
    var session = URLSession.shared
    
    var quote: [String] = []
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // Get inspiring quote of the day
    func getQuoteOfTheDay(completionHandlerQuote: @escaping (_ result: [String]?, _ error: NSError?)
        -> Void) {
        
        // 1. Specify parameters
        let request = URLRequest(url: URL(string: "https://quotes.rest/qod?category=inspire")!)
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerQuote(nil, error)
            } else {
                
                if let results = parsedResult?["contents"] as? [String:AnyObject] {
                    let quotes = results["quotes"] as! [[String:AnyObject]]
                    let quote = quotes[0]["quote"] as! String
                    let author = quotes[0]["author"] as! String

                    self.quote = []
                    self.quote.append(quote)
                    self.quote.append(author)
                    
                    completionHandlerQuote(self.quote, nil)
                } else {
                    completionHandlerQuote(nil, NSError(domain: "quoteOfTheDay parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getQuoteOfTheDay"]))
                }
            }
        }
    }
    
    // This abstracts the guard statements for requests to one location
    private func performRequest(request: URLRequest,
                                completionHandlerRequest: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
        -> URLSessionDataTask {
            
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                
                func sendError(_ error: String) {
                    print(error)
                    let userInfo = [NSLocalizedDescriptionKey : error]
                    completionHandlerRequest(nil, NSError(domain: "performRequest", code: 1, userInfo: userInfo))
                }
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    sendError("There was an error with your request: \(error!)")
                    return
                }
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    let httpError = (response as? HTTPURLResponse)?.statusCode
                    sendError("Your request returned a status code : \(String(describing: httpError))")
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    sendError("No data was returned by the request!")
                    return
                }
                
                print(String(data: data, encoding: String.Encoding.utf8)!)
                
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerRequest)
            }
            
            task.resume()
            
            return task
    }
    
    // When given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> QuotesClient {
        struct Singleton {
            static var sharedInstance = QuotesClient()
        }
        return Singleton.sharedInstance
    }
}
