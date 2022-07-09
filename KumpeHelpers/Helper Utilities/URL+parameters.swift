//
//  URL+parameters.swift
//  KumpeHelpers
//
//  Created by Justin Kumpe on 1/10/21.
//

import Foundation

public extension URL {
    var parameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
