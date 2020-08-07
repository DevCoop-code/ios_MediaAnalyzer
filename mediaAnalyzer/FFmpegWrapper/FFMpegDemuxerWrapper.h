//
//  FFMpegDemuxerWrapper.h
//  mediaAnalyzer
//
//  Created by HanGyo Jeong on 2020/08/02.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct FFDemuxer {
    int video_stream_index;
    AVFormatContext* fmt_ctx;
    AVCodecContext* codec_ctx;
    AVCodec* codec;
    AVPacket pkt;
} FFDemuxer;
FFDemuxer demuxer = {-1, NULL};

@interface FFMpegDemuxerWrapper : NSObject

- (int)initFFMpegConfigWithPath:(NSString*)url;

@end

NS_ASSUME_NONNULL_END
