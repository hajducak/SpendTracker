import Foundation

class LoadWalletRequest: BaseAPIRequest {
    override var urlRequest: URLRequest {
        let url = URL(string: "\(baseUrl)/sandbox-idp/wallets")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = [
            "clientId": Self.clientId,
            "clientSecret": Self.clientSecret
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return request
    }
}
