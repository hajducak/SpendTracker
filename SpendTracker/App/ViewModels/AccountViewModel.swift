import Foundation
import Combine

class AccountViewModel: ObservableObject {
    @Published var token: String?
    @Published var errorMessage: String?
    
    private let networkManager: NetworkManagerProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        loadData()
    }
    
    func loadData() {
        networkManager.loadWallet()
            .flatMap({ walletResponse -> AnyPublisher<TokenResponse, Error> in
                print("walletId: \(walletResponse.walletId)")
                print("walletSecret: \(walletResponse.walletSecret)")
                return self.networkManager.loadToken(
                    walletId: walletResponse.walletId,
                    walletSecret: walletResponse.walletSecret)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Token request finished.")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Error: \(error)")
                }
            }, receiveValue: { tokenResponse in
                self.token = tokenResponse.accessToken
                print("token: \(tokenResponse.accessToken)")
                print("tokenType: \(tokenResponse.tokenType)")
                print("expiresIn: \(tokenResponse.expiresIn)")
            }).store(in: &cancellables)
    }
}
