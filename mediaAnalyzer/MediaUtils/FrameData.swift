//
//  FrameData.swift
//  mediaAnalyzer
//
//  Created by HanGyo Jeong on 2020/09/30.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

import UIKit
import Foundation

class FrameData: NSObject {
    var frameIndex: NSInteger?
    var frameType: FrameType?
    var pixelBufferRef: UnsafeMutablePointer<Unmanaged<CVPixelBuffer>?>?
    
    init(_ pixelBufferRef: UnsafeMutablePointer<Unmanaged<CVPixelBuffer>?>?) {
        self.frameIndex = nil
        self.frameType = nil
        self.pixelBufferRef = pixelBufferRef
    }
    
    init(_ frameIndex: NSInteger?, _ frameType: FrameType?, _ pixelBufferRef: UnsafeMutablePointer<Unmanaged<CVPixelBuffer>?>?) {
        self.frameIndex = frameIndex
        self.frameType = frameType
        self.pixelBufferRef = pixelBufferRef
    }
}
