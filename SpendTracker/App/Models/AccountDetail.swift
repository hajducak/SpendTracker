import Foundation

struct AccountResponse: Decodable {
    let account: AccountDetail
}

struct AccountDetail: Decodable {
    struct Links: Decodable {
        let detail: Link
        let transactions: Link
        let balances: Link
    }
    
    struct Link: Decodable {
        let href: String
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
    let _links: Links
    let _ext: Ext
    
    struct Ext: Decodable {
        let identityProviderCode: String
        let message: String
    }
}
