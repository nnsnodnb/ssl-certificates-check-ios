//
//  View+Extensions.swift
//  SSLCertificateCheckPackage
//
//  Created by Yuya Oka on 2026/09/20.
//

import SwiftUI

extension View {
  func modifier(@ViewBuilder _ closure: (Self) -> some View) -> some View {
    closure(self)
  }

  func navigationScrollEdgeEffectSoft() -> some View {
    modifier {
      if #available(iOS 26.0, *) {
        $0
          .scrollEdgeEffectStyle(.soft, for: .top)
      } else {
        $0
      }
    }
  }
}
