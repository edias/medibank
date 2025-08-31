//
//  ArticlesResponse.swift
//  Headlines
//
//  Created by Eduardo Dias on 31/08/2025.
//

import Foundation
import Storage

struct ArticlesResponse: Decodable {
    let articles: [Article]
}
