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

@interface VideoToolboxDecoder : NSObject

- (instancetype)initWithExtradata;

@end

NS_ASSUME_NONNULL_END
