//
//  TodayNavigationView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/08.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI

struct TodayNavigationView: View {
    @State var isActive:Bool = false
    var body: some View {
        NavigationView {
            TagListView().navigationBarTitle("Tags")
               .navigationBarItems(trailing: NavigationLink(
                destination: MenuView(),
                isActive: $isActive,
                label: {
                   Image("menu")
               }))
        }
    }
}

struct TodayNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        TodayNavigationView()
    }
}
