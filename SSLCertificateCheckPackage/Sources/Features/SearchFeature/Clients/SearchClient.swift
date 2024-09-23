//
//  SearchClient.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import Dependencies
import DependenciesMacros
import Foundation
import X509Parser

@DependencyClient
package struct SearchClient: Sendable {
    // MARK: - Properties
    var fetchCertificates: @Sendable (URL) async throws -> [X509]
}

// MARK: - DependencyKey
extension SearchClient: DependencyKey {
    package static let liveValue: SearchClient = .init(
        fetchCertificates: { try await Implementation.fetchCertificates(fromURL: $0) }
    )
    package static let testValue: SearchClient = .init()
}

// MARK: - Implementation
private extension SearchClient {
    struct Implementation {
        // MARK: - Error
        package enum Error: Swift.Error {
            case unknown
        }

        static func fetchCertificates(fromURL url: URL) async throws -> [X509] {
            return try await withCheckedThrowingContinuation { continuation in
                let sessionDelegate = SessionDelegate { serverTrust in
                    guard let serverTrust else {
                        continuation.resume(throwing: Error.unknown)
                        return
                    }
                    do {
                        let x509s = try X509Parser.parse(serverTrust: serverTrust)
                        continuation.resume(returning: x509s)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                let session = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: nil)
                Task {
                    _ = try await session.data(from: url)
                }
            }
        }

        // MARK: - URLSessionDelegate
        private final class SessionDelegate: NSObject, URLSessionDelegate {
            // MARK: - Properties
            private let serverTrustCompletion: @Sendable (SecTrust?) -> Void

            // MARK: - Initialize
            init(serverTrustCompletion: @Sendable @escaping (SecTrust?) -> Void) {
                self.serverTrustCompletion = serverTrustCompletion
            }

            // MARK: - URLSessionDelegate
            func urlSession(
                _ session: URLSession,
                didReceive challenge: URLAuthenticationChallenge
            ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
                let serverTrust = challenge.protectionSpace.serverTrust
                serverTrustCompletion(serverTrust)
                return (.performDefaultHandling, nil)
            }
        }
    }
}
