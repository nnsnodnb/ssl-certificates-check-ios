//
//  SearchResultDetailPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import ComposableArchitecture
import SFSafeSymbols
import SubscriptionFeature
import SwiftUI
import X509Parser

package struct SearchResultDetailPage: View {
  // MARK: - Properties
  @Bindable package var store: StoreOf<SearchResultDetailReducer>

  private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .full
    return dateFormatter
  }()

  // MARK: - Body
  package var body: some View {
    form
      .navigationTitle(store.x509.subject.commonName ?? "")
      .navigationBarTitleDisplayMode(.inline)
      .onAppear {
        store.send(.appear)
      }
      .sheet(item: $store.scope(state: \.paywall, action: \.paywall)) { store in
        PaywallPage(store: store)
      }
  }
}

// MARK: - Private method
private extension SearchResultDetailPage {
  var form: some View {
    Form {
      otherSection
      contentSection(title: "Issued to", distinguishedNames: store.x509.subject)
      contentSection(title: "Issued by", distinguishedNames: store.x509.issuer)
      validityPeriodSection
      sha256FingerprintSection
    }
    .formStyle(.grouped)
  }

  var otherSection: some View {
    Section {
      item(title: "Version", content: "Version \(store.x509.version)")
      item(
        title: "Serial Number",
        content: store.x509.serialNumber,
        needPremiumSubscription: true,
      )
    }
  }

  func contentSection(title: String, distinguishedNames: X509.DistinguishedNames) -> some View {
    Section(
      content: {
        if let commonName = distinguishedNames.commonName {
          item(title: "Common name", content: commonName)
        }
        if let organization = distinguishedNames.organization {
          item(title: "Organization", content: organization)
        }
        if let organizationalUnit = distinguishedNames.organizationalUnit {
          item(title: "Organizational unit", content: organizationalUnit)
        }
        if let country = distinguishedNames.country {
          item(title: "Country", content: country)
        }
        if let stateOrProvinceName = distinguishedNames.stateOrProvinceName {
          item(title: "State or Province name", content: stateOrProvinceName)
        }
        if let locality = distinguishedNames.locality {
          item(title: "Locality", content: locality)
        }
        item(title: nil, content: distinguishedNames.all)
      },
      header: {
        Text(title)
          .font(.system(size: 14))
      }
    )
  }

  var validityPeriodSection: some View {
    Section(
      content: {
        item(title: "Issued", content: dateFormatter.string(from: store.x509.notValidBefore))
        item(title: "Expired", content: dateFormatter.string(from: store.x509.notValidAfter))
      },
      header: {
        Text("Validity Period")
          .font(.system(size: 14))
      }
    )
  }

  var sha256FingerprintSection: some View {
    Section(
      content: {
        item(
          title: "Certificate",
          content: store.x509.sha256Fingerprint.certificate,
          needPremiumSubscription: true,
        )
        item(
          title: "Public key",
          content: store.x509.sha256Fingerprint.publicKey,
          needPremiumSubscription: true,
        )
      },
      header: {
        Text("SHA256 Fingerprints")
          .font(.system(size: 14))
      }
    )
  }

  func item(title: String?, content: String, needPremiumSubscription: Bool = false) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      if let title {
        Text(title)
          .font(.system(size: 12))
          .foregroundStyle(.secondary)
      }
      if needPremiumSubscription && !store.isPremiumActive {
        needPremiumSubscriptionItem(content: content)
      } else {
        Text(content)
          .textSelection(.enabled)
      }
    }
  }

  func needPremiumSubscriptionItem(content: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(content.prefix(Int(ceil(Double(content.count) * 0.25))) + "...")
      Button(
        action: {
          store.send(.showPaywall)
        },
        label: {
          if #available(iOS 26.0, *) {
            Label(
              title: {
                Text("Show all content (Premium)")
                  .fontWeight(.semibold)
              },
              icon: {
                Image(systemSymbol: .lockFill)
                  .foregroundStyle(Color(UIColor.systemYellow))
              }
            )
            .font(.system(size: 14))
            .labelIconToTitleSpacing(4)
          } else {
            HStack(alignment: .center, spacing: 4) {
              Image(systemSymbol: .lockFill)
                .foregroundStyle(Color(UIColor.systemYellow))
              Text("Show all content (Premium)")
                .fontWeight(.semibold)
            }
            .font(.system(size: 14))
          }
        }
      )
      .font(.system(size: 14))
      .buttonStyle(.plain)
      .padding(.vertical, 4)
    }
  }
}

#if DEBUG
#Preview {
  SearchResultDetailPage(
    store: .init(
      initialState: SearchResultDetailReducer.State(x509: .stub)
    ) {
      SearchResultDetailReducer()
    }
  )
}
#endif
