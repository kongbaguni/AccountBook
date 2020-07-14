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
    @State var name:String = "홍길동"
    var body: some View {
        HStack {
            NetImageView(imageUrl: profile?.profileImageURL?.absoluteString ?? " " , placeHolder: Image("profile"), size: CGSize(width: 100, height: 100))
            VStack {
                Text(name)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    
                Text(profile?.email ?? "hong@gil.dong")
                    .multilineTextAlignment(.leading)
            }.onReceive(NotificationCenter.default.publisher(for: .profileUpdatedNotification)) { (obj) in
                self.name = UserInfoModel.myInfo!.name
            }.onAppear {
                self.name = UserInfoModel.myInfo!.name
            }
            
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
