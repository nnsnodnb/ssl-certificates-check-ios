//
//  SearchResultPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import ComposableArchitecture
import SwiftUI
import X509Parser

public struct SearchResultPage: View {
  // MARK: - Properties
  public let store: StoreOf<SearchResultReducer>

  private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .full
    return dateFormatter
  }()

  // MARK: - Body
  public var body: some View {
    list
      .navigationTitle(store.domain)
  }

  private var list: some View {
    List {
      summarySection
      certificatesSection
    }
  }

  private var summarySection: some View {
    Section {
      HStack(alignment: .top, spacing: 12) {
        Image(.icIntermediateCertificate)
          .resizable()
          .scaledToFit()
          .frame(height: 48)
        if let certificate = store.searchedDNSCertificate {
          VStack(alignment: .leading, spacing: 8) {
            Text(certificate.subject.commonName ?? "Unknown")
              .bold()
            HStack(alignment: .center, spacing: 8) {
              Image(systemSymbol: store.isValidCertificate ? .checkmarkCircleFill : .xmarkCircleFill)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundStyle(store.isValidCertificate ? Color.green : Color.red)
              Text("This certificate is \(store.isValidCertificate ? "" : "in")valid.")
                .font(.system(size: 14))
            }
          }
        }
      }
      if let certificate = store.certificates.first {
        VStack(alignment: .center, spacing: 12) {
          Group {
            HStack(alignment: .top, spacing: 12) {
              Text("Web site:")
                .foregroundStyle(.gray)
                .frame(width: 90, alignment: .trailing)
              Text(certificate.subject.commonName ?? "Unknown")
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top, spacing: 12) {
              Text("Issued by:")
                .foregroundStyle(.gray)
                .frame(width: 90, alignment: .trailing)
              Text(certificate.issuer.commonName ?? "Unknown")
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(alignment: .top, spacing: 12) {
              Text("Expired:")
                .foregroundStyle(.gray)
                .frame(width: 90, alignment: .trailing)
              Text(dateFormatter.string(from: certificate.notValidAfter))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
        }
      }
    }
  }

  private var certificatesSection: some View {
    Section(
      content: {
        ForEach(store.certificates) { certificate in
          row(certificate: certificate) {
            store.send(.selectCertificate(certificate))
          }
        }
      },
      header: {
        Text("Details")
      },
    )
  }

  private func row(certificate: X509, action: @escaping () -> Void) -> some View {
    Button(
      action: action,
      label: {
        HStack(alignment: .center, spacing: 0) {
          VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
              rowCertificateImage(certificate: certificate)
              Text(certificate.subject.commonName ?? "Unknown")
            }
            Text("Issued by: \(certificate.issuer.commonName ?? "Unknown")")
              .font(.system(size: 16))
              .foregroundStyle(.gray)
          }
          Spacer()
          ListRowChevronRight()
        }
      }
    )
    .tint(.primary)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  @ViewBuilder
  private func rowCertificateImage(certificate: X509) -> some View {
    let isRootCertificate = certificate.subject == certificate.issuer
    Image(isRootCertificate ? .icRootCertificate : .icIntermediateCertificate)
      .resizable()
      .scaledToFit()
      .frame(height: 32, alignment: .top)
  }
}

#if DEBUG
#Preview {
  NavigationStack(
    root: {
      SearchResultPage(
        store: .init(
          initialState: SearchResultReducer.State(
            domain: "example.com",
            certificates: .init(
              uniqueElements: [.stub]
            )
          ),
          reducer: {
            SearchResultReducer()
          },
        ),
      )
    },
  )
}
#endif
