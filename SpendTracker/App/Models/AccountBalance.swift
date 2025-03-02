import Foundation

struct AccountInfo: Decodable {
    let iban: String
    let currency: String
}

struct AccountBalance: Decodable {
    let balanceAmount: BalanceAmount
    let balanceType: String
    let lastChangeDateTime: String
    let referenceDate: String
}

struct BalanceAmount: Decodable {
    let amount: String
    let currency: String
}
