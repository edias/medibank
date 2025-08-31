//
//  NewslineTabView.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI

import CommonWeb
import Headlines
import SourceSelection

import Storage

struct NewslineTabView: View {

    @State private var article: Article?

    private var dependencies: FeatureDependencies {
        FeatureDependencies { selectedArticle in
            article = selectedArticle
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

        }.sheet(item: $article) { article in
            CommonWebFactory(dependencies.commonWeb).makeRootView(article: article)
        }
    }
}

#Preview {
    NewslineTabView()
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
