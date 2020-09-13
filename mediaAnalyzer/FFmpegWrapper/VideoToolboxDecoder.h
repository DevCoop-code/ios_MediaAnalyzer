//
//  VideoToolboxDecoder.h
//  mediaAnalyzer
//
//  Created by HanGyo Jeong on 2020/08/07.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreFoundation/CFDictionary.h>
#import <VideoToolbox/VideoToolbox.h>

#include "FFMpegDemuxerWrapper.h"

NS_ASSUME_NONNULL_BEGIN

#ifndef VideoToolboxDecoder_IMPORTED
#define VideoToolboxDecoder_IMPORTED
@protocol NALUnitDelegate <NSObject>

- (void)nalUnitInfo:(uint8_t*)nal_buf_data nalUnitSize:(int)nal_buf_size;

@end

@interface VideoToolboxDecoder : NSObject

@property(nonatomic) id<NALUnitDelegate> delegate;

- (int)initWithExtradata:(FFMpegDemuxerWrapper*)demuxerWrapper;
- (int)decodeVideo: (CVPixelBufferRef*)pixelBuffer;
- (void)releaseVideoToolboxDecoder;

@end
#endif

NS_ASSUME_NONNULL_END
