import Foundation
import Combine

protocol NetworkManagerProtocol {
    func loadWallet() -> AnyPublisher<WalletResponse, Error>
    func loadToken(walletId: String, walletSecret: String) -> AnyPublisher<TokenResponse, Error>
    func addBankAccount(token: String, idpCode: String) -> AnyPublisher<LoginResponse, Error>
    func getAccounts(token: String) -> AnyPublisher<AccountsResponse, Error>
    func getAccountDetails(token: String, resourceId: String) -> AnyPublisher<AccountResponse, Error>
}

class NetworkManagerImpl: NetworkManagerProtocol {
    
    private static let clientId: String = "3cff42fb-c037-4317-8a36-b31c09395c80"
    private static let clientSecret: String = "dc50f4eb-7e43-43e5-9e90-65065e8f6931"
    private static let apiKey = "33d089df-6abc-4ece-b6cc-497321a88a2e"
    private static let IP = "178.143.37.123"
    
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
            "clientId": Self.clientId,
            "clientSecret": Self.clientSecret
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

    func loadToken(walletId: String, walletSecret: String) -> AnyPublisher<TokenResponse, Error> {
        // Načítame certifikát pre získanie tokenu
        guard let identity = CertificateManagement.shared.loadP12Certificate(fileName: "sandbox", password: "Heslo1234") else {
            return Fail(error: NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load certificate"])).eraseToAnyPublisher()
        }
        
        let url = URL(string: "https://webapi.developers.erstegroup.com/api/egb/sandbox/v1/sandbox-idp/wallets/\(walletId)/tokens")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Telo požiadavky pre získanie tokenu
        let body = [
            "clientId": Self.clientId,
            "clientSecret": Self.clientSecret,
            "walletSecret": walletSecret
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
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func addBankAccount(token: String, idpCode: String) -> AnyPublisher<LoginResponse, Error> {
        let url = URL(string: "https://webapi.developers.erstegroup.com/api/egb/sandbox/v1/wallet/v1/banks")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(Self.apiKey, forHTTPHeaderField: "web-api-key")
        request.setValue(Self.IP, forHTTPHeaderField: "PSU-IP-ADDRESS")

        let body: [String: Any] = [
            "idpCode": idpCode
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NSError(domain: "NetworkManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                }
                return result.data
            }
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func getAccounts(token: String) -> AnyPublisher<AccountsResponse, Error> {
        guard let identity = CertificateManagement.shared.loadP12Certificate(fileName: "sandbox", password: "Heslo1234") else {
            return Fail(error: NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load certificate"])).eraseToAnyPublisher()
        }

        let url = URL(string: "https://webapi.developers.erstegroup.com/api/egb/sandbox/v1/aisp/v1/accounts")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(Self.apiKey, forHTTPHeaderField: "web-api-key")

        // Setup SSL session
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
            .decode(type: AccountsResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func getAccountDetails(token: String, resourceId: String) -> AnyPublisher<AccountResponse, Error> {
        guard let identity = CertificateManagement.shared.loadP12Certificate(fileName: "sandbox", password: "Heslo1234") else {
            return Fail(error: NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load certificate"])).eraseToAnyPublisher()
        }

        let url = URL(string: "https://webapi.developers.erstegroup.com/api/egb/sandbox/v1/aisp/v1/accounts/\(resourceId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(Self.apiKey, forHTTPHeaderField: "web-api-key")

        // Setup SSL session
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
            .decode(type: AccountResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
