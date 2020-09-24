import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class NetworkService {
    
    private let session: Session
    
    init(session: Session = Session.default) {
        self.session = session
    }
}

// MARK: - Internal methods

extension NetworkService {
    
    func makeObjectRequest<T: BaseMappable>(_ request: HTTPRequest, completion: @escaping (AFResult<T>) -> Void) {
        validatedDataRequest(from: request).responseObject(keyPath: request.mappingKeyPath) { completion($0.result) }
    }
    
    func makeArrayRequest<T: BaseMappable>(_ request: HTTPRequest, completion: @escaping (AFResult<[T]>) -> Void) {
        validatedDataRequest(from: request).responseArray(keyPath: request.mappingKeyPath) { completion($0.result) }
    }
}

// MARK: - Private methods

private extension NetworkService {
    
    func validatedDataRequest(from httpRequest: HTTPRequest) -> DataRequest {
        
        return session
            .request(httpRequest.resource,
                     method: httpRequest.method,
                     parameters: httpRequest.parameters,
                     encoding: JSONEncoding.default,
                     headers: httpRequest.headers)
            .validate()
    }
}
