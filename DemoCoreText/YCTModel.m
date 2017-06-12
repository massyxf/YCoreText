//
//  YCTModel.m
//  DemoCoreText
//
//  Created by yxf on 2017/6/12.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "YCTModel.h"

@interface YCTModel ()

/** text*/
@property(nonatomic,copy)NSString *text;

/** width*/
@property(nonatomic,assign)CGFloat width;

/** ctframe*/
@property(nonatomic,assign)CTFrameRef ctFrame;

/** height*/
@property(nonatomic,assign)CGFloat height;

/** att text*/
@property(nonatomic,copy)NSAttributedString *attText;

/** font*/
@property(nonatomic,strong)UIFont *font;

@end

@implementation YCTModel

@synthesize ctFrame = _ctFrame;

+(instancetype)initWithText:(NSString *)text containerWith:(CGFloat)width{
    YCTModel *model = [[self alloc] init];
    model.text = text;
    model.width = width;
    return model;
}

-(void)dealloc{
    [self releaseCtframe];
}

#pragma mark - setter
-(void)setCtFrame:(CTFrameRef)ctFrame{
    if (_ctFrame != ctFrame) {
        [self releaseCtframe];
        _ctFrame = CFRetain(ctFrame);
    }
}

#pragma mark - getter

-(UIFont *)font{
    if (!_font) {
        _font = [UIFont systemFontOfSize:15];
    }
    return _font;
}

-(NSAttributedString *)attText{
    if (!_attText) {
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:_text];
        [attText addAttributes:@{NSFontAttributeName : self.font,
                                 NSForegroundColorAttributeName : [UIColor blackColor]}
                         range:NSMakeRange(0, attText.length)];
        _attText = attText;
    }
    return _attText;
}


-(CTFrameRef)ctFrame{
    if (!_ctFrame) {
        
        //CTFramesetter
        CTFramesetterRef setter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attText);
        
        //att range
        CFRange range = CFRangeMake(0, self.attText.length);
        
        //core text 推荐高度 不准确
        CGFloat suggestHeight = CTFramesetterSuggestFrameSizeWithConstraints(setter,
                                                                             range,
                                                                             NULL,
                                                                             CGSizeMake(self.width, 100000),
                                                                             NULL).height;
        //获取绘制范围, 绘制范围需大于文字实际占据的大小，否则会显示不完全
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, self.width, suggestHeight * 2));
        
        //获取CTFrameRef
        CTFrameRef frame = CTFramesetterCreateFrame(setter,
                                 range,
                                 path,
                                 NULL);
        _ctFrame = CFRetain(frame);
        
        CFRelease(setter);
        CFRelease(path);
        CFRelease(frame);
    }
    return _ctFrame;
}

-(CGFloat)height{
    if (_height<= 0 && _text.length > 0) {
        //行数
        CFArrayRef lines = CTFrameGetLines(self.ctFrame);
        CFIndex lineCount = CFArrayGetCount(lines);
        
        //根据行高计算文字内容所占据的高度
        _height = lineCount * self.font.lineHeight;
    }
    return _height;
}

#pragma mark - custom func
-(void)releaseCtframe{
    if (!_ctFrame) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}




@end
