//
//  TitleView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/08.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI

struct TitleView: View {
    var body: some View {
        VStack {
            Image("book")
                .frame(width: 150, height: 150, alignment: .center)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.strockColor,lineWidth: 10))
                .shadow(color: .shadowColor, radius: 10, x: 0, y: 0)
                .padding(20)
            Text("AppTitle")
                .font(.title)
                .fontWeight(.bold)
        }
        
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["en", "ko_kr"], id: \.self) { id in
            TitleView()
                .environment(\.locale, .init(identifier: id))
        }
        
    }
}
