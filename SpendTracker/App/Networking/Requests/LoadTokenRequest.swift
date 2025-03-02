import Foundation

class LoadTokenRequest: BaseAPIRequest {
    let walletId: String
    let walletSecret: String
    
    init(walletId: String, walletSecret: String) {
        self.walletId = walletId
        self.walletSecret = walletSecret
    }

    override var urlRequest: URLRequest {
        let url = URL(string: "\(baseUrl)/sandbox-idp/wallets/\(walletId)/tokens")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = [
            "clientId": Self.clientId,
            "clientSecret": Self.clientSecret,
            "walletSecret": walletSecret
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return request
    }
}
