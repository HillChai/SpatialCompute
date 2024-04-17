//
//  RecordingButton.swift
//  RecordingnARView
//
//  Created by cccc on 2024/3/20.
//

import SwiftUI
import ARKit

struct RecordingButton: View {
    @Binding var isRecording: Bool
    
    let arViewModel = ARViewContainer.instanceForRecording
    
    var body: some View {
        Button {
            isRecording.toggle()
            if isRecording {
                arViewModel.startRecordingVideo()
            } else {
                arViewModel.stopRecordingVideo()
            }
        } label: {
            Image(systemName: isRecording ? "stop.circle.fill" : "play.circle.fill")
                .resizable()
                .foregroundStyle(.white)
                .frame(width: 55, height: 55)
        }
        
    }
    
}


//Continuous

#Preview {
    RecordingButton(isRecording: .constant(false))
        .background(Color.black)
}

