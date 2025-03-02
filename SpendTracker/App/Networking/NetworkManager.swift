import Foundation
import Combine

protocol NetworkManagerProtocol {
    func loadWallet() -> AnyPublisher<WalletResponse, Error>
    func loadToken(walletId: String, walletSecret: String) -> AnyPublisher<TokenResponse, Error>
    func addBankAccount(token: String, idpCode: String) -> AnyPublisher<LoginResponse, Error>
    func getAccounts(token: String) -> AnyPublisher<AccountsResponse, Error>
    func getAccountDetails(token: String, resourceId: String) -> AnyPublisher<AccountDetailResponse, Error>
    func getAccountBalances(token: String, resourceId: String) -> AnyPublisher<AccountBalanceResponse, Error>
    func getAccountTransactions(token: String, resourceId: String) -> AnyPublisher<AccountTransactionResponse, Error>
}

class NetworkManagerImpl: NetworkManagerProtocol {
    private static let clientId: String = "3cff42fb-c037-4317-8a36-b31c09395c80"
    private static let clientSecret: String = "dc50f4eb-7e43-43e5-9e90-65065e8f6931"
    private static let apiKey = "33d089df-6abc-4ece-b6cc-497321a88a2e"
    private static let IP = "178.143.37.123"
    private let baseUrl = "https://webapi.developers.erstegroup.com/api/egb/sandbox/v1"
    
    private func executeRequest<T: Decodable>(_ request: APIRequest, with session: URLSession) -> AnyPublisher<T, Error> {
        return session.dataTaskPublisher(for: request.urlRequest)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NSError(domain: "NetworkManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                }
                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func loadWallet() -> AnyPublisher<WalletResponse, Error> {
        guard let identity = CertificateManagement.shared.loadP12Certificate(fileName: "sandbox", password: "Heslo1234") else {
            return Fail(error: NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load certificate"])).eraseToAnyPublisher()
        }

        let delegate = SSLSessionDelegate(identity: identity)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: nil)
        let request = LoadWalletRequest()
        return executeRequest(request, with: session)
    }

    func loadToken(walletId: String, walletSecret: String) -> AnyPublisher<TokenResponse, Error> {
        guard let identity = CertificateManagement.shared.loadP12Certificate(fileName: "sandbox", password: "Heslo1234") else {
            return Fail(error: NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load certificate"])).eraseToAnyPublisher()
        }

        let delegate = SSLSessionDelegate(identity: identity)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: nil)
        let request = LoadTokenRequest(walletId: walletId, walletSecret: walletSecret)
        return executeRequest(request, with: session)
    }

    func getAccounts(token: String) -> AnyPublisher<AccountsResponse, Error> {
        guard let identity = CertificateManagement.shared.loadP12Certificate(fileName: "sandbox", password: "Heslo1234") else {
            return Fail(error: NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load certificate"])).eraseToAnyPublisher()
        }

        let delegate = SSLSessionDelegate(identity: identity)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: nil)
        let request = GetAccountsRequest(token: token)
        return executeRequest(request, with: session)
    }

    func getAccountDetails(token: String, resourceId: String) -> AnyPublisher<AccountDetailResponse, Error> {
        guard let identity = CertificateManagement.shared.loadP12Certificate(fileName: "sandbox", password: "Heslo1234") else {
            return Fail(error: NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load certificate"])).eraseToAnyPublisher()
        }

        let delegate = SSLSessionDelegate(identity: identity)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: nil)
        let request = GetAccountDetailsRequest(token: token, resourceId: resourceId)
        return executeRequest(request, with: session)
    }
    
    func getAccountBalances(token: String, resourceId: String) -> AnyPublisher<AccountBalanceResponse, Error> {
        guard let identity = CertificateManagement.shared.loadP12Certificate(fileName: "sandbox", password: "Heslo1234") else {
            return Fail(error: NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load certificate"])).eraseToAnyPublisher()
        }
    
        let delegate = SSLSessionDelegate(identity: identity)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: nil)
        let request = GetBalancesRequest(token: token, resourceId: resourceId)
        return executeRequest(request, with: session)
    }

    func getAccountTransactions(token: String, resourceId: String) -> AnyPublisher<AccountTransactionResponse, Error> {
        guard let identity = CertificateManagement.shared.loadP12Certificate(fileName: "sandbox", password: "Heslo1234") else {
            return Fail(error: NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load certificate"])).eraseToAnyPublisher()
        }

        let delegate = SSLSessionDelegate(identity: identity)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: nil)
        let request = GetTransactionsRequest(token: token, resourceId: resourceId)
        return executeRequest(request, with: session)
    }
    
    // FIXME: not used for now
    func addBankAccount(token: String, idpCode: String) -> AnyPublisher<LoginResponse, Error> {
        // return executeRequest(request, with: session)
        let url = URL(string: "\(baseUrl)/wallet/v1/banks")!
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
}
