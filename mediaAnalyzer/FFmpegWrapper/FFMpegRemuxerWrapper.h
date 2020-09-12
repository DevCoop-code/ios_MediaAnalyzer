//
//  FFMpegRemuxerWrapper.h
//  mediaAnalyzer
//
//  Created by HanGyo Jeong on 2020/09/12.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct _FileContext {
    AVFormatContext* fmt_ctx;
    int v_index;
    int a_index;
} FileContext;
@interface FFMpegRemuxerWrapper : NSObject

- (NSString*)convertMpegtsToMp4:(const char*) tsfileName;
@end

NS_ASSUME_NONNULL_END
