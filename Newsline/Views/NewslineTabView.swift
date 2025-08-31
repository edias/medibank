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

    let dependencies: FeatureDependencies

    var body: some View {
        
        TabView {

            HeadlinesFactory(dependencies.headlines).makeRootView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Headlines")
                }

            SourceSelectionFactory(dependencies.sourceSelection).makeRootView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Sources")
                }
        }
    }
}

#Preview {
    NewslineTabView(dependencies: FeatureDependencies())
}
