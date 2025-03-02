import Foundation

protocol APIRequest {
    var urlRequest: URLRequest { get }
}

class BaseAPIRequest: APIRequest {
    static let clientId: String = "3cff42fb-c037-4317-8a36-b31c09395c80"
    static let clientSecret: String = "dc50f4eb-7e43-43e5-9e90-65065e8f6931"
    static let apiKey: String = "33d089df-6abc-4ece-b6cc-497321a88a2e"
    static let IP: String = "178.143.37.123"
    let baseUrl = "https://webapi.developers.erstegroup.com/api/egb/sandbox/v1"
    
    var urlRequest: URLRequest {
        fatalError("Subclasses need to implement the `urlRequest` property.")
    }
}

class TokenRequiredAPIRequest: BaseAPIRequest {
    let token: String

    init(token: String) {
        self.token = token
    }
}

class ResourceIdRequiredAPIRequest: TokenRequiredAPIRequest {
    let resourceId: String

    init(token: String, resourceId: String) {
        self.resourceId = resourceId
        super.init(token: token)
    }
}
