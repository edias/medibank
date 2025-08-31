//
//  String+Localization.swift
//  SourceSelection
//
//  Created by Eduardo Dias on 30/08/2025.
//

import Foundation

extension String {
    func localized(bundle: Bundle = .module, comment: String = "") -> String {
        NSLocalizedString(self, bundle: bundle, comment: comment)
    }
}
