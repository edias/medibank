//
//  NewslineTabView.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI

import Favorites
import Headlines
import SourceSelection

import CommonWeb
import Storage

struct NewslineTabView: View {

    @State
    private var article: Article?

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

            FavoritesFactory(dependencies.favorites).makeRootView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favorites")
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
