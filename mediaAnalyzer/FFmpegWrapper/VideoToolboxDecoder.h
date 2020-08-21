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
@interface VideoToolboxDecoder : NSObject

- (int)initWithExtradata:(FFMpegDemuxerWrapper*)demuxerWrapper;

@end
#endif

NS_ASSUME_NONNULL_END
