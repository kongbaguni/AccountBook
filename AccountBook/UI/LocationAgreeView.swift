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
    
    var body: some View {
        VStack {
            Text("Location Agree").padding(30)
            Spacer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .locationDidChangeAuthorization)) { (out) in
            switch out.object as? CLAuthorizationStatus {
            case .notDetermined:
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
