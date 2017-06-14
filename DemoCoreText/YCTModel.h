//
//  YCTModel.h
//  DemoCoreText
//
//  Created by yxf on 2017/6/12.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface YCTModel : NSObject

+(instancetype)initWithText:(NSString *)text containerWith:(CGFloat)width;

/** ctframe*/
@property(nonatomic,assign,readonly)CTFrameRef ctFrame;

/** height*/
@property(nonatomic,assign,readonly)CGFloat height;

/** font*/
@property(nonatomic,strong,readonly)UIFont *font;

/** 图片信息*/
@property(nonatomic,strong)NSMutableArray *imageInfos;

/** 网址链接*/
@property(nonatomic,strong)NSMutableArray *urlInfos;

@end
