//
//  NetworkManager.swift
//  SpaceXLaunches
//
//  Created by Alexander Starodub on 23.08.2023.
//

import Foundation
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
        
    func getPOSTData(numberOfPage: Int, urlString: String, completion: @escaping(JsonLaunch) -> Void) {
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: makeHttpRequest(url: url, numberOfPage: numberOfPage)) { data, response, error in
                guard let data else {return}
                if let launches = try? JSONDecoder().decode(JsonLaunch.self, from: data){
                    completion(launches)
                } else {
                    print("ERROR!!!")
                }
            }
            task.resume()
        }
    }
    
    func makeHttpRequest(url: URL, numberOfPage: Int) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let stringBodyOfRequest: [String : Any] = ["query": "", "options": ["page": numberOfPage, "sort":["date_local": "desc"], "limit": 20, "populate":["rocket", "payloads"]] as [String : Any]]
        let jsonData = try? JSONSerialization.data(withJSONObject: stringBodyOfRequest)
        request.httpBody = jsonData
        return request
    }
}
