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
import MobileCoreServices

var ONE_FRAME_DURATION: Double {
    get {
        0.03
    }
}

protocol MetalViewControllerDelegate {
    func updateLogic(timeSinceLasttUpdate: CFTimeInterval)
    func renderObject(drawable: CAMetalDrawable, pixelBuffer:CVPixelBuffer)
}

enum mediaType {
    case local
    case hls
    case dash
}

//private var playerItemObserverList: [NSKeyValueObservation] = []
// Key-value observing context
private var playerItemContext = 0

class DrawVideoViewController: UIViewController, AVPlayerItemOutputPullDelegate {
    
    var device: MTLDevice?
    var metalLayer: CAMetalLayer?
    var pipelineState: MTLRenderPipelineState?
    var commandQueue: MTLCommandQueue?
    var metalVideoPreview: UIView?
    
    var metalViewControllerDelegate: MetalViewControllerDelegate?
    
    var avPlayer: AVPlayer?
    var videoOutput: AVPlayerItemVideoOutput?
    var m_type: mediaType?
    var currentPlayingTime: CMTime?
    var totalPlayTime: CMTime?
    
    var videoOutputQueue: DispatchQueue?
    var timer: CADisplayLink?
    var lastFrameTimestamp: CFTimeInterval?
    
    var mediaContentPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initProperties()
        
        avPlayer = AVPlayer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        m_type = .local
        
        // STUDY: KVO
        videoOutput?.addObserver(self,
                                 forKeyPath: #keyPath(AVPlayerItem.status),
                                 options: [.old, .new],
                                 context: &playerItemContext)
        
        var mediaURL: NSURL?
        if let mediaURI = mediaContentPath, let player = avPlayer, let videoItem = videoOutput {
            NSLog("Media Content URI: %@", mediaURI)
            player.pause()
            
            switch m_type {
            case .local:
                mediaURL = NSURL.fileURL(withPath: mediaURI) as NSURL
                break;
            case .hls:
                
                break
            case .dash:
                mediaURL = NSURL.init(fileURLWithPath: mediaURI)
                break;
            default:
                break;
            }
            
            player.currentItem?.remove(videoItem)
            
            if let mediaPath = mediaURL {
                let item = AVPlayerItem.init(url: mediaPath as URL)
                let asset = item.asset
                
                asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
                    var error: NSError? = nil
                    let status = asset.statusOfValue(forKey: "tracks", error: &error)
                    switch status {
                    case .loaded:
                        DispatchQueue.main.async {
                            item.add(videoItem)
                            player.replaceCurrentItem(with: item)
                            videoItem.requestNotificationOfMediaDataChange(withAdvanceInterval: ONE_FRAME_DURATION)
                            player.play()
                            
                            self.totalPlayTime = player.currentItem?.duration
                        }
                        break;
                    default:
                        NSLog("player Status is not loaded")
                        break;
                    }
                }
            }
        }
    }
    
    func initProperties() {
        lastFrameTimestamp = 0.0
        
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        
        if let metal_device = device, let metal_layer = metalLayer, let metal_VideoPreview = metalVideoPreview {
            metal_layer.device = metal_device
            metal_layer.pixelFormat = .bgra8Unorm
            metal_layer.framebufferOnly = true
            metal_layer.frame = metal_VideoPreview.layer.frame
            metal_VideoPreview.layer.addSublayer(metal_layer)
            
            let defaultLibrary = metal_device.makeDefaultLibrary()
            let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
            let fragmentProgram = defaultLibrary?.makeFunction(name: "basic_fragment")
            
            let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
            pipelineStateDescriptor.vertexFunction = vertexProgram
            pipelineStateDescriptor.fragmentFunction = fragmentProgram
            pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            pipelineState = try! metal_device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            
            commandQueue = metal_device.makeCommandQueue()
        }
        
        timer = CADisplayLink.init(target: self, selector: #selector(newFrame))
        timer?.add(to: .main, forMode: .default)
        
        // Setup AVPlayerItemVideoOutput with the required pixelbuffer atttributes
        var pixelBufferAttributes: NSDictionary = [kCVPixelBufferMetalCompatibilityKey: true,
                                                   kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        videoOutput = AVPlayerItemVideoOutput.init(pixelBufferAttributes: pixelBufferAttributes as! [String : Any])
        
        // STUDY: https://medium.com/@BruceLee_38294/gcd-in-swfit-5-0-866b93d2589
        // STUDY: GCD
        videoOutputQueue = DispatchQueue(label: "VideoOutputQueue")
        videoOutput?.setDelegate(self, queue: videoOutputQueue)
    }
    
    @objc func newFrame(displayLink: CADisplayLink) {
        /*
        The callback gets called once every Vsync.
        Using tthe display link's timestamp and duration we can compute the next time the screen will be refreshed, and copy the pixel buffer for that time.
        This pixel buffer can then be processed and later rendered on screen
        */
        var outputItemTime: CMTime = .invalid
        
        // Calculate the nextVsync time which is when the screen will be refreshed next
        let nextVSync: CFTimeInterval = (displayLink.timestamp + displayLink.duration)
        
        if let output = videoOutput {
            outputItemTime = output.itemTime(forHostTime: nextVSync)
            
            var pixelBuffer: CVPixelBuffer?
            if output.hasNewPixelBuffer(forItemTime: outputItemTime) {
                pixelBuffer = output.copyPixelBuffer(forItemTime: outputItemTime, itemTimeForDisplay: nil)
            }
            
            if 0.0 == lastFrameTimestamp {
                lastFrameTimestamp = displayLink.timestamp
            }
            
            if let lastTimestamp = lastFrameTimestamp {
                var elapsed: TimeInterval = displayLink.timestamp - lastTimestamp
                lastFrameTimestamp = displayLink.timestamp
                
                // STUDY: autoreleasepool
                let drawable: CAMetalDrawable? = metalLayer?.nextDrawable()
                if let pixelBufferData = pixelBuffer, let drawableData = drawable {
                    metalViewControllerDelegate?.renderObject(drawable: drawableData, pixelBuffer: pixelBufferData)
                }
            }
        }
    }
}
