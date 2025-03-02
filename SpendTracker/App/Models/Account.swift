import Foundation

struct Account: Codable {
    let resourceId: String
    let iban: String
    let _links: AccountLinks
    let _ext: AccountExt
}

struct AccountLinks: Codable {
    let detail: Link
    let transactions: Link
    let balances: Link
}

struct Link: Codable {
    let href: String
}

struct AccountExt: Codable {
    let identityProviderCode: String
}

struct AccountsResponse: Codable {
    let accounts: [Account]
}
