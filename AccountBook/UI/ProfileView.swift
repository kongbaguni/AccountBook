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
    @State var profileURL:String = profile?.profileImageURL?.absoluteString ?? " "

    var body: some View {
        HStack {
            NetImageView(imageUrl: profileURL, placeHolder: Image("profile"), size: CGSize(width: 100, height: 100))
            VStack {
                HStack {
                    Text(name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                HStack {
                    Text(profile?.email ?? "hong@gil.dong")
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            }.onReceive(NotificationCenter.default.publisher(for: .profileUpdatedNotification)) { (obj) in
                self.update()
            }.onAppear {
                self.update()
            }
        }
    }
    
    private func update() {
        name = profile?.name ?? "홍길동"
        profileURL = profile?.profileImageURL?.absoluteString ?? " "
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
