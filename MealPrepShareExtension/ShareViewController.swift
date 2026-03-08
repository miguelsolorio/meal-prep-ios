import UIKit
import UniformTypeIdentifiers

@MainActor
final class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        extractAndImport()
    }

    private func extractAndImport() {
        guard
            let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let provider = item.attachments?.first(where: {
                $0.hasItemConformingToTypeIdentifier(UTType.url.identifier)
            })
        else {
            finish()
            return
        }

        provider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] item, _ in
            let url = item as? URL  // cast before crossing actor boundary
            Task { @MainActor [weak self] in
                if let url {
                    let defaults = UserDefaults(suiteName: "group.com.miguelsolorio.mealprep")
                    defaults?.set(url.absoluteString, forKey: "pending_import_url")
                    defaults?.synchronize()
                    self?.openMainApp(urlString: url.absoluteString)
                }
                self?.finish()
            }
        }
    }

    private func openMainApp(urlString: String) {
        let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let appURL = URL(string: "mealprep://import?url=\(encoded)") else { return }
        var responder: UIResponder? = self
        while let r = responder {
            if let app = r as? UIApplication {
                app.perform(NSSelectorFromString("openURL:"), with: appURL)
                return
            }
            responder = r.next
        }
    }

    private func finish() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
