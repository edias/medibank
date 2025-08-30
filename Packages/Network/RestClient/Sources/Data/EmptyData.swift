//
//  EmptyData.swift
//  Newsline
//
//  Created by Eduardo Dias on 29/08/2025.
//

import Foundation

struct EmptyData: Codable, Equatable {}

extension EmptyData {
    var data: Data {
        // swiftlint:disable:next force_try
        try! JSONEncoder().encode(self)
    }
}
