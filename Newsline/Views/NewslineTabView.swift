//
//  NewslineTabView.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI
import SourceSelection

struct NewslineTabView: View {

    let dependencies: FeatureDependencies

    var body: some View {
        
        TabView {

            SourceSelectionFactory(dependencies.sourceSelection).makeRootView()
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Headlines")
                }
        }
    }
}

#Preview {
    NewslineTabView(dependencies: FeatureDependencies())
}
