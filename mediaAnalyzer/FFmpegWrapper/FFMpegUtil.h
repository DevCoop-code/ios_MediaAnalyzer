//
//  FFMpegUtil.h
//  mediaAnalyzer
//
//  Created by HanGyo Jeong on 2020/09/14.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "libavformat/avformat.h"
#include "FFMpegDemuxerWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface FFMpegUtil : NSObject

+ (void)convertMp4ToAnnexB:(uint8_t*)nal_buf;

@end

NS_ASSUME_NONNULL_END
