//
//  WebPageView.swift
//  Newsline
//
//  Created by Eduardo Dias on 01/09/2025.
//

import Foundation
import SwiftUI
import WebKit

struct WebPageView: View {

    let url: URL

    var body: some View {

        ZStack {

            WebView(url: url)
                .edgesIgnoringSafeArea(.all)

            VStack {

                Spacer()

                HStack {
                    Spacer()
                    FavoriteButton(url: url)
                        .padding(.trailing, 15)
                }
            }
        }
    }
}
