import Foundation
import Combine

enum AccountsContentState {
    case empty
    case error(String)
    case loading
    case content([AccountsContentData])
}

final class AccountsViewModel: ObservableObject {
    @Published var state: AccountsContentState = .loading
    
    let networkManager: NetworkManagerProtocol
    private var cancellables: Set<AnyCancellable> = []
    private var token: String?
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        loadAccounts()
    }

    func refreshData() {
        loadAccounts()
    }

    private func loadAccounts() {
        loadToken()
            .flatMap({ tokenResponse -> AnyPublisher<AccountsResponse, Error> in
                self.token = tokenResponse.accessToken
                return self.networkManager.getAccounts(token: tokenResponse.accessToken)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .error(error.localizedDescription)
                }
            },  receiveValue: { accountsResponse in
                let accounts = accountsResponse.accounts.compactMap({
                    AccountsContentData(resourceId: $0.resourceId, iban: $0.iban)
                })
                self.state = accounts.isEmpty ? .empty : .content(accounts)
            }).store(in: &cancellables)
    }
    
    private func loadToken() -> AnyPublisher<TokenResponse, Error> {
        return networkManager.loadWallet()
            .flatMap({ walletResponse -> AnyPublisher<TokenResponse, Error> in
                return self.networkManager.loadToken(
                    walletId: walletResponse.walletId,
                    walletSecret: walletResponse.walletSecret
                )
            })
            .eraseToAnyPublisher()
    }
    
    // TODO: If login required
    // Only if we do not have this (just once)
    func addBankAccount(token: TokenResponse) {
        let idpCode = "CSAS"
        networkManager.addBankAccount(
            token: token.accessToken,
            idpCode: idpCode
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                print("Banka account request finished.")
            case .failure(let error):
                self?.state = .error(error.localizedDescription)
            }
        }, receiveValue: { bankAccountResponse in
            print("Login URL: \(bankAccountResponse.loginUrl)")
            // IF we need login open this in web page
        }).store(in: &cancellables)
    }
}
