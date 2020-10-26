//
//  DataRequest+Extension.swift
//  sdk
//
//  Created by Sergey Iskhakov on 26.10.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

extension DataRequest {
    
    private enum ErrorCode: Int {
        case noData = 1
        case dataSerializationFailed = 2
    }
    
    @discardableResult
    func responseObject<T: BaseMappable>(queue: DispatchQueue = .main, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil, completionHandler: @escaping (AFDataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.ObjectMapperSerializer(keyPath, mapToObject: object, context: context), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseObject<T: ImmutableMappable>(queue: DispatchQueue = .main, keyPath: String? = nil, mapToObject object: T? = nil, context: MapContext? = nil, completionHandler: @escaping (AFDataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.ObjectMapperImmutableSerializer(keyPath, context: context), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseArray<T: BaseMappable>(queue: DispatchQueue = .main, keyPath: String? = nil, context: MapContext? = nil, completionHandler: @escaping (AFDataResponse<[T]>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.ObjectMapperArraySerializer(keyPath, context: context), completionHandler: completionHandler)
    }

    @discardableResult
    func responseArray<T: ImmutableMappable>(queue: DispatchQueue = .main, keyPath: String? = nil, context: MapContext? = nil, completionHandler: @escaping (AFDataResponse<[T]>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: DataRequest.ObjectMapperImmutableArraySerializer(keyPath, context: context), completionHandler: completionHandler)
    }
    
    /// Utility function for extracting JSON from response
    private static func processResponse(request: URLRequest?, response: HTTPURLResponse?, data: Data?, keyPath: String?) -> Any? {
        
        let jsonResponseSerializer = JSONResponseSerializer(options: .allowFragments)
        if let result = try? jsonResponseSerializer.serialize(request: request, response: response, data: data, error: nil) {
            
            let JSON: Any?
            if let keyPath = keyPath , keyPath.isEmpty == false {
                JSON = (result as AnyObject?)?.value(forKeyPath: keyPath)
            } else {
                JSON = result
            }
            
            return JSON
        }
        
        return nil
    }
    
    private static func newError(_ code: ErrorCode, failureReason: String) -> NSError {
        let errorDomain = "com.alamofireobjectmapper.error"
        
        let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
        let returnError = NSError(domain: errorDomain, code: code.rawValue, userInfo: userInfo)
        
        return returnError
    }
    
    
    /// BaseMappable Object Serializer
    private static func ObjectMapperSerializer<T: BaseMappable>(_ keyPath: String?, mapToObject object: T? = nil, context: MapContext? = nil) -> MappableResponseSerializer<T> {
        
        return MappableResponseSerializer(keyPath, mapToObject: object, context: context, serializeCallback: {
            request, response, data, error in

            let JSONObject = processResponse(request: request, response: response, data: data, keyPath: keyPath)
            
            if let object = object {
                _ = Mapper<T>(context: context, shouldIncludeNilValues: false).map(JSONObject: JSONObject, toObject: object)
                return object
            } else if let parsedObject = Mapper<T>(context: context, shouldIncludeNilValues: false).map(JSONObject: JSONObject){
                return parsedObject
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            throw AFError.responseSerializationFailed(reason: .decodingFailed(error: newError(.dataSerializationFailed, failureReason: failureReason)))
            
        })
    }
    
    /// ImmutableMappable Array Serializer
    private static func ObjectMapperImmutableSerializer<T: ImmutableMappable>(_ keyPath: String?, context: MapContext? = nil) -> MappableResponseSerializer<T> {
        
        return MappableResponseSerializer(keyPath, context: context, serializeCallback: {
            request, response, data, error in
            
            let JSONObject = processResponse(request: request, response: response, data: data, keyPath: keyPath)
            
            if let JSONObject = JSONObject,
                let parsedObject = (try? Mapper<T>(context: context, shouldIncludeNilValues: false).map(JSONObject: JSONObject) as T) {
                return parsedObject
            } else {
                let failureReason = "ObjectMapper failed to serialize response."
                throw AFError.responseSerializationFailed(reason: .decodingFailed(error: newError(.dataSerializationFailed, failureReason: failureReason)))
            }
        })
    }
    
    
    
    /// BaseMappable Array Serializer
    private static func ObjectMapperArraySerializer<T: BaseMappable>(_ keyPath: String?, context: MapContext? = nil) -> MappableArrayResponseSerializer<T> {
        
        
        
        return MappableArrayResponseSerializer(keyPath, context: context, serializeCallback: {
            request, response, data, error in
            
            let JSONObject = processResponse(request: request, response: response, data: data, keyPath: keyPath)
            
            if let parsedObject = Mapper<T>(context: context, shouldIncludeNilValues: false).mapArray(JSONObject: JSONObject){
                return parsedObject
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            throw AFError.responseSerializationFailed(reason: .decodingFailed(error: newError(.dataSerializationFailed, failureReason: failureReason)))
        })
    }
    
    /// ImmutableMappable Array Serializer
    private static func ObjectMapperImmutableArraySerializer<T: ImmutableMappable>(_ keyPath: String?, context: MapContext? = nil) -> MappableArrayResponseSerializer<T> {
        return MappableArrayResponseSerializer(keyPath, context: context, serializeCallback: {
             request, response, data, error in
            
            if let JSONObject = processResponse(request: request, response: response, data: data, keyPath: keyPath){
                
                if let parsedObject = try? Mapper<T>(context: context, shouldIncludeNilValues: false).mapArray(JSONObject: JSONObject) as [T] {
                    return parsedObject
                }
            }
            
            let failureReason = "ObjectMapper failed to serialize response."
            throw AFError.responseSerializationFailed(reason: .decodingFailed(error: newError(.dataSerializationFailed, failureReason: failureReason)))
        })
    }
}

private final class MappableResponseSerializer<T: BaseMappable>: ResponseSerializer {
    public let decoder: DataDecoder = JSONDecoder()
    public let emptyResponseCodes: Set<Int>
    public let emptyRequestMethods: Set<HTTPMethod>
    
    public let keyPath: String?
    public let context: MapContext?
    public let object: T?

    public let serializeCallback: (URLRequest?,HTTPURLResponse?, Data?,Error?) throws -> T
    public init(_ keyPath: String?, mapToObject object: T? = nil, context: MapContext? = nil,
                emptyResponseCodes: Set<Int> = MappableResponseSerializer.defaultEmptyResponseCodes,
                emptyRequestMethods: Set<HTTPMethod> = MappableResponseSerializer.defaultEmptyRequestMethods, serializeCallback: @escaping (URLRequest?,HTTPURLResponse?, Data?,Error?) throws -> T) {

        self.emptyResponseCodes = emptyResponseCodes
        self.emptyRequestMethods = emptyRequestMethods
        
        self.keyPath = keyPath
        self.context = context
        self.object = object
        self.serializeCallback = serializeCallback
    }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
        guard error == nil else { throw error! }
        
        guard let data = data, !data.isEmpty else {
            guard emptyResponseAllowed(forRequest: request, response: response) else {
                throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
            }
            
            guard let emptyValue = Empty.value as? T else {
                throw AFError.responseSerializationFailed(reason: .invalidEmptyResponse(type: "\(T.self)"))
            }
            
            return emptyValue
        }
        return try self.serializeCallback(request, response, data, error)
    }
}

private final class MappableArrayResponseSerializer<T: BaseMappable>: ResponseSerializer {
    public let decoder: DataDecoder = JSONDecoder()
    public let emptyResponseCodes: Set<Int>
    public let emptyRequestMethods: Set<HTTPMethod>
    
    public let keyPath: String?
    public let context: MapContext?

    public let serializeCallback: (URLRequest?,HTTPURLResponse?, Data?,Error?) throws -> [T]
    public init(_ keyPath: String?, context: MapContext? = nil, serializeCallback: @escaping (URLRequest?,HTTPURLResponse?, Data?,Error?) throws -> [T],
                emptyResponseCodes: Set<Int> = MappableArrayResponseSerializer.defaultEmptyResponseCodes,
                emptyRequestMethods: Set<HTTPMethod> = MappableArrayResponseSerializer.defaultEmptyRequestMethods) {
        self.emptyResponseCodes = emptyResponseCodes
        self.emptyRequestMethods = emptyRequestMethods
        
        self.keyPath = keyPath
        self.context = context
        self.serializeCallback = serializeCallback
    }
    
    public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> [T] {
        guard error == nil else { throw error! }
        
        guard let data = data, !data.isEmpty else {
            guard emptyResponseAllowed(forRequest: request, response: response) else {
                throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
            }
            
            // TODO / FIX - Empty Response JSON Decodable Array Fix - "Cast from empty always fails..."
            guard let emptyValue = Empty.value as? [T] else {
                throw AFError.responseSerializationFailed(reason: .invalidEmptyResponse(type: "\(T.self)"))
            }
            
            return emptyValue
        }
        return try self.serializeCallback(request, response, data, error)
    }
}
