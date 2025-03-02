import Foundation

class AddBankAccountRequest: TokenRequiredAPIRequest {
    let idpCode: String
    
    init(idpCode: String, token: String) {
        self.idpCode = idpCode
        super.init(token: token)
    }

    override var urlRequest: URLRequest {
        let url = URL(string: "\(baseUrl)/wallet/v1/banks")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["idpCode": idpCode]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return request
    }
}

