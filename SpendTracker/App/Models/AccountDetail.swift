import Foundation

struct AccountDetail: Decodable {
    struct Links: Decodable {
        let detail: Link
        let transactions: Link
        let balances: Link
    }

    struct Link: Decodable {
        let href: String
    }

    struct Ext: Decodable {
        let identityProviderCode: String
        let message: String
    }

    let resourceId: String
    let iban: String
    let currency: String
    let name: String
    let product: String
    let cashAccountType: String
    let status: String
    let bic: String
    let usage: String
    let links: Links
    let ext: Ext

    enum CodingKeys: String, CodingKey {
        case resourceId, iban, currency, name, product, cashAccountType, status, bic, usage
        case links = "_links"
        case ext = "_ext"
    }
}
