import Foundation

struct AccountBalanceResponse: Decodable {
    let account: AccountInfo?
    let balances: [AccountBalance]
}
