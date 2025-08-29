//
//  ContentView.swift
//  Newsline
//
//  Created by Eduardo Dias on 30/08/2025.
//

import SwiftUI

struct NewslineTabView: View {
    
    var body: some View {
        TabView {
            Text("Headlines")
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("Headlines")
                }
        }
    }
}

#Preview {
    NewslineTabView()
}
