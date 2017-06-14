//
//  YCEmojiModel.h
//  DemoCoreText
//
//  Created by yxf on 2017/6/14.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YCEmojiModel : NSObject

/** text*/
@property(nonatomic,copy)NSString *text;

/** range*/
@property(nonatomic,assign)NSRange range;

+(instancetype)initWithText:(NSString *)text range:(NSRange)range;

@end


@interface YCEmojiLocationModel : NSObject

/** text*/
@property(nonatomic,copy)NSString *text;

/** location*/
@property(nonatomic,assign)NSInteger location;

/** line*/
@property(nonatomic,assign)NSInteger line;

/** frame*/
@property(nonatomic,assign)CGRect frame;

@end
