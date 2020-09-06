//
//  MetalViewController.swift
//  mediaAnalyzer
//
//  Created by HanGyo Jeong on 2020/08/02.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

import Foundation
import UIKit
import MetalKit
import AVFoundation

protocol MetalViewControllerDelegate {
    func updateLogic(timeSinceLasttUpdate: CFTimeInterval)
    func renderObject(drawable: CAMetalDrawable, pixelBuffer:CVPixelBuffer)
}

enum mediaType {
    case local
    case hls
    case dash
}

class DrawVideoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
