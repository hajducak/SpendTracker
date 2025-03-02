import Foundation
import Combine

protocol NetworkManagerProtocol {
    func loadWallet() -> AnyPublisher<WalletResponse, Error>
}

class NetworkManagerImpl: NetworkManagerProtocol {
    
    func loadWallet() -> AnyPublisher<WalletResponse, Error> {
        // Načítame certifikát
        guard let identity = CertificateManagement.shared.loadP12Certificate(fileName: "sandbox", password: "Heslo1234") else {
            return Fail(error: NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load certificate"])).eraseToAnyPublisher()
        }

        let url = URL(string: "https://webapi.developers.erstegroup.com/api/egb/sandbox/v1/sandbox-idp/wallets")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Telo požiadavky
        let body = [
            "clientId": "3cff42fb-c037-4317-8a36-b31c09395c80",
            "clientSecret": "dc50f4eb-7e43-43e5-9e90-65065e8f6931"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let delegate = SSLSessionDelegate(identity: identity)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: nil)
        
        return session.dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NSError(domain: "NetworkManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                }
                return result.data
            }
            .decode(type: WalletResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
