//
//  RoundedTextField.swift
//  AnyReview
//
//  Created by Changyul Seo on 2020/06/17.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI

struct RoundedTextField: View {
    let title:String
    let text:Binding<String>
    let keyboardType:UIKeyboardType
    let onEditingChanged: (Bool) -> Void
    let onCommit: () -> Void
    
    var body: some View {
        TextField(self.title, text: text, onEditingChanged: onEditingChanged, onCommit: onCommit )
        
            .keyboardType(keyboardType)
            .foregroundColor(.textFieldTextColor)
            .padding(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.strockColor, lineWidth: 1))
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.textFieldBgColor))
    
        
    }
}

struct RoundedTextField_Previews: PreviewProvider {
    @State var name_preview:String = "홍길동"
    static var previews: some View {
        Preview()
    }
    struct Preview : View {
        @State var name_preview = "홍길동"
        var body: some View {
            RoundedTextField(title: "test", text: $name_preview, keyboardType: .default, onEditingChanged: {_ in }, onCommit: { })
        }
    }
}
