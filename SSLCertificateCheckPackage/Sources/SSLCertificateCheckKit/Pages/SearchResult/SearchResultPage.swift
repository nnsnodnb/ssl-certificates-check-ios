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

  var list: some View {
    List {
      summarySection
      certificatesSection
    }
  }

  var summarySection: some View {
    Section {
      HStack(alignment: .top, spacing: 12) {
        Image(.icIntermediateCertificate)
          .resizable()
          .scaledToFit()
          .frame(height: 48)
        if let commonName = store.certificates.first?.subject.commonName {
          VStack(alignment: .leading, spacing: 8) {
            Text(commonName)
              .bold()
            HStack(alignment: .center, spacing: 8) {
              Image(systemSymbol: .checkmarkCircleFill)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .foregroundStyle(Color.green)
              Text("This certificate is valid.")
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

  var certificatesSection: some View {
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

  func row(certificate: X509, action: @escaping () -> Void) -> some View {
    Button(
      action: action,
      label: {
        HStack(alignment: .center, spacing: 0) {
          VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
              Image(store.certificates.last == certificate ? .icRootCertificate : .icIntermediateCertificate)
                .resizable()
                .scaledToFit()
                .frame(height: 32, alignment: .top)
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
