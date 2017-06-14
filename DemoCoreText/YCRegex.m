//
//  YCRegex.m
//  DemoCoreText
//
//  Created by yxf on 2017/6/14.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "YCRegex.h"
#import "YCEmojiModel.h"
#import "YCUrlModel.h"

@implementation YCRegex

+(NSArray<YCEmojiModel *> *)emojiRangesInString:(NSString *)text{
    NSString *emojiRegext = @"\\[emoji\\]";
    NSArray<NSTextCheckingResult *> *emojis = [self regexModelsWithPattern:emojiRegext text:text];
    NSMutableArray *emojiModels = [NSMutableArray array];
    [emojis enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.range.length > 0) {//获取emoji
            NSString *emojiText  = [text substringWithRange:obj.range];
            YCEmojiModel *model = [YCEmojiModel initWithText:emojiText range:obj.range];
            [emojiModels addObject:model];
        }
    }];
    return emojiModels;
}

+(NSArray<YCUrlModel *> *)urlRangesInString:(NSString *)text{
    NSString *urlRegext = @"www.baidu.com";
    NSArray<NSTextCheckingResult *> *urls = [self regexModelsWithPattern:urlRegext text:text];
    NSMutableArray *urlModels = [NSMutableArray array];
    [urls enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.range.length > 0) {//获取emoji
            NSString *urlText  = [text substringWithRange:obj.range];
            YCUrlModel *model = [YCUrlModel initWithText:urlText range:obj.range];
            [urlModels addObject:model];
        }
    }];
    return urlModels;
}

+(NSArray<NSTextCheckingResult *> *)regexModelsWithPattern:(NSString *)pattern text:(NSString *)text{
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:nil];
    return [expression matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)];
}

@end
