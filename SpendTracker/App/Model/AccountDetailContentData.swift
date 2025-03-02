import Foundation
import SwiftUI

struct AccountDetailContentData {
    let accountDetail: AccountDetailData
    let balances: [AccountBalanceData]
    let transactions: [TransactionData]
}

struct AccountDetailData {
    let iban: String
    let currency: String
    let name: String
    let product: String
    let cashAccountType: String
    let status: String
    let bic: String
    let usage: String

    init(accountDetail: AccountDetail) {
        self.iban = accountDetail.iban ?? "Missing IBAN"
        self.currency = accountDetail.currency
        self.name = accountDetail.name ?? "Missing account name"
        self.product = accountDetail.product ?? "Missing product name"
        self.cashAccountType = accountDetail.cashAccountType  ?? "Missing cash type"
        self.status = accountDetail.status ?? "Missing status"
        self.bic = accountDetail.bic ?? "Missing bic"
        self.usage = accountDetail.usage  ?? "Missing usage"
    }
}

struct AccountBalanceData: Identifiable {
    let id: String = UUID().uuidString
    let amount: String
    let currency: String
    
    init(balance: AccountBalance) {
        self.amount = balance.balanceAmount.amount
        self.currency = balance.balanceAmount.currency
    }
}

struct TransactionData: Identifiable {
    let id: String
    let date: String
    let amount: String
    var amountColor: Color {
        return amount.contains("-") ? .red : .green
    }
    let currency: String
    let creditorName: String
    let creditorIBAN: String
    let debtorName: String
    let debtorIBAN: String
    let additionalInfo: String?
    
    init(transaction: Transaction) {
        self.id = transaction.transactionId ?? UUID().uuidString
        self.date = transaction.bookingDate ?? "Unknown booking date"
        self.amount = transaction.transactionAmount.amount
        self.currency = transaction.transactionAmount.currency
        self.creditorName = transaction.creditorName ?? "Unknown name"
        self.creditorIBAN = transaction.creditorAccount?.iban ?? "Unknown IBAN"
        self.debtorName = transaction.debtorName ?? "Unknown name"
        self.debtorIBAN = transaction.debtorAccount?.iban ?? "Unknown IBAN"
        self.additionalInfo = transaction.remittanceInformationUnstructured
    }
}

protocol AccountDetailContentDataFactory {
    func data(accountDetail: AccountDetail, balances: [AccountBalance], transactions: [Transaction]) -> AccountDetailContentData
}

final class AccountDetailContentDataFactoryImpl : AccountDetailContentDataFactory {
    func data(accountDetail: AccountDetail, balances: [AccountBalance], transactions: [Transaction]) -> AccountDetailContentData {
        AccountDetailContentData(
            accountDetail: AccountDetailData(accountDetail: accountDetail),
            balances: balances.compactMap { AccountBalanceData(balance: $0) },
            transactions: transactions.compactMap { TransactionData(transaction: $0) }
        )
    }
}
