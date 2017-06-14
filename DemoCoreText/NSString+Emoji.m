//
//  NSString+Emoji.m
//  DemoCoreText
//
//  Created by yxf on 2017/6/14.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "NSString+Emoji.h"
#import <CoreText/CoreText.h>

@implementation NSString (Emoji)

static CGFloat ascentCallback(void *ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"ascent"] floatValue];
}
static CGFloat descentCallback(void *ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"descent"] floatValue];
}
static CGFloat widthCallback(void* ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}

+(void)setEmojiDelegateWithEmojiAtt:(NSMutableAttributedString *)emojiAtt SizeDict:(NSDictionary *)sizeDict atRange:(NSRange)range
{
    CTRunDelegateCallbacks callbacks;
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascentCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)(sizeDict));
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)emojiAtt,
                                   CFRangeMake(range.location, range.length),
                                   kCTRunDelegateAttributeName,
                                   delegate);
    CFRelease(delegate);
}

@end
