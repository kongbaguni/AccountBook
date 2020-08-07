//
//  LogoView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/07/14.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI

struct LogoView: View {
    @State private var animationAmount: Double = 3.14

    var body: some View {
        Image("book")
        .resizable()
        .frame(width: 100, height: 100, alignment: .center)
        .rotation3DEffect(Angle(degrees: animationAmount), axis: (x: 10, y:5, z: 10))
        .animation(
            Animation.easeInOut(duration: 0.25)
                .repeatForever(autoreverses: true)
        ).onAppear {
            self.animationAmount = 5 * 3.14
        }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
