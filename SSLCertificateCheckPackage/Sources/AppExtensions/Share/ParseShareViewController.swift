//
//  ParseShareViewController.swift
//
//
//  Created by Yuya Oka on 2023/10/16.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

open class ParseShareViewController: UIHostingController<ShareView> {
    // MARK: - Properties
    private static let universalLinkComponent = "https://nnsnodnb.moe/ssl-certificates-check-ios"

    // MARK: - Initialize
    public required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: ShareView())
    }

    // MARK: - Life Cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        Task { @MainActor in
            do {
                let url = try await generateOpenURL()
                openURL(url)
            } catch {
                extensionContext?.cancelRequest(withError: error)
            }
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        extensionContext?.completeRequest(returningItems: nil)
    }
}

// MARK: - Private method
private extension ParseShareViewController {
    func generateOpenURL() async throws -> URL {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = item.attachments?.first else {
            throw Error.invalidItemProvider
        }
        guard itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier),
              let url = try await itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier) as? URL else {
            throw Error.notHasURLItem
        }
        guard let base64EncodedURL = url.absoluteString.data(using: .utf8)?.base64EncodedString(),
              let openURL = URL(string: "\(Self.universalLinkComponent)?encodedURL=\(base64EncodedURL)") else {
            throw Error.internal
        }
        return openURL
    }

    // Ref: https://zenn.dev/kyome/articles/88876501b05f13
    func openURL(_ url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                let selector = sel_registerName("openURL:")
                application.perform(selector, with: url)
                break
            }
            responder = responder?.next
        }
    }
}

// MARK: - Error
private extension ParseShareViewController {
    enum Error: Swift.Error {
        case invalidItemProvider
        case notHasURLItem
        case `internal`
    }
}
