//
//  BluetoothSettingsView.swift
//  RecordingnARView
//
//  Created by cccc on 2024/3/20.
//

import SwiftUI

struct BluetoothSettingsView: View {
    @Environment(\.editMode) var editMode
    @State private var Name = ""
    @State private var Service = ""
    @State private var Characteristic = ""
    @AppStorage("Name") var savedName = Peripheral.default.peripheral_name
    @AppStorage("ServiceUUID") var savedService = Peripheral.default.serviceUUID
    @AppStorage("CharacteristicUUID") var savedCharacteristic = Peripheral.default.characteristicUUID
    
    //whether autoFocus
    @AppStorage("isAutoFocus") var isAutoFocus = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HStack {
                if editMode?.wrappedValue == .active {
                    Button("Cancel", role: .cancel) {
                        editMode?.animation().wrappedValue =
                            .inactive
                    }
                }
                Spacer()
                EditButton()
            }
            
            if editMode?.wrappedValue == .inactive {
                VStack(alignment: .leading, spacing: 10) {
                    Text("蓝牙名称: \(savedName)")
                    Text("service UUID: \(savedService)")
                    Text("characteristic UUID: \(savedCharacteristic)")
                }
            } else {

                List {
                    Toggle(isOn: $isAutoFocus) {
                        Text("isAutoFocusEnabled").bold()
                    }
                    
                    HStack {
                        Text("蓝牙名称").bold()
                        Divider()
                        TextField("蓝牙名称",text: $Name)
                            .onChange(of: Name) {
                                self.savedName = Name
                            }
                            .onAppear {
                                self.Name = savedName
                            }
                    }
                    
                    HStack {
                        Text("service UUID").bold()
                        Divider()
                        TextField("service UUID", text: $Service)
                            .onChange(of: Service) {
                                self.savedService = Service
                            }
                            .onAppear {
                                self.Service = savedService
                            }
                    }
                    HStack {
                        Text("characteristic UUID").bold()
                        Divider()
                        TextField("characteristic UUID", text: $Characteristic)
                            .onChange(of: Characteristic) {
                                self.savedCharacteristic = Characteristic
                            }
                            .onAppear {
                                self.Characteristic = savedCharacteristic
                            }
                    }
                }
            
            }
        }
        .padding()
    }
}

#Preview {
    BluetoothSettingsView()
}
