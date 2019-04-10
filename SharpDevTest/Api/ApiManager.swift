//
//  ApiManager.swift
//  SharpDevTest
//
//  Created by Anton Trofimenko on 04/04/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import Foundation

enum ApiMethods: String {
    case register = "users"
    case login = "sessions/create"
    case transactions = "api/protected/transactions"
    case userInfo = "api/protected/user-info"
    case filteredUserList = "api/protected/users/list"
}

enum ApiHeaders: String {
    case auth = "Authorization"
    case bearer = "Bearer "
}

enum ApiRegisterVariables: String {
    case userName = "username"
    case password = "password"
    case email = "email"
    case filter = "filter"
}

enum ApiHTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

typealias Parameters = [String : Any]


enum ApiError: Error {
//    case invalidEmail
//    case invalidPassword
//    case invalidPhoneNumber
    case badUrl
    case connectionError
    case badData
    case errorJsonParsing
    case loginErrorParams
    case loginBadParams
    case registerError
    case userNotFound
    case invalidUser
}

extension ApiError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badUrl:
            return NSLocalizedString("You aru using bad url", comment: "Bad Url")
        case .connectionError:
            return NSLocalizedString("Check your Internet connection", comment: "Bad Internet Connection")
        case .badData:
            return NSLocalizedString("Bad reponse/data from server", comment: "Api error")
        case .errorJsonParsing:
            return NSLocalizedString("Error parsing JSON", comment: "Bad JSON")
        case .loginErrorParams:
            return NSLocalizedString("You must send email and password", comment: "Login Bad Params")
        case .loginBadParams:
            return NSLocalizedString("Invalid email or password", comment: "Login Params Error")
        case .registerError:
            return NSLocalizedString("A user with that email already exists", comment: "Register Params Error")
        case .userNotFound:
            return NSLocalizedString("No such user", comment: "User Not Found Error")
        case .invalidUser:
            return NSLocalizedString("Bad user", comment: "Invalid User Error")
        }
    }
}

class ApiManager {
    
    static let shared = ApiManager()
    static var authToken: String? {
        get {
            let defaults = UserDefaults.standard
            return defaults.string(forKey: SettingsFields.authToken.rawValue)
        }
    }
    
    let baseUrl = "http://193.124.114.46:3001/"
    
    public func registerUser(userName: String, password: String, email: String, callback: @escaping (UserAuthData?, Error?) -> Void) {
        
        let urlPath = baseUrl + ApiMethods.register.rawValue
        let url = URL(string: urlPath)
        guard let okUrl = url else {
            callback(nil, ApiError.badUrl)
            return
        }
        
        var request = URLRequest(url: okUrl)
        request.httpMethod = ApiHTTPMethod.post.rawValue
        
        var params = Parameters()
        params[ApiRegisterVariables.userName.rawValue] = userName
        params[ApiRegisterVariables.password.rawValue] = password
        params[ApiRegisterVariables.email.rawValue] = email
        
        request.httpBody = generateBodyDataFromParams(params: params)

        let datatask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                callback(nil, ApiError.connectionError)
            } else if let data = data, let responseCode = response as? HTTPURLResponse {
                print(responseCode, responseCode.statusCode, data)
                
                var generatedError: Error? = nil
                switch responseCode.statusCode {
                case 400:
                    generatedError = ApiError.loginErrorParams
                default:
                    break
                }
                
                if let generatedError = generatedError {
                    callback(nil, generatedError)
                    return
                }
                do {
                    let userResponse = try JSONDecoder().decode(UserAuthData.self, from: data)
                    callback(userResponse, nil)
                } catch {
                    callback(nil, ApiError.errorJsonParsing)
                }
            } else {
                callback(nil, ApiError.badData)
            }
        }
        
        datatask.resume()
    }
    
    public func loginUser(email: String, password: String, callback: @escaping (UserAuthData?, Error?) -> Void) {
        let urlPath = baseUrl + ApiMethods.login.rawValue
        let url = URL(string: urlPath)
        guard let okUrl = url else {
            callback(nil, ApiError.badUrl)
            return
        }
        
        var request = URLRequest(url: okUrl)
        request.httpMethod = ApiHTTPMethod.post.rawValue
        var params = Parameters()
        params[ApiRegisterVariables.password.rawValue] = password
        params[ApiRegisterVariables.email.rawValue] = email
        
        request.httpBody = generateBodyDataFromParams(params: params)
        
        let datatask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                callback(nil, ApiError.connectionError)
            } else if let data = data, let responseCode = response as? HTTPURLResponse {
                print(responseCode, responseCode.statusCode, data)
                
                var generatedError: Error? = nil
                switch responseCode.statusCode {
                case 400:
                    generatedError = ApiError.loginErrorParams
                case 401:
                    generatedError = ApiError.loginBadParams
                default:
                    break
                }
                
                if let generatedError = generatedError {
                    callback(nil, generatedError)
                    return
                }
                do {
                    let userResponse = try JSONDecoder().decode(UserAuthData.self, from: data)
                    callback(userResponse, nil)
                } catch {
                    callback(nil, ApiError.errorJsonParsing)
                }
            } else {
                callback(nil, ApiError.badData)
            }
        }
        
        datatask.resume()
    }
    
    public func userInfo(callback: @escaping (UserModel?, Error?) -> Void) {
        let urlPath = baseUrl + ApiMethods.userInfo.rawValue
        let url = URL(string: urlPath)
        guard let okUrl = url else {
            callback(nil, ApiError.badUrl)
            return
        }
        
        var request = URLRequest(url: okUrl)
        request.httpMethod = ApiHTTPMethod.get.rawValue
        request.addAuthTokenForHeader()
        
        let datatask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                callback(nil, ApiError.connectionError)
            } else if let data = data, let responseCode = response as? HTTPURLResponse {
                print(responseCode, responseCode.statusCode, data)
                
                var generatedError: Error? = nil
                switch responseCode.statusCode {
                case 400:
                    generatedError = ApiError.userNotFound
                case 401:
                    generatedError = ApiError.invalidUser
                default:
                    break
                }
                
                if let generatedError = generatedError {
                    callback(nil, generatedError)
                    return
                }
                do {
                    let userResponse = try JSONDecoder().decode(UserModel.self, from: data)
                    callback(userResponse, nil)
                } catch {
                    callback(nil, ApiError.errorJsonParsing)
                }
            } else {
                callback(nil, ApiError.badData)
            }
        }
        
        datatask.resume()
    }
    
    public func filteredUserList(filter: String, callback: @escaping (Data?, Error?) -> Void) {
        let urlPath = baseUrl + ApiMethods.filteredUserList.rawValue
        let url = URL(string: urlPath)
        guard let okUrl = url else {
            callback(nil, ApiError.badUrl)
            return
        }
        
        var request = URLRequest(url: okUrl)
        request.httpMethod = ApiHTTPMethod.post.rawValue
        request.addAuthTokenForHeader()
        
        var params = Parameters()
        params[ApiRegisterVariables.filter.rawValue] = filter
        request.httpBody = generateBodyDataFromParams(params: params)
        
        let datatask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                callback(nil, ApiError.connectionError)
            } else if let data = data, let responseCode = response as? HTTPURLResponse {
                print(responseCode, responseCode.statusCode)
                print(data)
                
                var generatedError: Error? = nil
                switch responseCode.statusCode {
                case 400:
                    generatedError = ApiError.userNotFound
                case 401:
                    generatedError = ApiError.invalidUser
                default:
                    break
                }
                
                if let generatedError = generatedError {
                    callback(nil, generatedError)
                    return
                }
                do {
//                    let userResponse = try JSONDecoder().decode(UserModel.self, from: data)
                    callback(data, nil)
                } catch {
                    callback(nil, ApiError.errorJsonParsing)
                }
            } else {
                callback(nil, ApiError.badData)
            }
        }
        
        datatask.resume()
    }
    
    private func generateBodyDataFromParams(params: Parameters) -> Data? {
        let parameterData = params.reduce("") { (result, param) -> String in
            return result + "&\(param.key)=\(param.value as! String)"
            }.data(using: .utf8)
        return parameterData
    }
}

extension URLRequest {
    mutating func addAuthTokenForHeader() {
        print(ApiManager.authToken!)
        self.setValue(ApiHeaders.bearer.rawValue + ApiManager.authToken!, forHTTPHeaderField: ApiHeaders.auth.rawValue)
    }
}
