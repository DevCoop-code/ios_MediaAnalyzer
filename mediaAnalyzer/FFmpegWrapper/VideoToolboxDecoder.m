//
//  VideoToolboxDecoder.m
//  mediaAnalyzer
//
//  Created by HanGyo Jeong on 2020/08/07.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "VideoToolboxDecoder.h"

@implementation VideoToolboxDecoder {
    FFMpegDemuxerWrapper* ffDemuxerWrapper;
    AVCodecParameters* codecpar;
    CMVideoFormatDescriptionRef formatDescription;
    VTDecompressionSessionRef decompressSession;
}

- (int)initWithExtradata:(FFMpegDemuxerWrapper*)demuxerWrapper {
    if (demuxerWrapper != nil) {
        ffDemuxerWrapper = demuxerWrapper;
        if (self) {
           codecpar = [ffDemuxerWrapper getCodecParameters];
           [self createVideoToolboxDecoder];
        } else {
           return -1;
        }
    } else {
        return -1;
    }
    
    return 0;
}

#pragma mark - callback when frame decompression
static void didDecompress(void* decompressionOutputRefCon,
                          void* sourceFrameRefCon,
                          OSStatus status,
                          VTDecodeInfoFlags infoFlags,
                          CVImageBufferRef pixelBuffer,
                          CMTime presentationTimeStamp,
                          CMTime presentationDuration) {
    CVPixelBufferRef* outputPixelBuffer = (CVPixelBufferRef*)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}

- (int)createVideoToolboxDecoder {
    int width = codecpar->width;
    int height = codecpar->height;
    
    // Extra binary data needed for initializing the decoder
    int extradata_size = codecpar->extradata_size;  //ex)sps, pps size
    uint8_t *extradata = codecpar->extradata;   //ex)sps, pps
    
    OSStatus status;
    
    // PixelAspectRatio
    // Declare the Dictionaries
    CFMutableDictionaryRef par = CFDictionaryCreateMutable(NULL,
                                                           0,
                                                           &kCFTypeDictionaryKeyCallBacks,
                                                           &kCFTypeDictionaryValueCallBacks);
    CFMutableDictionaryRef atoms = CFDictionaryCreateMutable(NULL,
                                                             0,
                                                             &kCFTypeDictionaryKeyCallBacks,
                                                             &kCFTypeDictionaryValueCallBacks);
    CFMutableDictionaryRef extensions = CFDictionaryCreateMutable(NULL,
                                                                  0,
                                                                  &kCFTypeDictionaryKeyCallBacks,
                                                                  &kCFTypeDictionaryValueCallBacks);
    NSLog(@"Frame width:%d, height:%d", width, height);
    
    // CVPixelAspectRatio dict
    /*
     CoreFoundation - CFSTR
     Creates an immutable string from a constant compile-time string
     */
    dict_set_i32(par, CFSTR("HorizontalSpacing"), 0);
    dict_set_i32(par, CFSTR("VerticalSpacing"), 0);
    
    // SampleDescriptionExtensionAtoms dict
    dict_set_data(atoms, CFSTR("extraUnit"), (uint8_t*)extradata, extradata_size);
    
    // Extensions dict
    dict_set_string(extensions, CFSTR("CVImageBufferChromaLocationBottomField"), "left");
    dict_set_string(extensions, CFSTR("CVImageBufferChromaLocationTopField"), "left");
    dict_set_boolean(extensions, CFSTR("FullRangeVideo"), FALSE);
    dict_set_object(extensions, CFSTR("CVPixelAspectRatio"), (CFTypeRef*)par);
    dict_set_object(extensions, CFSTR("SampleDescriptionExtensionAtoms"), (CFTypeRef*)atoms);
    
    CMVideoCodecType codecType = -1;
    switch (codecpar->codec_id) {
        case AV_CODEC_ID_H264:
            codecType = kCMVideoCodecType_H264;
        break;
            
        case AV_CODEC_ID_H263:
            codecType = kCMVideoCodecType_H263;
        break;
            
        case AV_CODEC_ID_HEVC:
            codecType = kCMVideoCodecType_HEVC;
        break;
            
        case AV_CODEC_ID_MPEG4:
            codecType = kCMVideoCodecType_MPEG4Video;
        break;
            
        case AV_CODEC_ID_MPEG2TS:
            codecType = kCMVideoCodecType_MPEG2Video;
        break;
        
        default:
            NSLog(@"Unsupported codec: %u", codecpar->codec_id);
            codecType = 0;
        break;
    }
    
    if (codecType == 0) {
        // Codec Not Supported
        return -1;
    }
    status = CMVideoFormatDescriptionCreate(NULL,
                                            codecType,
                                            width,
                                            height,
                                            extensions,
                                            &(formatDescription));
    CFRelease(extensions);
    CFRelease(atoms);
    CFRelease(par);
    
    if (status != 0) {
        NSError* error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Error: creating format descripttion failed. Description: %@", [error description]);
        return -1;
    }
    
    // TODO: Apply Pixel Format(YUV) and Renderer(OpenGLES, Metal)
    CFMutableDictionaryRef destinationPixelBufferAttributes;
    destinationPixelBufferAttributes = CFDictionaryCreateMutable(NULL,
                                                                 0,
                                                                 &kCFTypeDictionaryKeyCallBacks,
                                                                 &kCFTypeDictionaryValueCallBacks);
    dict_set_i32(destinationPixelBufferAttributes, kCVPixelBufferPixelFormatTypeKey, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange);
    dict_set_i32(destinationPixelBufferAttributes, kCVPixelBufferWidthKey, width);
    dict_set_i32(destinationPixelBufferAttributes, kCVPixelBufferHeightKey, height);
    dict_set_boolean(destinationPixelBufferAttributes, kCVPixelBufferMetalCompatibilityKey, YES);
    
    /*
     VTDecompressionOutputCallbackRecord
     is a simple structure with a pointer to the callback function invoked when frame decompression
     */
    VTDecompressionOutputCallbackRecord outputCallback;
    outputCallback.decompressionOutputCallback = didDecompress;
    outputCallback.decompressionOutputRefCon = NULL;
    status = VTDecompressionSessionCreate(kCFAllocatorDefault,
                                          formatDescription,
                                          NULL,
                                          destinationPixelBufferAttributes,
                                          &outputCallback,
                                          &(decompressSession));
    
    if (status != noErr) {
        NSError* error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        NSLog(@"Error: Creating decompression session failed. Description: %@", [error description]);
        return -1;
    }
    return 0;
}

# pragma mark - Decode the frame data
- (int)decodeVideo:(CVPixelBufferRef *)pixelBuffer {
    int err = 0;
    NAL_UNIT nal_unit = {NULL, 0};
    if (ffDemuxerWrapper != nil) {
        err = [ffDemuxerWrapper get_video_packet:&nal_unit];
        
        if (err < 0) {
            return err;
        }
        
        CVPixelBufferRef outputPixelBuffer = NULL;
        CMBlockBufferRef blockBuffer = NULL;
        OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                             (void *)nal_unit.nal_buf,
                                                             nal_unit.nal_size,
                                                             kCFAllocatorNull,
                                                             NULL,
                                                             0,
                                                             nal_unit.nal_size,
                                                             0,
                                                             &blockBuffer);
        if (status != kCMBlockBufferNoErr) {
            NSLog(@"Error: Creating block buffer failed.");
            return -1;
        }
        
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = { nal_unit.nal_size };
        status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                           blockBuffer,
                                           formatDescription,
                                           1,
                                           0,
                                           NULL,
                                           1,
                                           sampleSizeArray,
                                           &sampleBuffer);
        if (status != kCMBlockBufferNoErr || !sampleBuffer) {
            NSLog(@"Error: Creating sample buffer failed");
            return -1;
        }
        
        VTDecodeFrameFlags flags = 0;
        VTDecodeInfoFlags flagOut = 0;
        status = VTDecompressionSessionDecodeFrame(decompressSession,
                                                   sampleBuffer,
                                                   flags,
                                                   &outputPixelBuffer,
                                                   &flagOut);
        switch (status) {
            case noErr:
                NSLog(@"Decoding one frame succeeded.");
                break;
            case kVTInvalidSessionErr:
                NSLog(@"Error: Invalid session, reset decoder session.");
                break;
            case kVTVideoDecoderBadDataErr:
                NSLog(@"Error: decode failed status=%d(Bad data).", status);
                break;
            default:
                NSLog(@"Error: decode failed status=%d.", status);
                break;
        }
        
        CFRelease(sampleBuffer);
        CFRelease(blockBuffer);
        
        if (status == noErr) {
            *pixelBuffer = outputPixelBuffer;
            return 1;
        } else {
            return 0;
        }
    } else {
        return -1;
    }
}

- (void)releaseVideoToolboxDecoder {
    if (decompressSession) {
        VTDecompressionSessionInvalidate(decompressSession);
        CFRelease(decompressSession);
        decompressSession = NULL;
    }
    
    if (formatDescription) {
        CFRelease(formatDescription);
        formatDescription = NULL;
    }
    
    if (codecpar) {
        av_free(codecpar);
        codecpar = NULL;
    }
    NSLog(@"VideoToolbox decoder released.");
}

# pragma mark - Utils
static void dict_set_i32(CFMutableDictionaryRef dict, CFStringRef key, int32_t value) {
    CFNumberRef number;     // CFNumber - CFNumber encapsulates C scalar (numeric) types
    number = CFNumberCreate(NULL, kCFNumberSInt32Type, &value);
    CFDictionarySetValue(dict, key, number);
    CFRelease(number);
}

static void dict_set_data(CFMutableDictionaryRef dict, CFStringRef key, uint8_t* value, uint64_t length) {
    CFDataRef data;
    data = CFDataCreate(NULL, value, (CFIndex)length);
    CFDictionarySetValue(dict, key, data);
    CFRelease(data);
}

static void dict_set_string(CFMutableDictionaryRef dict, CFStringRef key, const char* value) {
    CFStringRef string;
    string = CFStringCreateWithCString(NULL, value, kCFStringEncodingASCII);
    CFRelease(string);
}

static void dict_set_boolean(CFMutableDictionaryRef dict, CFStringRef key, BOOL value) {
    CFDictionarySetValue(dict, key, value ? kCFBooleanTrue : kCFBooleanFalse);
}

static void dict_set_object(CFMutableDictionaryRef dict, CFStringRef key, CFTypeRef* value) {
    // CFTypeRef - An untyped "generic" reference to any Core Foundation object
    CFDictionarySetValue(dict, key, value);
}
@end
