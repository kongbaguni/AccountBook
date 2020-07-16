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

fileprivate var info:UserInfoModel? { UserInfoModel.myInfo }

struct ProfileSettingView: View {
    
    
  
    @State var showingAlert:Bool = false
    @State var showingImagePic:Bool = false
    @State var profileImageUrl:String? = UserInfoModel.myInfo?.profileImageURL?.absoluteString
    @State var name:String = "홍길동"
    @State var email:String = "Hong@gil.dong"
    @State var isActive:Bool = false
    @State var selectImageURL:URL? = nil
    @State var isDeleteProfile:Bool = false {
        didSet {
            if isDeleteProfile {
                profileImageUrl = nil
            }
        }
    }
    @State var isSetGoogleProfile:Bool = false {
        didSet {
            if isSetGoogleProfile {
                profileImageUrl = info?.profileImageURLgoogle
            }
        }
    }
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        ScrollView {
            HStack {
                ImageButton(imageUrl: selectImageURL?.absoluteString ?? profileImageUrl ?? "", placeHolderImage: Image("profile"), size: CGSize(width: 100, height: 100), text: Text("profileImage"), action: {
                    self.showingImagePic = true
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
                    info?.updateUserInfo(name: self.name, profileImageURL: photoURL, profileImageThumbURL: thumbURL, isSetDefaultProfile: self.isDeleteProfile, isSetGoogleProfile: self.isSetGoogleProfile, complete: { (complete) in
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
        .actionSheet(isPresented: $showingImagePic, content: { () -> ActionSheet in
            var buttons:[ActionSheet.Button] = [
                .default(Text("pic profile image"), action: {
                    let picker = ImagePickerController { (assets) in
                        if let asset:PHAsset = assets?.first{
                            print(asset)
                            asset.getURL { url in
                                self.isDeleteProfile = false
                                self.isSetGoogleProfile = false
                                self.selectImageURL = url
                            }
                        }
                    }
                    
                    picker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                    self.rootViewController?.present(picker, animated: true, completion: nil)
                }),
                .cancel()
            ]
            if info?.profileImageURLgoogle.isEmpty == false && info?.profileImageURLgoogle != self.profileImageUrl {
                buttons.append(.default(Text("set Google Profile image"), action: {
                    self.selectImageURL = nil
                    self.isDeleteProfile = false
                    self.isSetGoogleProfile = true
                }))
            }
            if self.isDeleteProfile != true {
                buttons.append(.default(Text("delete profile image"), action: {
                    self.selectImageURL = nil
                    self.isDeleteProfile = true
                    self.isSetGoogleProfile = false
                }))
            }
            return ActionSheet(title: Text("change profile image"), message: nil, buttons: buttons)
        })
   
    }
    
    private func loadData() {
        profileImageUrl = info?.profileImageURL?.absoluteString
        if profileImageUrl == nil {
            self.isDeleteProfile = true
        }
        name = info!.name
        email = info!.email
    }
}

struct ProfileSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingView()
    }
}
