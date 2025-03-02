import Foundation
import Combine

class AccountViewModel: ObservableObject {
    @Published var walletId: String?
    @Published var walletSecret: String?
    @Published var errorMessage: String?
    
    private let networkManager: NetworkManagerProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        loadWallet()
    }
    
    func loadWallet() {
        networkManager.loadWallet()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Wallet request finished.")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Error: \(error)")
                }
            }, receiveValue: { walletResponse in
                self.walletId = walletResponse.walletId
                self.walletSecret = walletResponse.walletSecret
                print("walletId: \(walletResponse.walletId)")
                print("walletSecret: \(walletResponse.walletSecret)")
            }).store(in: &cancellables)
    }
}
