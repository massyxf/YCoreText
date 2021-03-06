//
//  YCTView.m
//  DemoCoreText
//
//  Created by yxf on 2017/6/12.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "YCTView.h"
#import "YCTModel.h"
#import "YCEmojiModel.h"
#import "YCUrlModel.h"

@interface YCTView ()

/** touch url*/
@property(nonatomic,strong)YCUrlLocationModel *urlModel;

/** shadow view*/
@property(nonatomic,strong)NSMutableArray<UIView *> *shawdowViews;

@end

@implementation YCTView

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    //绘制背景色
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    //绘制文字
    if (self.model.ctFrame) {
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        //----------------------draw text----------------------//
        // 创建绘制区域，path的高度对绘制有直接影响，如果高度不够，则计算出来的CTLine的数量会少一行或者少多行
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathAddRect(path, NULL, CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.model.height * 2));
        
        // 一行一行绘制
        CFArrayRef lines = CTFrameGetLines(self.model.ctFrame);
        CFIndex lineCount = CFArrayGetCount(lines);
        
        CGPoint lineOrigins[lineCount];
        // 把ctFrame里每一行的初始坐标写到数组里，注意CoreText的坐标是左下角为原点
        CTFrameGetLineOrigins(self.model.ctFrame, CFRangeMake(0, 0), lineOrigins);
        for (CFIndex i = 0; i < lineCount; i++){
            
            // 遍历每一行CTLine
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            CGFloat lineAscent;
            CGFloat lineDescent;
            CGFloat lineLeading; // 行距
            // 该函数除了会设置好ascent,descent,leading之外，还会返回这行的宽度
            CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
            
            //重置每行的origin.y,CoreText的origin的Y值是在baseLine处，而不是下方的descent。
            CGPoint lineOrigin = lineOrigins[i];
            //lineFont.descender为负值,TATextTopMargin顶部留白区
            lineOrigin.y = self.model.height - (i + 1) * self.model.font.lineHeight - self.model.font.descender;
            
            //调整坐标
            CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
            
            CTLineDraw(line, context);
        }
        CFRelease(path);
    }
    
    //draw image
    UIImage *image = [UIImage imageNamed:@"1.png"];
    for (YCEmojiLocationModel *model in self.model.imageInfos) {
        CGContextDrawImage(context, model.frame, image.CGImage);
    }
}

-(void)setModel:(YCTModel *)model{
    _model = model;
    //调用drawRect方法重绘
    [self setNeedsDisplay];
}

-(NSMutableArray<UIView *> *)shawdowViews{
    if (!_shawdowViews) {
        _shawdowViews = [NSMutableArray array];
    }
    return _shawdowViews;
}

#pragma mark - custom func
-(void)removeShadowView{
    for (UIView *view in self.shawdowViews) {
        [view removeFromSuperview];
    }
    [self.shawdowViews removeAllObjects];
}

#pragma mark - touch
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.urlModel = nil;
    [self removeShadowView];
    UITouch *touch  =[touches anyObject];
    CGPoint point = [touch locationInView:self];
    for (YCUrlLocationModel *model in self.model.urlInfos) {
        for (NSValue *value in model.frames) {
            CGRect frame = [value CGRectValue];
            if (CGRectContainsPoint(frame, point)) {
                //包含触摸点
                self.urlModel = model;
                break;
            }
        }
        if (self.urlModel) {
            for (NSValue *value in self.urlModel.frames) {
                CGRect frame = [value CGRectValue];
                UIView *shawdowView = [[UIView alloc] initWithFrame:frame];
                shawdowView.backgroundColor = [UIColor colorWithRed:0.3 green:0.2 blue:0.4 alpha:0.3];
                [self addSubview:shawdowView];
                [self.shawdowViews addObject:shawdowView];
            }
            return;
        }
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.urlModel = nil;
    [self removeShadowView];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.urlModel) {
        NSLog(@"touch:%@",self.urlModel.text);
        NSString *url = [NSString stringWithFormat:@"http://%@",self.urlModel.text];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        [self removeShadowView];
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.urlModel = nil;
    [self removeShadowView];
}


@end
