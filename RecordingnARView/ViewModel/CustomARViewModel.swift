//
//  CustomARViewModel.swift
//  RecordingnARView
//
//  Created by cccc on 2024/3/20.
//

import Foundation
import ARKit
import RealityKit
import SwiftUI
//import Combine

class CustomARViewModel: ARView, ARSessionDelegate, ObservableObject {
    
    @Published var sessionInfolLabel: String = ""
    
    //savePath
    @Published var recordingTime: String  = ""
    
    var startTime: CMTime = CMTime.zero
    var assetWriter: AVAssetWriter?
    var videoInput: AVAssetWriterInput?
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    var videoWidth: Int32?
    var videoHeight: Int32?
    
    //attitudes, photos, BLE
    var jsonObject: [attitudesPhotosBLE] = []
    let BLE = BlueToothViewModel.instance
    
    // Video compressor/decompressor.
    var isRecording: Bool = false
    
    //whether autoFocus
    @AppStorage("isAutoFocus") var isAutoFocus = true
    
    func StartSession(completionHandler: @escaping () -> Void) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isAutoFocusEnabled = isAutoFocus
        session.delegate = self
        session.run(configuration)
        completionHandler()
    }
    
    func GetWidthAndHeight() {
        guard let frame = session.currentFrame else {return}
        let frameWidth = Float(CVPixelBufferGetWidth(frame.capturedImage))
        let frameHeight = Float(CVPixelBufferGetHeight(frame.capturedImage))
        
        
        var width = Int32(frameWidth)
        var height = Int32(frameHeight)
        
        // Make sure that the videoWidth and videoHeight are even values.
        if !width.isMultiple(of: 2) {width += 1}
        if !height.isMultiple(of: 2) {height += 1}
        
        videoWidth = width
        videoHeight = height
        print("\(String(describing: videoWidth)), \(String(describing: videoHeight))")
    }
    
    func SaveAttitudes(currentframe: ARFrame) {
        let currentTime = String(format: "%f", currentframe.timestamp)
        let arCamera = currentframe.camera
        let positions = positionFromTransform(arCamera.transform)
        let eulerAngles = arCamera.eulerAngles
        let BLEmessages = BLE.completemessage
        let frameData = attitudesPhotosBLE(id: currentTime, position: [positions.x, positions.y, positions.z], eulerAngle: [eulerAngles.x, eulerAngles.y, eulerAngles.z], BLEmessage: BLEmessages)
        
        jsonObject.append(frameData)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        if isRecording {
            let scale = CMTimeScale(NSEC_PER_SEC)
            guard let pixelBufferAdaptor else {
                print("Wrong with pixelBufferAdaptor's initialization...")
                return
            }
            if (self.videoInput?.isReadyForMoreMediaData)! && frame.camera.trackingState == .normal {
                if startTime == CMTime.zero {
                    startTime = CMTime(value: CMTimeValue((frame.timestamp)*Double(scale)), timescale: scale)
                }
                let tempTime = CMTime(value: CMTimeValue((frame.timestamp) * Double(scale)), timescale: scale)
                
                pixelBufferAdaptor.append(frame.capturedImage, withPresentationTime: tempTime - startTime)
                self.SaveAttitudes(currentframe: frame)
            }
            
        }
        
    }
 
}

// Mark: Private Method
extension CustomARViewModel {
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String

        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal and vertical surfaces."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""

        }

        sessionInfolLabel = message
    }
    
}

// Mark: Video Recording

extension CustomARViewModel {
    
    func startRecordingVideo() {
        
        recordingTime = getFolderName()
        createFolderIfNeeded(fileFolder: recordingTime)
        
        createURLForVideo(withName: recordingTime) { (videoURL) in
            guard let videoWidth = self.videoWidth,
                  let videoHeight = self.videoHeight
            else {return}
            self.prepareWriterAndInput(width: videoWidth, height: videoHeight,
                                       videoURL: videoURL) { (error) in
                guard error == nil else { return }
            }
        }
        
        isRecording = true
        
    }
    
    func createURLForVideo(withName:String, completionHandler:@escaping (URL)->()) {
        guard
            let path = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(recordingTime)
                .appendingPathComponent("\(withName).mp4") else {
            print("Error getting image path.")
            return
        }
        
        // return the URL
        completionHandler(path);
    }
    
    func prepareWriterAndInput(width: Int32, height: Int32, videoURL:URL, completionHandler: @escaping(Error?) -> ()) {
        do {
            
            self.assetWriter = try AVAssetWriter(outputURL: videoURL, fileType: AVFileType.mp4)
            
            let videoOutputSettings: Dictionary<String, Any> = [
                AVVideoCodecKey : AVVideoCodecType.h264,
                AVVideoWidthKey : width,
                AVVideoHeightKey : height
            ]
            
            self.videoInput = AVAssetWriterInput (mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
            self.videoInput!.expectsMediaDataInRealTime = true
            self.assetWriter!.add(self.videoInput!)
            
            // Create Pixel buffer Adaptor
            
            let sourceBufferAttributes: [String : Any] = [
                (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ABGR),
                (kCVPixelBufferWidthKey as String) : Float(width),
                (kCVPixelBufferHeightKey as String) : Float(height)] as [String : Any]
            
            self.pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.videoInput!, sourcePixelBufferAttributes: sourceBufferAttributes)
            
            self.assetWriter?.startWriting()
            self.assetWriter?.startSession(atSourceTime: CMTime.zero)
            completionHandler(nil)
            
        } catch {
            print("Failed to create assetWritter with error : \(error)");
            completionHandler(error);
        }
    }
    
    
    func finishVideoRecordingAndSave() {
        guard let videoInput = self.videoInput else {return}
        videoInput.markAsFinished()
        self.assetWriter?.finishWriting {
            print("output url : \(String(describing: self.assetWriter?.outputURL))")
            
            print("Your video was successfully saved")
            
            // Clear memory
            
        }
    }
    
    func stopRecordingVideo() {
        
        isRecording = false
        startTime = CMTime.zero
        
        self.finishVideoRecordingAndSave()
        
        if recordingTime != "" {
            guard let path = getPathForJson(folderName: recordingTime, name: recordingTime) else { return }
            do {
                let bigData = try? JSONEncoder().encode(jsonObject)
                try bigData?.write(to: path, options: [.atomic])
                print("Json finished")
                jsonObject.removeAll()
            } catch let error {
                print("Errors: \(error)")
            }
        }
        
    }
    
}
