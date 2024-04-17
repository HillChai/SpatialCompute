//
//  ARViewContainer.swift
//  RecordingnARView
//
//  Created by cccc on 2024/3/20.
//

import SwiftUI

struct ARViewContainer {
    static var instanceForRecording = CustomARViewModel()
}

struct RecordingContainer: UIViewRepresentable {
    
    static var instance = RecordingContainer()
    
    func makeUIView(context: Context) -> some UIView {
        let arView = ARViewContainer.instanceForRecording
//        arView.debugOptions = .showStatistics
        /*[.showFeaturePoints] */  //Product -> Scheme -> Edit Scheme -> Run -> Diagnostic -> Metal
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
}
