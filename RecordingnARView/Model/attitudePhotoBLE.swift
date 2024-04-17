//
//  attitudePhotoBLE.swift
//  RecordingnARView
//
//  Created by cccc on 2024/3/20.
//

import Foundation

struct attitudesPhotosBLE: Identifiable, Codable {
    let id: String
    let position: [Float]
    let eulerAngle: [Float]
    let BLEmessage: String
}
