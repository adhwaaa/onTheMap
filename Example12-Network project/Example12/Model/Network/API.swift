//
//  API.swift
//  PinSample
//
//  Created by Ammar AlTahhan on 15/11/2018.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class API {
    
    private static var TheuserInfo = UserInfo()
    private static var ThesessionID: String?
    
    static func postSession(username: String, password: String, completion: @escaping (String?)->Void) {
        guard let url = URL(string: APIConstants.SESSION) else {
            completion("your url is invalid")
            return
        }
        
        var requestIt = URLRequest(url: url)
        requestIt.httpMethod = HTTPMethod.post.rawValue
        requestIt.addValue("application/json", forHTTPHeaderField: "Accept")
        requestIt.addValue("application/json", forHTTPHeaderField: "Content-Type")
        requestIt.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: requestIt) { data, response, error in
            var errorS: String?
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode >= 200 && statusCode < 300 { //Response is ok
                    
                    let newData = data?.subdata(in: 5..<data!.count)
                    if let jsonIt = try? JSONSerialization.jsonObject(with: newData!, options: []),
                        let dict = jsonIt as? [String:Any],
                        let sessionDict = dict["session"] as? [String: Any],
                        let accountDict = dict["account"] as? [String: Any]  {
                        
                        self.TheuserInfo.key = accountDict["key"] as? String
                        self.ThesessionID = sessionDict["id"] as? String
                        
                        self.getUserInfo(completion: { err in })
                    } else {
                        errorS = "Problem in parsing the response"
                    }
                } else {
                    errorS = "Error in username or the password"
                }
            } else {
                errorS = "problem in the internet connection"
            }
            DispatchQueue.main.async {
                completion(errorS)
            }
            
        }
        task.resume()
    }
    
    static func getUserInfo(completion: @escaping (Error?)->Void) {
        var errorS: String?
        let request = URLRequest(url: URL(string: APIConstants.PUBLIC_USER + "(userInfo.key!)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var errString: String?
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode >= 200 && statusCode < 300 {
                    let newData = data?.subdata(in: 5..<data!.count)
                    if let Myjson = try? JSONSerialization.jsonObject(with: newData!, options: [.allowFragments]),
                       
                        let userDict = Myjson as? [String: Any]{
                        self.TheuserInfo.firstName = userDict["first_name"] as? String
                        self.TheuserInfo.lastName = userDict["last_name"] as? String
                        self.getUserInfo(completion: { err in
                            
                        })
                    } else {
                        errString = "Problem in parsing the response"
                    }
                } else {
                    errString = "Error in username or the password"
                }
            } else {
                errString = "problem in the internet connection"
            }
            DispatchQueue.main.async {
                completion(errString as? Error)
            }
            
        }
        task.resume()
    }
    
    class Parser {
        
        static func getStudentLocations(limit: Int = 100, skip: Int = 0, orderBy: SLParam = .updatedAt, completion: @escaping (LocationsData?)->Void) {
            guard let url = URL(string: "\(APIConstants.STUDENT_LOCATION)?\(APIConstants.ParameterKeys.LIMIT)=\(limit)&\(APIConstants.ParameterKeys.SKIP)=\(skip)&\(APIConstants.ParameterKeys.ORDER)=-\(orderBy.rawValue)") else {
                completion(nil)
                return
            }
            
            var requestIt = URLRequest(url: url)
            requestIt.httpMethod = HTTPMethod.get.rawValue
            requestIt.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
            requestIt.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
            let session = URLSession.shared
            let task = session.dataTask(with: requestIt) { data, response, error in
                var studentLocations: [StudentLocation] = []
                if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                    if statusCode >= 200 && statusCode < 300 { //Response is ok
                        
                        if let json = try? JSONSerialization.jsonObject(with: data!, options: []),
                            let dict = json as? [String:Any],
                            let results = dict["results"] as? [Any] {
                            
                            for location in results {
                                let data = try! JSONSerialization.data(withJSONObject: location)
                                let studentLocation = try! JSONDecoder().decode(StudentLocation.self, from: data)
                                studentLocations.append(studentLocation)
                            }
                            
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    completion(LocationsData(studentLocations: studentLocations))
                }
                
            }
            task.resume()
        }
        
        static func postLocation(_ location: StudentLocation, completion: @escaping (String?)->Void) {
            
            var request = URLRequest(url: URL(string: APIConstants.STUDENT_LOCATION)!)
            request.httpMethod = HTTPMethod.post.rawValue
            request.addValue(APIConstants.HeaderValues.PARSE_APP_ID, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_APP_ID)
            request.addValue(APIConstants.HeaderValues.PARSE_API_KEY, forHTTPHeaderField: APIConstants.HeaderKeys.PARSE_API_KEY)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.httpBody = "{\"uniqueKey\": \"\(TheuserInfo.key!)\",  \"firstName\": \"\(TheuserInfo.firstName!)\", \"lastName\": \"\(TheuserInfo.lastName!)\", \"mapString\": \"\(location.mapString!)\", \"mediaURL\": \"\(location.mediaURL!)\", \"latitude\": \(location.latitude!), \"longitude\": \(location.longitude!)}".data(using: .utf8)
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    print(error as? String)
                    return
                }
                print(String(data: data!, encoding: .utf8)!)
               
                print(request.httpBody!)
                
            }
            task.resume()
        }
        
        static func deleteSession( completion: @escaping (String?)->Void) {
            var request = URLRequest(url: URL(string: APIConstants.SESSION)!)
            request.httpMethod = "DELETE"
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    return
                }
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range) /* subset response data! */
                print(String(data: newData!, encoding: .utf8)!)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
            task.resume()
        }
    
    }
}
