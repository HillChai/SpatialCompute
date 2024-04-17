//
//  Writer.swift
//  RecordingnARView
//
//  Created by cccc on 2024/3/20.
//

import Foundation
import ARKit

// 1. Check whether the folder exitst
func createFolderIfNeeded(fileFolder folderName: String) {
    guard
        let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(folderName)
            .path else { return }
    
    //Check whether the target folder exists.
    if !FileManager.default.fileExists(atPath: path) {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            print("Success creating folder.")
        } catch let error {
            print("Error creating folder. \(error)")
        }
    }
    
    print("Folder Created!")
}

// 2. Get the path to save photos
func getPathForImage(folderName: String, name: String) -> URL? {
//        createFolderIfNeeded(fileFolder: folderName)
    
    guard
        let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(folderName)
            .appendingPathComponent("\(name).jpg") else {
        print("Error getting image path.")
        return nil
    }
    
//        print("Image path exists!")
    return path
}


func getPathForJson(folderName: String, name: String) -> URL? {
    
    guard
        let path = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(folderName)
            .appendingPathComponent("\(name).json") else {
        print("Error getting json path.")
        return nil
    }
    
    print("Json path created!")
    return path
}

func getFolderName() -> String {
    let date = Date()
    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    let second = calendar.component(.second, from: date)
    return String(day)+"-"+String(hour)+"-"+String(minutes)+"-"+String(second)
}

func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
    return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
}
