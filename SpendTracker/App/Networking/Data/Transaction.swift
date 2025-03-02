import Foundation

struct Transactions: Decodable {
    let booked: [Transaction]?
    let pending: [Transaction]?
}

struct Transaction: Decodable {
    let transactionId: String?
    let bookingDate: String?
    let valueDate: String?
    let transactionAmount: TransactionAmount
    let creditorName: String?
    let creditorAccount: IBAN?
    let debtorName: String?
    let debtorAccount: IBAN?
    let remittanceInformationUnstructured: String?
}

struct IBAN: Decodable {
    let iban: String?
}

struct TransactionAmount: Decodable {
    let amount: String
    let currency: String
}
