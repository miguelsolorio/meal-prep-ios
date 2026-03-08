import UIKit
import UniformTypeIdentifiers

@MainActor
final class ShareViewController: UIViewController {

    // MARK: - UI

    private let iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bag.fill"))
        iv.tintColor = UIColor.systemGreen
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Meal Prep"
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Opening recipe…"
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        spinner.startAnimating()
        extractAndImport()
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, subtitleLabel, spinner])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.setCustomSpacing(16, after: iconView)
        stack.setCustomSpacing(16, after: subtitleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 52),
            iconView.heightAnchor.constraint(equalToConstant: 52),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - Logic

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
            let url = item as? URL
            Task { @MainActor [weak self] in
                if let url {
                    // Save to shared UserDefaults first so the main app can pick it up
                    let defaults = UserDefaults(suiteName: "group.com.miguelsolorio.mealprep")
                    defaults?.set(url.absoluteString, forKey: "pending_import_url")
                    defaults?.synchronize()

                    self?.subtitleLabel.text = "Opening Meal Prep…"
                    self?.openMainApp(urlString: url.absoluteString)

                    // Brief pause so the user sees feedback before the sheet dismisses
                    try? await Task.sleep(for: .milliseconds(400))
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
                app.perform(
                    NSSelectorFromString("openURL:options:completionHandler:"),
                    with: appURL,
                    with: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: false]
                )
                return
            }
            responder = r.next
        }
    }

    private func finish() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
