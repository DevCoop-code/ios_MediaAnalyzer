//
//  VideoToolboxDecoder.swift
//  mediaAnalyzer
//
//  Created by HanGyo Jeong on 2020/08/02.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

import Foundation
import CoreVideo
import CoreFoundation
import VideoToolbox


class VideoToolboxDecoder: NSObject {
    var formatDescriptor: CMVideoFormatDescription?
    var decompressSession: VTDecompressionSession?
    var demuxerWrapper: FFMpegDemuxerWrapper?
    
    override init() {
        super.init()
    }
}
