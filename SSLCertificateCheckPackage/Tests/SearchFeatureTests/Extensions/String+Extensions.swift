//
//  String+Extensions.swift
//
//
//  Created by Yuya Oka on 2023/10/15.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { self }
}
