//
//  NetImageView.swift
//  AnyReview
//
//  Created by Changyul Seo on 2020/06/17.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI

struct NetImageView: View {
    let imageUrl:String
    let placeHolder:Image
    let size:CGSize
    var profileImage:Image {
        if let imgurl = URL(string: imageUrl) {
            do {
                let data = try Data(contentsOf: imgurl)
                if let img = UIImage(data: data) {
                    return Image(uiImage: img)
                }
            }
            catch {
                return placeHolder
            }
        }
        return placeHolder
    }
    
    var body: some View {
        profileImage
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct NetImageView_Previews: PreviewProvider {
    static var previews: some View {
        Preview_view()
    }
    
    struct Preview_view : View{
        var body: some View {
            NetImageView(imageUrl: "https://lh3.googleusercontent.com/proxy/nuN98L8MagAO-kRZqckKBjezm8uAGiftvFeYHihXRQ1I1ZC_4a9-p7GblMSbjiLxjNatsDtL7yEQkyTrKrK2cWsblqYDhwCgblhnFt0sQUGh7w2u4w", placeHolder: Image("profile"), size: CGSize(width: 100, height: 100))
        }
    }
}
