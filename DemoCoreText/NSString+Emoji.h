//
//  NSString+Emoji.h
//  DemoCoreText
//
//  Created by yxf on 2017/6/14.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Emoji)

+(void)setEmojiDelegateWithEmojiAtt:(NSMutableAttributedString *)emojiAtt SizeDict:(NSDictionary *)sizeDict atRange:(NSRange)range;

@end
