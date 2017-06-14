//
//  YCRegex.h
//  DemoCoreText
//
//  Created by yxf on 2017/6/14.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YCEmojiModel;
@class YCUrlModel;

@interface YCRegex : NSObject

+(NSArray<YCEmojiModel *> *)emojiRangesInString:(NSString *)text;

+(NSArray<YCUrlModel *> *)urlRangesInString:(NSString *)text;

@end
