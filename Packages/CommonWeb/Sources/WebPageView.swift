//
//  WebPageView.swift
//  Newsline
//
//  Created by Eduardo Dias on 01/09/2025.
//

import Foundation
import SwiftUI

import Storage

struct WebPageView: View {

    let article: Article

    var body: some View {

        ZStack {

            WebView(url: URL(string: article.url)!)
                .edgesIgnoringSafeArea(.all)

            VStack {

                Spacer()

                HStack {
                    Spacer()
                    FavoriteButton(article: article)
                        .padding(.trailing, 15)
                }
            }
        }
    }
}



