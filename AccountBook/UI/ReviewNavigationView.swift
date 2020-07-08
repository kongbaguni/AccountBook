//
//  ReviewNavigationView.swift
//  AnyReview
//
//  Created by Changyul Seo on 2020/06/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift

struct ReviewNavigationView: View {
    @State var isActive = false
    var body: some View {
        NavigationView {
            TagListView().navigationBarTitle("Tags")
                .navigationBarItems(
                trailing:Button(action: {
                    TagModel.createTag(title: "test\(Int.random(in: 0...100))", isCreatePublic: true) { (isSucess) in
                        
                    }
                }) {
                    Text("make tag")
                }
            )
                
            
        }
    }
}

struct ReviewNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewNavigationView()
    }
}
