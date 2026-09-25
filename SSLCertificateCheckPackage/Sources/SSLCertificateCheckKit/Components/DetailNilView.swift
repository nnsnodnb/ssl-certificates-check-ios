//
//  SwiftUIView.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/09/25.
//

import SwiftUI

public struct DetailNilView: View {
  // MARK: - Properties
  public var text: String = "Please select an item from sidebar."

  public var body: some View {
    Text(text)
      .font(.system(size: 20))
      .foregroundStyle(Color.gray)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .backgroundStyle(Color(UIColor.systemGroupedBackground))
  }
}


#Preview {
    DetailNilView()
}
