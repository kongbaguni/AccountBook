//
//  TodayNavigationView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/08.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import HorizonCalendar
struct TodayNavigationView: View {
    @State var isActive:Bool = false
    var body: some View {
        NavigationView {
            TagListView()
                .navigationBarTitle(LocalizedStringKey("Today"))
                .navigationBarItems(trailing:
                    NavigationLink(
                        destination: MenuView(),
                        isActive: $isActive,
                        label: {
                            Image("menu")
                    })
                    
            )
        }
        
    }
}

struct TodayNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["en", "kr"], id: \.self) { id in
            TodayNavigationView()
                .environment(\.locale, .init(identifier: id))
        }
    }
}
