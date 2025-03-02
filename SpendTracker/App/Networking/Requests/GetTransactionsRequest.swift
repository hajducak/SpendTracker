import Foundation

class GetTransactionsRequest: ResourceIdRequiredAPIRequest {
    override var urlRequest: URLRequest {
        let url = URL(string: "\(baseUrl)/aisp/v1/accounts/\(resourceId)/transactions?bookingStatus=both")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(Self.apiKey, forHTTPHeaderField: "web-api-key")
        return request
    }
}
