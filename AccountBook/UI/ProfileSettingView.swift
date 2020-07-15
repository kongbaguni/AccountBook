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
import Photos

struct ProfileSettingView: View {
    var info:UserInfoModel? { UserInfoModel.myInfo }
    @State var showingAlert:Bool = false
    @State var profileImageUrl:String? = UserInfoModel.myInfo?.profileImageURL?.absoluteString ?? ""
    @State var name:String = "홍길동"
    @State var email:String = "Hong@gil.dong"
    @State var isActive:Bool = false
    @State var selectImageURL:URL? = nil
    @State var isDeleteProfile:Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        ScrollView {
            HStack {
                ImageButton(imageUrl: selectImageURL?.absoluteString ?? profileImageUrl ?? "", placeHolderImage: Image("profile"), size: CGSize(width: 100, height: 100), text: Text("profileImage"), action: {
                    
                    let picker = ImagePickerController { (assets) in
                        if let asset:PHAsset = assets?.first{
                            print(asset)
                            asset.getURL { url in
                                self.selectImageURL = url
                            }
                        }
                    }
                    
                    picker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                    self.rootViewController?.present(picker, animated: true, completion: nil)
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
                func updateProfile(photoURL:URL?, thumbURL:URL?) {
                    UserInfoModel.myInfo?.updateUserInfo(name: self.name, profileImageURL: photoURL, profileImageThumbURL: thumbURL, isDeleteProfile: self.isDeleteProfile, complete: { (complete) in
                        self.presentationMode.wrappedValue.dismiss()

                    })
                }
                
                if let url = self.selectImageURL {
                    FirebaseStorageHelper().uploadProfile(url: url) { (large, thumb) in
                        updateProfile(photoURL: large, thumbURL: thumb)
                    }
                    
                } else {
                    updateProfile(photoURL: nil, thumbURL: nil)
                }
                
                
            }) {
                Text("save")
            })
            .alert(isPresented: $showingAlert) { () -> Alert in
                Alert(title: Text("alert"), message: Text("name is empty!"), dismissButton: .default(Text("confirm")))
        }
    }
    
    private func loadData() {
        profileImageUrl = UserInfoModel.myInfo?.profileImageURL?.absoluteString
        name = UserInfoModel.myInfo!.name
        email = UserInfoModel.myInfo!.email
    }
}

struct ProfileSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingView()
    }
}
