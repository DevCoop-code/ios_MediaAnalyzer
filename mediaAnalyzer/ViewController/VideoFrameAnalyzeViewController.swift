//
//  ViewController.swift
//  mediaAnalyzer
//
//  Created by HanGyo Jeong on 2020/08/02.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

import UIKit
import MetalKit
import Metal



class VideoFrameAnalyzeViewController: DrawVideoViewController {

    // UI Components
    @IBOutlet weak var videoPreview: UIView!
    
    // property
    var device: MTLDevice?
    var metalLayer: CAMetalLayer?
    var pipelineState: MTLRenderPipelineState?
    var commandQueue: MTLCommandQueue?
    
    var mediaPath: String?
    
    var demuxerWrapper: FFMpegDemuxerWrapper?
    var videoToolboxDecoder: VideoToolboxDecoder?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        demuxerWrapper = FFMpegDemuxerWrapper()
        videoToolboxDecoder = VideoToolboxDecoder();
        
        if let analyzeMedia = mediaPath {
            NSLog("media which analyzed: \(analyzeMedia)")
            
            guard let result = demuxerWrapper?.initFFMpegConfig(withPath: analyzeMedia), result == 0 else {
                NSLog("Failed to initialize the ffmpeg")
                return
            }
            
            if let demuxer = demuxerWrapper {
                guard let result = videoToolboxDecoder?.initWithExtradata(demuxer), result == 0 else {
                    NSLog("Failed to initialize the videoToolboxDecoder");
                    return
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global().async {
            self.runVideoToolboxDecoder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // TODO: Close the Decoder
    }
    
    func runVideoToolboxDecoder() -> Int {
//        while (true) {
//            var pixelBufferRef: CVPixelBuffer
//
//        }
        return 0
    }
    
    // MARK: button action
    @IBAction func playTheContent(_ sender: Any) {
        NSLog("play")
    }
    
    @IBAction func showNextVideoFrame(_ sender: Any) {
        NSLog("next")
    }
    
    @IBAction func showPreviousVideoFrame(_ sender: Any) {
        NSLog("previous")
    }
}

