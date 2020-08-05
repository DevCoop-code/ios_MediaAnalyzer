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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

