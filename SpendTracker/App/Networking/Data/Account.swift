import Foundation

struct Account: Codable {
    let resourceId: String
    let iban: String
    let links: AccountLinks
    let ext: AccountExt

    enum CodingKeys: String, CodingKey {
        case resourceId, iban
        case links = "_links"
        case ext = "_ext"
    }
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
