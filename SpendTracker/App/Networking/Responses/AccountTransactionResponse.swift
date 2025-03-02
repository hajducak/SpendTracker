struct AccountTransactionResponse: Decodable {
    let account: AccountInfo
    let transactions: Transactions
}
