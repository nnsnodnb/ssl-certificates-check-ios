//
//  SearchResultPage.swift
//
//
//  Created by Yuya Oka on 2023/10/14.
//

import ComposableArchitecture
import SwiftUI
import X509Parser

@Reducer
public struct SearchResultReducer: Sendable {
  // MARK: - Destination
  public enum Destination: Hashable {
    case searchResultDetail(X509)
  }

  // MARK: - State
  @ObservableState
  public struct State: Equatable {
    // MARK: - Properties
    public let domain: String
    public let certificates: IdentifiedArrayOf<X509>
    public var columnVisibility: NavigationSplitViewVisibility = .all
    public var isPortrait = false
    public var searchResultDetail: SearchResultDetailReducer.State?
    @ObservationStateIgnored public var searchedDNSCertificate: X509? { certificates.first }
    @ObservationStateIgnored public var isValidCertificate: Bool { searchedDNSCertificate?.isValid ?? false }
  }

  // MARK: - Action
  public enum Action {
    case close
    case changedColumnVisibility(NavigationSplitViewVisibility)
    case changedIsPortrait(Bool)
    case showDestination(Destination?)
    case searchResultDetail(SearchResultDetailReducer.Action)
    case delegate(Delegate)

    // MARK: - Delegate
    @CasePathable
    public enum Delegate {
      case showedSearchResultDetail
    }
  }

  @Dependency(\.dismiss)
  private var dismiss

  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .close:
        return .run(
          operation: { _ in
            await dismiss()
          },
        )
      case let .changedColumnVisibility(columnVisibility):
        state.columnVisibility = columnVisibility
        return .none
      case let .changedIsPortrait(isPortrait):
        state.isPortrait = isPortrait
        return .none
      case let .showDestination(destination):
        switch destination {
        case let .searchResultDetail(x509):
          state.searchResultDetail = .init(x509: x509)
        case .none:
          state.searchResultDetail = nil
        }
        return .none
      case .searchResultDetail(.delegate(.appeared)):
        return .send(.delegate(.showedSearchResultDetail))
      case .searchResultDetail:
        return .none
      case .delegate:
        return .none
      }
    }
    .ifLet(\.searchResultDetail, action: \.searchResultDetail) {
      SearchResultDetailReducer()
    }
  }
}

public struct SearchResultPage: View {
  // MARK: - Properties
  @Bindable public var store: StoreOf<SearchResultReducer>

  @Dependency(\.mainQueue)
  private var mainQueue
  @Environment(\.horizontalSizeClass)
  private var horizontalSizeClass
  @Environment(\.verticalSizeClass)
  private var verticalSizeClass

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
    NavigationSplitView(
      columnVisibility: $store.columnVisibility.sending(\.changedColumnVisibility),
      sidebar: {
        list
          .navigationTitle(store.domain)
          .navigationScrollEdgeEffectSoft()
          .toolbar(store: store)
      },
      detail: {
        if let store = store.scope(\.searchResultDetail, action: \.searchResultDetail) {
          SearchResultDetailPage(store: store)
        } else {
          DetailNilView()
        }
      },
    )
    .onGeometryChange(
      for: Bool.self,
      of: { proxy in
        proxy.size.width < proxy.size.height
      },
      action: { isPortrait in
        store.send(.changedIsPortrait(isPortrait))
        // 開いた状態
        guard horizontalSizeClass == .regular && verticalSizeClass == .regular else {
          return
        }
        if isPortrait && store.searchResultDetail == nil {
          // 縦持ちで遷移先がない場合は全カラム
          Task {
            try? await mainQueue.sleep(for: .milliseconds(1))
            store.send(.changedColumnVisibility(.all))
          }
        } else if !isPortrait {
          // 横持ちであれば強制的に全カラム
          store.send(.changedColumnVisibility(.all))
        }
      },
    )
  }

  private var list: some View {
    List(
      selection: Binding<X509?>(
        get: {
          store.searchResultDetail?.x509
        },
        set: { x509 in
          if let x509 {
            store.send(.showDestination(.searchResultDetail(x509)))
          } else {
            store.send(.showDestination(nil))
          }
        },
      ),
      content: {
        summarySection
        certificatesSection
      },
    )
    .listStyle(.insetGrouped)
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
            store.send(.showDestination(.searchResultDetail(certificate)))
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

private extension View {
  func toolbar(store: StoreOf<SearchResultReducer>) -> some View {
    toolbar {
      ToolbarItem(placement: .topBarLeading) {
        if #available(iOS 26.0, *) {
          Button(role: .cancel) {
            store.send(.close)
          }
        } else {
          Button(
            action: {
              store.send(.close)
            },
            label: {
              Image(systemSymbol: .xmark)
            },
          )
        }
      }
    }
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
