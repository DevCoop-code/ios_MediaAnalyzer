//
//  FFMpegRemuxerWrapper.m
//  mediaAnalyzer
//
//  Created by HanGyo Jeong on 2020/09/12.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "FFMpegRemuxerWrapper.h"

@implementation FFMpegRemuxerWrapper {
    FileContext inputFile, outputFile;
}

- (int)open_input:(const char*) fileName {
    inputFile.fmt_ctx = NULL;
    inputFile.a_index = inputFile.v_index = -1;
    
    if (avformat_open_input(&inputFile.fmt_ctx, fileName, NULL, NULL) < 0) {
        printf("Could not open input file %s\n", fileName);
        return -1;
    }
    
    if (avformat_find_stream_info(inputFile.fmt_ctx, NULL) < 0) {
        printf("Failed to retrieve input stream informaation\n");
        return -2;
    }
    
    for (unsigned int index = 0; index < inputFile.fmt_ctx->nb_streams; index++) {
        AVCodecContext* codec_ctx = inputFile.fmt_ctx->streams[index]->codec;
        if (codec_ctx->codec_type == AVMEDIA_TYPE_VIDEO && inputFile.v_index < 0) {
            inputFile.v_index = index;
        }
        else if (codec_ctx->codec_type == AVMEDIA_TYPE_AUDIO && inputFile.a_index < 0) {
            inputFile.a_index = index;
        }
    }
    
    if (inputFile.v_index < 0) {
        printf("There is no Video Information");
    }
    if (inputFile.a_index < 0) {
        printf("There is no Audio Information");
    }
    
    return 0;
}

- (int) create_output:(const char*) fileName {
    outputFile.fmt_ctx = NULL;
    outputFile.a_index = outputFile.v_index = -1;
    
    if (avformat_alloc_output_context2(&outputFile.fmt_ctx, NULL, NULL, fileName) < 0) {
        printf("Could not create output context\n");
        return -1;
    }
    
    // Start to Stream Index 0
    int output_index = 0;
    // Copy the input file context
    for (int index = 0; index < inputFile.fmt_ctx->nb_streams; index++) {
        // Add the stream from input file
        if (index != inputFile.v_index && index != inputFile.a_index) {
            continue;
        }
        AVStream* in_stream = inputFile.fmt_ctx->streams[index];
        AVCodecContext* in_codec_ctx = in_stream->codec;
        
        AVStream* out_stream = avformat_new_stream(outputFile.fmt_ctx, in_codec_ctx->codec);
        if (out_stream == NULL) {
            printf("Failed to allocate output stream\n");
            return -2;
        }
        
        AVCodecContext* outCodecContext = out_stream->codec;
        if (avcodec_copy_context(outCodecContext, in_codec_ctx) < 0) {
            printf("Error occured while copying context\n");
            return -3;
        }
        
        // Use AVStream instead of Deprecated AVCodecContext
        out_stream->time_base = in_stream->time_base;
        
        // Remove the codec tag information to match compatibility with codecs supported by ffmpeg
        outCodecContext->codec_tag = 0;
        if (outputFile.fmt_ctx->oformat->flags & AVFMT_GLOBALHEADER) {
            outCodecContext->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;
        }
        if (index == inputFile.v_index) {
            outputFile.v_index = output_index++;
        }
        else
        {
            outputFile.a_index = output_index++;
        }
    }
    
    if (!(outputFile.fmt_ctx->oformat->flags & AVFMT_NOFILE)) {
        // Open the File
        if (avio_open(&outputFile.fmt_ctx->pb, fileName, AVIO_FLAG_WRITE) < 0) {
            printf("Failed to create output file %s\n", fileName);
            return -4;
        }
    }
    
    // Function for writing header files for container
    if (avformat_write_header(outputFile.fmt_ctx, NULL) < 0) {
        printf("Failed writing header into output file\n");
        return -5;
    }
    return 0;
}

- (void)releaseRemuxer {
    if (inputFile.fmt_ctx != NULL) {
        avformat_close_input(&inputFile.fmt_ctx);
    }
    if (outputFile.fmt_ctx != NULL) {
        if(!(outputFile.fmt_ctx->oformat->flags & AVFMT_NOFILE)) {
            avio_closep(&outputFile.fmt_ctx->pb);
        }
        avformat_free_context(outputFile.fmt_ctx);
    }
}

- (NSString*)convertMpegtsToMp4:(const char*) tsfileName {
    int ret;
    av_register_all();

    if ([self open_input:tsfileName] < 0) {
        printf("Problem occured when open_input \n");
        return NULL;
    }
    
    unsigned long tsFileNameLength = strlen(tsfileName);
    char* mp4FileName = (char*)malloc((sizeof(char) * tsFileNameLength) + 1);
    strcpy(mp4FileName, tsfileName);
    mp4FileName[tsFileNameLength] = '4';
    mp4FileName[tsFileNameLength - 1] = 'p';
    mp4FileName[tsFileNameLength - 2] = 'm';
    printf("New File Name: %s\n", mp4FileName);
    
    if ([self create_output:mp4FileName] < 0) {
        printf("Problem occured when create_output \n");
        return NULL;
    }
    
    // Print out of output file information
    av_dump_format(outputFile.fmt_ctx, 0, outputFile.fmt_ctx->filename, 1);
    AVPacket pkt;
    int out_stream_index;
    
    while (1) {
        ret = av_read_frame(inputFile.fmt_ctx, &pkt);
        if (ret == AVERROR_EOF) {
            printf("End of frame \n");
            break;
        }
        if (pkt.stream_index != inputFile.v_index && pkt.stream_index != inputFile.a_index) {
            av_free_packet(&pkt);
            continue;
        }
        
        AVStream* in_stream = inputFile.fmt_ctx->streams[pkt.stream_index];
        out_stream_index = (pkt.stream_index == inputFile.v_index) ? outputFile.v_index : outputFile.a_index;
        
        AVStream* out_stream = outputFile.fmt_ctx->streams[out_stream_index];
        
        av_packet_rescale_ts(&pkt, in_stream->time_base, out_stream->time_base);
        pkt.stream_index = out_stream_index;
        
        if (av_interleaved_write_frame(outputFile.fmt_ctx, &pkt) < 0) {
            printf("Error occured when writing packet into file \n");
            break;
        }
    }
    // Clean up uncompleted information at the point of writing the file
    av_write_trailer(outputFile.fmt_ctx);
    
    [self releaseRemuxer];
    
    return [[NSString alloc] initWithCString:mp4FileName encoding:NSUTF8StringEncoding];
}
@end
