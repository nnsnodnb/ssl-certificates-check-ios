//
//  SearchClient.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Dependencies
import Foundation
import XCTestDynamicOverlay

package struct SearchClient: Sendable {
    // MARK: - Properties
    package var fetchCertificates: @Sendable (URL) async throws -> X509
}

// MARK: - DependencyKey
extension SearchClient: DependencyKey {
    package static let liveValue: SearchClient = .init(
        fetchCertificates: { try await Implementation.fetchCertificates(fromURL: $0) }
    )

    package static let testValue: SearchClient = .init(
        fetchCertificates: unimplemented("\(Self.self).fetchCertificates")
    )
}

// MARK: - Implementation
private extension SearchClient {
    struct Implementation {
        // MARK: - Error
        package enum Error: Swift.Error {
            case unknown
        }

        static func fetchCertificates(fromURL url: URL) async throws -> X509 {
            let sessionDelegate = SessionDelegate()
            let session = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: nil)
            _ = try await session.data(from: url)
            guard let serverTrust = sessionDelegate.serverTrust else {
                throw Error.unknown
            }
            return try X509(serverTrust: serverTrust)
        }
    }
}

// MARK: - SessionDelegate
private extension SearchClient.Implementation {
    final class SessionDelegate: NSObject, URLSessionDelegate {
        // MARK: - Properties
        private(set) var serverTrust: SecTrust?

        // MARK: - URLSessionDelegate
        func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge
        ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
            self.serverTrust = challenge.protectionSpace.serverTrust
            return (.performDefaultHandling, nil)
        }
    }
}
