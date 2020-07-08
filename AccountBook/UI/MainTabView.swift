//
//  MainTabView.swift
//  AnyReview
//
//  Created by Changyul Seo on 2020/06/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI

struct MainTabView: View {
    @State var selection:Int = 0
    var body: some View {        
        TabView(selection: $selection) {
            TodayNavigationView().tabItem {
                Text("today")
            }.tag(1)
            Text("Tab Content 2").tabItem {
                Text("Tab Label 2")
            }.tag(2)
        }.navigationBarTitle("\(selection)")
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
