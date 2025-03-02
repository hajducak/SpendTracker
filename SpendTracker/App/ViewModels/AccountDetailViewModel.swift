import Foundation
import Combine

class AccountDetailViewModel: ObservableObject {
    @Published var accountDetail: AccountDetail?
    @Published var errorMessage: String?
    
    private var cancellables: Set<AnyCancellable> = []
    private let networkManager: NetworkManagerProtocol
    private let accountViewModel: AccountViewModel

    init(networkManager: NetworkManagerProtocol, accountViewModel: AccountViewModel) {
        self.networkManager = networkManager
        self.accountViewModel = accountViewModel
        
        loadAccountDetail()
    }
    
    func loadAccountDetail() {
        guard let token = accountViewModel.token else {
            // Get token or what ?
            return
        }
        networkManager.getAccountDetails(token: token, resourceId: accountViewModel.resourceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Account detail loaded.")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Error: \(error)")
                }
            }, receiveValue: { accountResponse in
                self.accountDetail = accountResponse.account
            }).store(in: &cancellables)
    }
}
