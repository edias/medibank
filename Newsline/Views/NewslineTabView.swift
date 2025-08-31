//
//  NewslineTabView.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI

import Headlines
import SourceSelection

struct NewslineTabView: View {

    @State private var url: URL?

    private var dependencies: FeatureDependencies {
        FeatureDependencies { selectedURL in
            url = selectedURL
        }
    }

    var body: some View {
        
        TabView {

            HeadlinesFactory(dependencies.headlines).makeRootView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Headlines")
                }

            SourceSelectionFactory(dependencies.sourceSelection).makeRootView()
                .tabItem {
                    Image(systemName: "globe")
                    Text("Sources")
                }

        }.sheet(item: $url) { url in
            WebPageView(url: url)
        }
    }
}

#Preview {
    NewslineTabView()
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
