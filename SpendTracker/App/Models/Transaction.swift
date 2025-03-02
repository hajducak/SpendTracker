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
    let debtorName: String?
    let remittanceInformationUnstructured: String?
}

struct TransactionAmount: Decodable {
    let amount: String
    let currency: String
}
