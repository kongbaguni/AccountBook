//
//  FirebaseStorageHelper.swift
//  firebaseTest
//
//  Created by Changyul Seo on 2020/03/04.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import AlamofireImage

class FirebaseStorageHelper {
    let storageRef = Storage.storage().reference()
    
    func uploadProfile(url:URL, complete:@escaping(_ largeURL:URL?, _ thumbURL:URL?)->Void) {
        uploadImage(url: url, uploadSize: Consts.PROFILE_LARGE_SIZE, contentType: "image/jpeg", uploadURL: "profileImages/\(loginedEmail).png") { (largeURL) in
            self.uploadImage(url: url, uploadSize: Consts.PROFILE_THUMB_SIZE, contentType: "image/jpeg", uploadURL: "profileImages/\(loginedEmail).png.thumb") { (thumbURL) in
                complete(largeURL, thumbURL)
            }
        }
        
    }
    
    func uploadImage(url:URL, uploadSize:CGSize, contentType:String, uploadURL:String, complete:@escaping(_ downloadURL:URL?)->Void) {
        guard var data = try? Data(contentsOf: url) else {
            complete(nil)
            return
        }
        if contentType == "image/jpeg" {
            if let image = UIImage(data: data) {
                if let newData = image.af.imageScaled(to: image.size.resize(target: uploadSize, isFit: true)).jpegData(compressionQuality: 0.7) {
                    data = newData
                }
            }
        }
        
        let ref:StorageReference = storageRef.child(uploadURL)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        let task = ref.putData(data, metadata: metadata)
        task.observe(.success) { (snapshot) in
                    let path = snapshot.reference.fullPath
                    print(path)
                    ref.downloadURL { (downloadUrl, err) in
                        if (downloadUrl != nil) {
                            print(downloadUrl?.absoluteString ?? "없다")
                        }
                        complete(downloadUrl)
                    }
                }
        task.observe(.failure) { (_) in
            complete(nil)
        }
    }

}
