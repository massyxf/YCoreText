//
//  YCUrlModel.h
//  DemoCoreText
//
//  Created by yxf on 2017/6/14.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "YCEmojiModel.h"

@interface YCUrlModel : YCEmojiModel

@end


@interface YCUrlLocationModel : NSObject

/** text*/
@property(nonatomic,copy)NSString *text;

/** range*/
@property(nonatomic,assign)NSRange range;

/** frames*/
@property(nonatomic,strong)NSMutableArray *frames;

@end
