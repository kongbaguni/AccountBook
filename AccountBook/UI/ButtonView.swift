//
//  ButtonView.swift
//  AnyReview
//
//  Created by Changyul Seo on 2020/06/16.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI

struct ButtonView: View {
    let image:Image
    let title:Text
    let action:()->Void

    var body: some View {
        Button(action: action) {
            HStack {
                image.resizable().scaledToFit().padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    .frame(width: 40, height: 40, alignment: .center)
                title.fontWeight(.bold).padding(10)
            }
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.strockColor,lineWidth: 2))
            }.foregroundColor(.buttonStrockColor)
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.buttonBgColor))
            
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(image: Image("google"), title:Text("Sign in with GoogleID"), action:  {
            print("!!!")
        })
            .environment(\.locale, .init(identifier: "ko"))
        
    }

}
    
