import Foundation
import Security

class CertificateManagement {
    private static let fileName = "sandbox"
    private static let password = "Heslo1234"
    
    static let shared = CertificateManagement()
    
    private init() {}

    func loadP12Certificate() -> SecIdentity? {
        guard let p12Path = Bundle.main.path(forResource: Self.fileName, ofType: "p12"),
              let p12Data = try? Data(contentsOf: URL(fileURLWithPath: p12Path)) else {
            print("Unable to find or read the p12 file.")
            return nil
        }
        
        let options: [NSString: Any] = [
            kSecImportExportPassphrase: Self.password
        ]
        
        var items: CFArray?
        let status = SecPKCS12Import(p12Data as CFData, options as CFDictionary, &items)
        
        guard status == errSecSuccess, let itemsArray = items as? [[String: Any]], let firstItem = itemsArray.first else {
            print("Failed to import p12 file.")
            return nil
        }
        
        let identity = firstItem[kSecImportItemIdentity as String] as! SecIdentity
        
        return identity
    }
}

class SSLSessionDelegate: NSObject, URLSessionDelegate {
    var identity: SecIdentity

    init(identity: SecIdentity) {
        self.identity = identity
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            let credential = URLCredential(identity: identity, certificates: nil, persistence: .forSession)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
