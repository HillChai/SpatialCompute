//
//  Peripheral.swift
//  RecordingnARView
//
//  Created by cccc on 2024/3/20.
//

import Foundation

struct Peripheral: Codable, Hashable{
    var peripheral_name: String
    var serviceUUID: String
    var characteristicUUID: String
    
    static let `default` = Peripheral(peripheral_name: "BT04-E", serviceUUID: "FFE0", characteristicUUID: "FFE1")
}
