import Foundation
import Combine

class AccountViewModel: ObservableObject {
    @Published var accounts: [Account]?
    @Published var errorMessage: String?
    
    private let networkManager: NetworkManagerProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        loadAccounts()
    }
    
    func loadToken() -> AnyPublisher<TokenResponse, Error> {
        return networkManager.loadWallet()
            .flatMap({ walletResponse -> AnyPublisher<TokenResponse, Error> in
                print("walletId: \(walletResponse.walletId)")
                print("walletSecret: \(walletResponse.walletSecret)")
                return self.networkManager.loadToken(
                    walletId: walletResponse.walletId,
                    walletSecret: walletResponse.walletSecret
                )
            })
            .eraseToAnyPublisher()
    }

    // If login required
    // Only if we do not have this (just once)
    func addBankAccount(token: TokenResponse) {
        let idpCode = "CSAS"
        networkManager.addBankAccount(
            token: token.accessToken,
            idpCode: idpCode
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Banka account request finished.")
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                print("Error: \(error)")
            }
        }, receiveValue: { bankAccountResponse in
            print("Login URL: \(bankAccountResponse.loginUrl)")
            // IF we need login open this in web page
        }).store(in: &cancellables)
    }
    
    func loadAccounts() {
        loadToken()
            .flatMap({ tokenResponse -> AnyPublisher<AccountsResponse, Error> in
                return self.networkManager.getAccounts(token: tokenResponse.accessToken)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Account Loading finished.")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Error: \(error)")
                }
            },  receiveValue: { accountsResponse in
                self.accounts = accountsResponse.accounts
                print("Accounts: \(accountsResponse.accounts)")
            }).store(in: &cancellables)
     }
}
