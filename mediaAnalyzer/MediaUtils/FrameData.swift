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
    
    init(_ frameIndex: NSInteger?, _ frameType: FrameType?) {
        self.frameIndex = frameIndex
        self.frameType = frameType
    }
}
