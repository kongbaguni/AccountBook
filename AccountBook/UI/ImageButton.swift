//
//  ImageButton.swift
//  AnyReview
//
//  Created by Changyul Seo on 2020/06/17.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import SwURL

struct ImageButton: View {
    let imageUrl:String
    let placeHolderImage:Image
    let size:CGSize
    let text:String
    let action:()->Void

    var body: some View {
        VStack {
            Button(action: action) {
                Text(text).foregroundColor(.buttonStrockColor)
            }.background(
                NetImageView(imageUrl: imageUrl, placeHolder: placeHolderImage.renderingMode(.original), size: size)
                    .overlay(RoundedRectangle(cornerRadius: 10).foregroundColor(.imageButtonOveray))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.buttonStrockColor,lineWidth: 1))
            ).frame(width: size.width, height: size.height, alignment: .center)
                
        }
        
    }
}

struct ImageButton_Previews: PreviewProvider {
    static var previews: some View {
        PreviewBtnView()
    }
    
    struct PreviewBtnView : View {
        var body : some View {
            VStack {
                ImageButton(imageUrl:  "https://lh3.googleusercontent.com/proxy/xNFsYBeWxLwCcjg8Qhjjj8fV9nRrEXCR64dwc_sX-9CFa6_mMuaUMgFTIw0fBLJkAFmM8pRpK66sHOLPdIawGExYXJcLc3jAxJkDVTrLBRVrdfBARA", placeHolderImage: Image("profile"), size: CGSize(width: 100, height: 100), text: "profile") {
                    
                }
            }

        }
    }
}
