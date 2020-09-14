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

#ifndef FFDemuxer_IMPORTED
#define FFDemuxer_IMPORTED
typedef struct FFDemuxer {
    int video_stream_index;
    AVFormatContext* fmt_ctx;
    AVCodecContext* codec_ctx;
    AVCodec* codec;
    AVPacket pkt;
} FFDemuxer;
static FFDemuxer demuxer = {-1, NULL};

typedef struct NAL_UNIT {
    uint8_t* nal_buf;
    int nal_size;
} NAL_UNIT;

@interface FFMpegDemuxerWrapper : NSObject

- (int)initFFMpegConfigWithPath:(NSString*)url;

- (AVCodecParameters*)getCodecParameters;

- (int) get_video_packet:(NAL_UNIT*) nalu;

- (void) ffmpeg_demuxer_release;

+ (FFDemuxer) getFFDemuxer;

@end
#endif

NS_ASSUME_NONNULL_END
