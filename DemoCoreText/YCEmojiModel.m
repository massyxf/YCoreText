//
//  YCEmojiModel.m
//  DemoCoreText
//
//  Created by yxf on 2017/6/14.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "YCEmojiModel.h"

@implementation YCEmojiModel

+(instancetype)initWithText:(NSString *)text range:(NSRange)range{
    YCEmojiModel *model = [[self alloc] init];
    model.text = text;
    model.range = range;
    return model;
}

@end


@implementation YCEmojiLocationModel



@end
