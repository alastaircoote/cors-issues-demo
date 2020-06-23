//
//  ContentView.swift
//  cors-issues-demo
//
//  Created by Alastair Coote on 6/23/20.
//  Copyright © 2020 Alastair Coote. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SchemeCORSDemo(schemeToUse: "https")
                .tabItem {
                    Image(systemName: "safari")
                    Text("HTTPS")
            }
            SchemeCORSDemo(schemeToUse: "http")
                .tabItem {
                    Image(systemName: "safari")
                    Text("HTTP")
            }
            SchemeCORSDemo(schemeToUse: "custom-scheme")
                .tabItem {
                    Image(systemName: "safari")
                    Text("Custom")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
