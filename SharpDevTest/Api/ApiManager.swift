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
    case name = "name"
    case amount = "amount"
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
    case badUrl
    case connectionError
    case badData
    case errorJsonParsing
    case loginErrorParams
    case loginBadParams
    case registerError
    case userNotFound
    case invalidUser
    case filteringError
    case balanceExceeded
    case unuthorizedUser
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
        case .filteringError:
            return NSLocalizedString("Bad filter request", comment: "Error Search Users")
        case .balanceExceeded:
            return NSLocalizedString("Not enough money", comment: "Balance error")
        case .unuthorizedUser:
            return NSLocalizedString("Something goes wrong with authentication", comment: "Error Bad Auth")
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
            if let _ = error {
                callback(nil, ApiError.connectionError)
            } else if let data = data, let responseCode = response as? HTTPURLResponse {
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
            if let _ = error {
                callback(nil, ApiError.connectionError)
            } else if let data = data, let responseCode = response as? HTTPURLResponse {

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
            if let _ = error {
                callback(nil, ApiError.connectionError)
            } else if let data = data, let responseCode = response as? HTTPURLResponse {
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
    
    public func filteredUserList(filter: String, callback: @escaping ([UserSearchModel]?, Error?) -> Void) {
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
                var generatedError: Error? = nil
                switch responseCode.statusCode {
                case 401:
                    generatedError = ApiError.filteringError
                default:
                    break
                }
                
                if let generatedError = generatedError {
                    callback(nil, generatedError)
                    return
                }
                do {
                    let searchArray = try JSONDecoder().decode([UserSearchModel].self, from: data)
                    callback(searchArray, nil)
                } catch {
                    callback(nil, ApiError.errorJsonParsing)
                }
            } else {
                callback(nil, ApiError.badData)
            }
        }
        
        datatask.resume()
    }
    
    public func fetchTransactions(callback: @escaping ([TransactionModel]?, Error?) -> Void) {
        let urlPath = baseUrl + ApiMethods.transactions.rawValue
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
                var generatedError: Error? = nil
                switch responseCode.statusCode {
                case 401:
                    generatedError = ApiError.unuthorizedUser
                default:
                    break
                }
                
                if let generatedError = generatedError {
                    callback(nil, generatedError)
                    return
                }
                do {
                    let transactionList = try JSONDecoder().decode(TransactionListModel.self, from: data)
                    callback(transactionList.transactions.map{TransactionModel(id: $0.id, date: $0.date, userName: $0.userName, balance: $0.balance, amount: $0.amount)}, nil)
                } catch {
                    callback(nil, ApiError.errorJsonParsing)
                }
            } else {
                callback(nil, ApiError.badData)
            }
        }
        
        datatask.resume()
    }
    
    public func createTransaction(name: String, amount: Int, callback: @escaping (TransactionModel?, Error?) -> Void) {
        let urlPath = baseUrl + ApiMethods.transactions.rawValue
        let url = URL(string: urlPath)
        guard let okUrl = url else {
            callback(nil, ApiError.badUrl)
            return
        }
        
        var request = URLRequest(url: okUrl)
        request.httpMethod = ApiHTTPMethod.post.rawValue
        request.addAuthTokenForHeader()
        
        var params = Parameters()
        params[ApiRegisterVariables.name.rawValue] = name
        params[ApiRegisterVariables.amount.rawValue] = String(amount)
        request.httpBody = generateBodyDataFromParams(params: params)
        
        let datatask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                callback(nil, ApiError.connectionError)
            } else if let data = data, let responseCode = response as? HTTPURLResponse {
                var generatedError: Error? = nil
                switch responseCode.statusCode {
                case 400:
                    generatedError = ApiError.balanceExceeded
                case 401:
                    generatedError = ApiError.unuthorizedUser
                default:
                    break
                }
                
                if let generatedError = generatedError {
                    callback(nil, generatedError)
                    return
                }
                do {
                    let transaction = try JSONDecoder().decode(TransactionModel.self, from: data)
                    callback(transaction, nil)
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
