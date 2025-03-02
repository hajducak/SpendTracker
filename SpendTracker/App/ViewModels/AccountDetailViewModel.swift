import Foundation
import Combine

enum AccountDetailContentState {
    case error(String)
    case loading
    case content(AccountDetailContentData)
}

final class AccountDetailViewModel: ObservableObject {
    @Published var state: AccountDetailContentState = .loading
    
    private var cancellables: Set<AnyCancellable> = []
    private let networkManager: NetworkManagerProtocol
    private let accountDetailContentDataFactory: AccountDetailContentDataFactory
    private let resourceId: String

    init(networkManager: NetworkManagerProtocol, accountDetailContentDataFactory: AccountDetailContentDataFactory, resourceId: String) {
        self.accountDetailContentDataFactory = accountDetailContentDataFactory
        self.networkManager = networkManager
        self.resourceId = resourceId
        
        loadAccountDetails()
    }
    
    func refreshData() {
        loadAccountDetails()
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
    
    func loadAccountDetails() {
        loadToken()
            .flatMap({ [weak self] tokenResponse -> AnyPublisher<(AccountDetailResponse, AccountBalanceResponse, AccountTransactionResponse), Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "LoadAccountDetails", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self deallocated"]))
                        .eraseToAnyPublisher()
                }
                let accountInfoPublisher = networkManager.getAccountDetails(token: tokenResponse.accessToken, resourceId: resourceId)
                let balancesPublisher = networkManager.getAccountBalances(token: tokenResponse.accessToken, resourceId: resourceId)
                let transactionsPublisher = networkManager.getAccountTransactions(token: tokenResponse.accessToken, resourceId: resourceId)
                return Publishers.Zip3(accountInfoPublisher, balancesPublisher, transactionsPublisher)
                    .eraseToAnyPublisher()
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .error("Failure: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] accountResponse, balancesResponse, transactionsResponse in
                guard let self else { return }
                let transactions = (transactionsResponse.transactions?.booked ?? []) + (transactionsResponse.transactions?.pending ?? [])
                state = .content(
                    accountDetailContentDataFactory.data(
                        accountDetail: accountResponse.account,
                        balances: balancesResponse.balances,
                        transactions: transactions
                    )
                )
            })
            .store(in: &cancellables)
    }
}
