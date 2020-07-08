//
//  ProfileView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/08.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
fileprivate var profile:UserInfoModel? {
    return UserInfoModel.myInfo
}

struct ProfileView: View {
    var body: some View {
        HStack {
            NetImageView(imageUrl: profile?.profileImageURL?.absoluteString ?? " " , placeHolder: Image("profile"), size: CGSize(width: 100, height: 100))
            VStack {
                Text(profile?.name ?? "홍길동")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    
                Text(profile?.email ?? "hong@gil.dong")
                    .multilineTextAlignment(.leading)
            }
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
