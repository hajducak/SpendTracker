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
    private func createSession() -> URLSession? {
        guard let identity = CertificateManagement.shared.loadP12Certificate(fileName: "sandbox", password: "Heslo1234") else {
            return nil
        }
        let delegate = SSLSessionDelegate(identity: identity)
        let sessionConfig = URLSessionConfiguration.default
        return URLSession(configuration: sessionConfig, delegate: delegate, delegateQueue: nil)
    }
    
    private func executeRequest<T: Decodable>(_ request: APIRequest) -> AnyPublisher<T, Error> {
        guard let session = createSession() else {
            return Fail(error: NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load certificate"])).eraseToAnyPublisher()
        }
        
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
        return executeRequest(LoadWalletRequest())
    }
    
    func loadToken(walletId: String, walletSecret: String) -> AnyPublisher<TokenResponse, Error> {
        return executeRequest(LoadTokenRequest(walletId: walletId, walletSecret: walletSecret))
    }
    
    func getAccounts(token: String) -> AnyPublisher<AccountsResponse, Error> {
        return executeRequest(GetAccountsRequest(token: token))
    }
    
    func getAccountDetails(token: String, resourceId: String) -> AnyPublisher<AccountDetailResponse, Error> {
        return executeRequest(GetAccountDetailsRequest(token: token, resourceId: resourceId))
    }
    
    func getAccountBalances(token: String, resourceId: String) -> AnyPublisher<AccountBalanceResponse, Error> {
        return executeRequest(GetBalancesRequest(token: token, resourceId: resourceId))
    }
    
    func getAccountTransactions(token: String, resourceId: String) -> AnyPublisher<AccountTransactionResponse, Error> {
        return executeRequest(GetTransactionsRequest(token: token, resourceId: resourceId))
    }
    
    /// FIXME: not using at this time - when not have any bank account create it and login
    func addBankAccount(token: String, idpCode: String) -> AnyPublisher<LoginResponse, Error> {
        return executeRequest(AddBankAccountRequest(idpCode: idpCode, token: token))
    }
}
