import Foundation

struct WalletResponse: Decodable {
    let walletId: String
    let walletSecret: String
}
