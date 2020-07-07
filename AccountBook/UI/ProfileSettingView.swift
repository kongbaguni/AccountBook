//
//  ProfileSettingView.swift
//  AnyReview
//
//  Created by Changyul Seo on 2020/06/17.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import RealmSwift
import ImagePicker
struct ProfileSettingView: View {
    var info:UserInfoModel? { UserInfoModel.myInfo }
    @State var profileImageUrl:String? = "https://lh3.googleusercontent.com/proxy/xNFsYBeWxLwCcjg8Qhjjj8fV9nRrEXCR64dwc_sX-9CFa6_mMuaUMgFTIw0fBLJkAFmM8pRpK66sHOLPdIawGExYXJcLc3jAxJkDVTrLBRVrdfBARA"
    @State var name:String = ""
    @State var email:String = "email@email.com"
    var body: some View {
        ScrollView {
            HStack {
                ImageButton(imageUrl: profileImageUrl ?? "", placeHolderImage: Image("profile"), size: CGSize(width: 100, height: 100), text: "profileImage".localized, action: {
                    let picker = ImagePickerController { (asset) in
                                            
                    }
                    picker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                    UIApplication.shared.windows.last?.rootViewController?.present(picker, animated: true, completion: nil)
                })
                VStack {
                    RoundedTextField(title: "name".localized, text: $name)
                    RoundedTextField(title: "email".localized, text: $email).disabled(true)
                }
            }.padding(10)
        }.navigationBarTitle("profileSetting".localized)
    }
}

struct ProfileSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingView()
    }
}
