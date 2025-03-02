import SwiftUI
import WebKit

struct AccountsView: View {
    @ObservedObject private var viewModel: AccountsViewModel
    @State private var showWebView = false
    @State private var webViewURL: URL?

    init(viewModel: AccountsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                switch viewModel.state {
                case .empty:
                    VStack {
                        Spacer()
                        Text("No data found")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding()
                        Button("Add Bank Account") {
                            viewModel.refreshData()
                        }
                        Spacer()
                    }
                case .error(let error):
                    VStack {
                        Spacer()
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                        Button("Refresh data") {
                            viewModel.refreshData()
                        }
                        Spacer()
                    }
                case .loading:
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .content(let accounts):
                    List(Array(accounts.enumerated()), id: \.element.resourceId) { index, account in
                        NavigationLink(
                            destination: AccountDetailView(
                                viewModel: AccountDetailViewModel(
                                    networkManager: viewModel.networkManager,
                                    accountDetailContentDataFactory: AccountDetailContentDataFactoryImpl(),
                                    resourceId: account.resourceId
                                )
                            )
                        ) {
                            VStack(alignment: .leading) {
                                Text("Account #\(index + 1):")
                                    .font(.title3)
                                Text("IBAN: \(account.iban)")
                                    .font(.caption)
                            }
                        }
                    }
                case .showLogin(let url):
                    Color.clear
                        .onAppear {
                            webViewURL = url
                            showWebView = true
                        }
                }
            }
            .navigationTitle("My Accounts")
            .sheet(isPresented: $showWebView, onDismiss: {
                viewModel.handleWebViewClosed()
            }) {
                if let url = webViewURL {
                    WebView(url: url)
                }
            }
        }
    }
}


struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
