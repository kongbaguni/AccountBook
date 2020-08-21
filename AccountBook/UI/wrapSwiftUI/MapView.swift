//
//  MapView.swift
//  AccountBook
//
//  Created by Changyul Seo on 2020/08/20.
//  Copyright © 2020 Changyul Seo. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    var location:CLLocation? = nil
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.isScrollEnabled = false
        view.isPitchEnabled = false
        view.isRotateEnabled = false
        view.isZoomEnabled = false
        view.showsUserLocation = location == nil

        let camera = MKMapCamera()
        camera.altitude = 1500
        camera.pitch = 45
        camera.heading = 45
        
        guard let coo = location?.coordinate  else {
            view.camera = camera
            return
        }

        camera.centerCoordinate = coo
        view.camera = camera


        for ann in view.annotations {
            view.removeAnnotation(ann)
        }
        let ann = MKPointAnnotation()
        ann.coordinate = coo
        view.addAnnotation(ann)
        
        
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}
