//
//  StreamingView.swift
//  RecordingnARView
//
//  Created by cccc on 2024/3/20.
//

import SwiftUI

struct StreamingView: View {
    
    @State var showAlert: Bool = false
    //BLE Settings
    @State var isPresent: Bool = false
    //play or stop button
    @State var isRecording: Bool = false
    
    //ARView
    let customARView = ARViewContainer.instanceForRecording
    
    //whether autoFocus
    @AppStorage("isAutoFocus") var isAutoFocus = true
    
    var body: some View {
        ZStack  {
            
            RecordingContainer.instance
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    
                    Image(systemName: "gearshape")
                        .resizable()
                        .foregroundStyle(Color.white)
                        .frame(width: 35, height: 35)
                        .padding()
                        .sheet(isPresented: $isPresent, content: {
                            BluetoothSettingsView()
                        })
                        .onTapGesture(perform: {
                            isPresent.toggle()
                        })
                
                    Spacer()
                    
                    Button {
                        isRecording = false
                        customARView.StartSession() {
                            customARView.GetWidthAndHeight()
                        }
                        showAlert.toggle()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .resizable()
                            .foregroundStyle(.white)
                            .frame(width: 35, height: 35)
                    }
                    .padding()
                    .alert(isPresented: $showAlert) {
                        return Alert(title: 
                                         isAutoFocus ?
                                     Text("请横屏拍摄以获得更好体验🚀,当前为自动对焦") :
                                        Text("请横屏拍摄以获得更好体验🚀,当前为固定焦距"))
                    }
                }
                
                Spacer()
                
                Text(customARView.sessionInfolLabel)
                    .background(Color.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                RecordingButton(isRecording: $isRecording)
                    .padding()
                
            }
        }
    }
    
}

#Preview {
    StreamingView()
}
