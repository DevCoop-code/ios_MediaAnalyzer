//
//  FFMpegUtil.m
//  mediaAnalyzer
//
//  Created by HanGyo Jeong on 2020/09/14.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "FFMpegUtil.h"

@implementation FFMpegUtil

/*
 TODO: It is not working now
 */
+ (void)convertMp4ToAnnexB:(uint8_t*)nal_buf {
    FFDemuxer demuxer = [FFMpegDemuxerWrapper getFFDemuxer];
    
    AVBitStreamFilterContext* bsf = av_bitstream_filter_init("h264_mp4toannexb");
    AVStream* avStream = demuxer.fmt_ctx->streams[demuxer.video_stream_index];
    AVCodecContext* codec_ctx = avStream->codec;
    AVPacket annexbPacket = demuxer.pkt;
    int ret = av_bitstream_filter_filter(bsf,
                                         codec_ctx,
                                         NULL,
                                         &annexbPacket.data,
                                         &annexbPacket.size,
                                         demuxer.pkt.data,
                                         demuxer.pkt.size,
                                         demuxer.pkt.flags);
    if (ret > 0) {
        annexbPacket.buf = av_buffer_create(annexbPacket.data, annexbPacket.size, av_buffer_default_free, NULL, 0);
        for (int i = 0; i < 10; i++) {
            NSLog(@"annex b<%x>", annexbPacket.data[i]);
        }
    }
}

@end
