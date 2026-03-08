import UIKit
import UniformTypeIdentifiers

private enum ShareConstants {
    static let appGroup = "group.com.miguelsolorio.mealprep"
    static let pendingImportURL = "pending_import_url"
    static let urlScheme = "mealprep://import?url="
}

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
            let attachments = item.attachments,
            !attachments.isEmpty
        else {
            finish()
            return
        }

        // Try URL type first, then fall back to plain text (Safari shares both)
        if let provider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
            provider.loadObject(ofClass: URL.self) { [weak self] url, _ in
                self?.scheduleImport(url)
            }
        } else if let provider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) }) {
            provider.loadObject(ofClass: String.self) { [weak self] text, _ in
                let url = text.flatMap { URL(string: $0.trimmingCharacters(in: .whitespacesAndNewlines)) }
                self?.scheduleImport(url)
            }
        } else {
            finish()
        }
    }

    private func scheduleImport(_ url: URL?) {
        Task { @MainActor [weak self] in
            await self?.handleExtractedURL(url)
        }
    }

    private func handleExtractedURL(_ url: URL?) async {
        if let url {
            UserDefaults(suiteName: ShareConstants.appGroup)?
                .set(url.absoluteString, forKey: ShareConstants.pendingImportURL)

            subtitleLabel.text = "Opening Meal Prep…"
            openMainApp(urlString: url.absoluteString)

            try? await Task.sleep(for: .milliseconds(400))
        }
        finish()
    }

    private func openMainApp(urlString: String) {
        let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let appURL = URL(string: "\(ShareConstants.urlScheme)\(encoded)") else { return }

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
