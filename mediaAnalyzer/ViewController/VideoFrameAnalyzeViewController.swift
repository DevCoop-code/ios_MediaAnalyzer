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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        demuxerWrapper = FFMpegDemuxerWrapper()
        
        if let analyzeMedia = mediaPath {
            NSLog("media which analyzed: \(analyzeMedia)")
            
            guard let result = demuxerWrapper?.initFFMpegConfig(withPath: analyzeMedia), result < 0 else {
                NSLog("Failed to initialize the ffmpeg")
                return
            }
        }
    }


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

