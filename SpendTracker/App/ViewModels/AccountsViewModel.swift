import Foundation
import Combine

enum AccountsContentState {
    case empty
    case error(String)
    case loading
    case content([AccountsContentData])
    case showLogin(url: URL)
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
            .flatMap({ [weak self] tokenResponse -> AnyPublisher<AccountsResponse, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "Self deallocated", code: 0, userInfo: nil)).eraseToAnyPublisher()
                }
                self.token = tokenResponse.accessToken
                return self.networkManager.getAccounts(token: tokenResponse.accessToken)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.handleLoadAccountsError(error)
                }
            }, receiveValue: { [weak self] accountsResponse in
                let accounts = accountsResponse.accounts.compactMap {
                    AccountsContentData(resourceId: $0.resourceId, iban: $0.iban)
                }
                self?.state = accounts.isEmpty ? .empty : .content(accounts)
            }).store(in: &cancellables)
    }

    private func loadToken() -> AnyPublisher<TokenResponse, Error> {
        return networkManager.loadWallet()
            .flatMap({ [weak self] walletResponse -> AnyPublisher<TokenResponse, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "Self deallocated", code: 0, userInfo: nil)).eraseToAnyPublisher()
                }
                return self.networkManager.loadToken(
                    walletId: walletResponse.walletId,
                    walletSecret: walletResponse.walletSecret
                )
            })
            .eraseToAnyPublisher()
    }

    private func handleLoadAccountsError(_ error: Error) {
        guard let token = self.token else {
            self.state = .error(error.localizedDescription)
            return
        }

        // FIXME: should have possibility to choos from user wich accounts to add
        addBankAccount(token: token)
    }

    private func addBankAccount(token: String) {
        let idpCode = "CSAS"
        networkManager.addBankAccount(
            token: token,
            idpCode: idpCode
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                print("Bank account request finished.")
            case .failure(let error):
                self?.state = .error(error.localizedDescription)
            }
        }, receiveValue: { [weak self] bankAccountResponse in
            guard let url = URL(string: bankAccountResponse.loginUrl) else {
                self?.state = .error("Invalid login URL")
                return
            }
            self?.state = .showLogin(url: url)
        }).store(in: &cancellables)
    }

    func handleWebViewClosed() {
        refreshData()
    }
}
