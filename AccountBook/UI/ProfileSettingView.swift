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
    @State var showingAlert:Bool = false
    @State var profileImageUrl:String? = UserInfoModel.myInfo?.profileImageURL?.absoluteString ?? ""
    @State var name:String = "홍길동"
    @State var email:String = "Hong@gil.dong"
    @State var isActive:Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        ScrollView {
            HStack {
                ImageButton(imageUrl: profileImageUrl ?? "", placeHolderImage: Image("profile"), size: CGSize(width: 100, height: 100), text: "profileImage", action: {
                    let picker = ImagePickerController { (asset) in
                                            
                    }
                    picker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                    UIApplication.shared.windows.last?.rootViewController?.present(picker, animated: true, completion: nil)
                })
                VStack {
                    RoundedTextField(title: "name", text: $name)
                    HStack {
                        Text(email)
                        Spacer()
                    }
                }
            }.padding(10)
                .onAppear {
                    self.loadData()
            }.onReceive(NotificationCenter.default.publisher(for: .profileUpdatedNotification)) { obj in
                self.loadData()
            }
        }.navigationBarTitle("profileSetting")
            .navigationBarItems(trailing: Button(action: {
                if self.name.isEmpty {
                    self.showingAlert = true
                    return
                }
                UserInfoModel.myInfo?.updateUserInfo(name: self.name, uploadProfileImageURL: nil, isDeleteProfile: false, complete: { (complete) in
                    self.presentationMode.wrappedValue.dismiss()
                })
            }) {
                Text("save")
            })
            .alert(isPresented: $showingAlert) { () -> Alert in
                Alert(title: Text("alert"), message: Text("name is empty!"), dismissButton: .default(Text("confirm")))
        }
    }
    
    private func loadData() {
        name = UserInfoModel.myInfo!.name
        email = UserInfoModel.myInfo!.email
    }
}

struct ProfileSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingView()
    }
}
