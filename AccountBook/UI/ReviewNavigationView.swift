//
//  ReviewNavigationView.swift
//  AnyReview
//
//  Created by Changyul Seo on 2020/06/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI

struct ReviewNavigationView: View {
    @State var isActive = false
    var body: some View {
        NavigationView {
            NavigationLink(destination:
                ProfileSettingView(), isActive: $isActive) {
                    Text("review".localized)
            }
            VStack {
                Text("test")
            }
        }.navigationBarTitle("Reviews".localized)
    }
}

struct ReviewNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewNavigationView()
    }
}
