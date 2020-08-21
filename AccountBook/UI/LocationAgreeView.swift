//
//  LocationAgreeView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/20.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import SwiftUI
import CoreLocation

struct LocationAgreeView: View {
    @ObservedObject var locationManager:LocationManager = LocationManager()
    @State var opacity:Double = 0.0
    var body: some View {
        ZStack {
            TitleView()
            VStack {
                Text("Location Agree").font(.title).padding(30)
                Spacer()
            }
        }
        .opacity(opacity)
        .onReceive(NotificationCenter.default.publisher(for: .locationDidChangeAuthorization)) { (out) in
            switch out.object as? CLAuthorizationStatus {
            case .notDetermined:
                self.opacity = 1.0
                break
            default:
                TodayNavigationView().changeThisView()
            }
        }
        
    }
}

struct LocationAgreeView_Previews: PreviewProvider {
    static var previews: some View {
        LocationAgreeView()
    }
}
