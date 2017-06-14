//
//  YCTModel.m
//  DemoCoreText
//
//  Created by yxf on 2017/6/12.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "YCTModel.h"
#import "YCRegex.h"
#import "NSString+Emoji.h"
#import "YCEmojiModel.h"
#import "YCUrlModel.h"

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
        //emoji
        NSArray<YCEmojiModel *> *emojiModels = [YCRegex emojiRangesInString:_text];
        NSDictionary *sizeDic = [self emojiSizeInfo];
        NSDictionary *attributes = [self normalAttributes];
        [emojiModels enumerateObjectsWithOptions:NSEnumerationReverse
                                      usingBlock:^(YCEmojiModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                          
                                          // 使用 0xFFFC 作为空白的占位符
                                          unichar objectReplacementChar = 0xFFFC;
                                          NSString * content = [NSString stringWithCharacters:&objectReplacementChar length:1];
                                          NSMutableAttributedString *space =
                                          [[NSMutableAttributedString alloc] initWithString:content
                                                                                 attributes:attributes];
                                          [NSString setEmojiDelegateWithEmojiAtt:space
                                                                        SizeDict:sizeDic
                                                                         atRange:NSMakeRange(0, 1)];
                                          [attText replaceCharactersInRange:obj.range withAttributedString:space];
                                      }];
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

-(NSMutableArray *)imageInfos{
    if (!_imageInfos) {
        _imageInfos = [NSMutableArray array];
        //emoji
        __block NSArray<YCEmojiModel *> *emojiModels = [YCRegex emojiRangesInString:_text];
        NSMutableString *emojiString = [NSMutableString stringWithString:_text];
        [emojiModels enumerateObjectsUsingBlock:^(YCEmojiModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YCEmojiLocationModel *locationModel = [[YCEmojiLocationModel alloc] init];
            locationModel.text = [_text substringWithRange:obj.range];
            NSRange textRange = [emojiString rangeOfString:locationModel.text];
            locationModel.location = textRange.location;
            [_imageInfos addObject:locationModel];
            [emojiString replaceCharactersInRange:textRange withString:@"x"];
        }];
        
        [self positionEmojis:_imageInfos];
    }
    return _imageInfos;
}

-(NSMutableArray *)urlInfos{
    if (!_urlInfos) {
        _urlInfos = [NSMutableArray array];
        
        //url
        NSArray<YCUrlModel *> *urlModels = [YCRegex urlRangesInString:self.attText.string];
        [urlModels enumerateObjectsUsingBlock:^(YCUrlModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            YCUrlLocationModel *model = [[YCUrlLocationModel alloc] init];
            model.text = obj.text;
            model.range = obj.range;
            [_urlInfos addObject:model];
        }];
        
        [self postionUrls:_urlInfos];
        
    }
    return _urlInfos;
}


#pragma mark - custom func
-(void)releaseCtframe{
    if (!_ctFrame) {
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}

-(NSDictionary *)emojiSizeInfo{
    return @{@"width":@(self.font.lineHeight),
             @"ascent":@(self.font.ascender),
             @"descent":@(self.font.descender)};
}

//emoji占位符的属性
- (NSDictionary *)normalAttributes{
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    return @{NSParagraphStyleAttributeName : paragraph,
             NSForegroundColorAttributeName : [UIColor clearColor],
             YCEmoji : @"emoji"};
}

-(void)positionEmojis:(NSArray *)emojis
{
    if (emojis && emojis.count > 0 && self.ctFrame)
    {
        CTFrameRef frame = self.ctFrame;
        NSArray *lines = (NSArray *)CTFrameGetLines(frame);
        CFIndex lineCount = [lines count];
        
        CGFloat maxHeight = self.height;
        
        for (int i = 0; i < lineCount; i++)
        {
            CTLineRef line = (__bridge CTLineRef)lines[i];
            CFRange lineRange = CTLineGetStringRange(line);
            //            DDLogInfo(@"line location:%zd,line length:%zd",lineRange.location,lineRange.length);
            NSInteger lineMinIndex = lineRange.location;
            NSInteger lineMaxIndex = lineRange.location + lineRange.length;
            for (YCEmojiLocationModel *emojiModel in emojis)
            {
                if (emojiModel.location >= lineMaxIndex) {
                    //emoji在下一行
                    break;
                } else if(emojiModel.location >= lineMinIndex){
                    //emoji在这一行
                    CGRect emojiRect = CGRectZero;
                    emojiRect.size.width = self.font.lineHeight;
                    emojiRect.size.height = self.font.ascender - self.font.descender;
                    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, emojiModel.location, NULL);
                    //                    DDLogInfo(@"originx:%.2lf,offsetx:%.2lf",lineOrigins[i].x,xOffset);
                    //在这里使用时并没有设置offsetx，所以可以视为0
                    CGFloat lineOriginX = 0;
                    emojiRect.origin.x = lineOriginX + xOffset;
                    //一般emoji的坐标
                    emojiRect.origin.y = maxHeight - (i + 1) * self.font.lineHeight;
                    
                    CGPathRef pathRef = CTFrameGetPath(frame);
                    CGRect colRect = CGPathGetBoundingBox(pathRef);
                    emojiModel.frame = CGRectOffset(emojiRect, colRect.origin.x, colRect.origin.y);
                    emojiModel.line = i;
                }
                //emoji在上一行
            }
        }
    }
}


-(void)postionUrls:(NSArray *)urls{
    if (urls.count > 0 && self.ctFrame) {
        CTFrameRef frame = self.ctFrame;
        NSArray *lines = (NSArray *)CTFrameGetLines(frame);
        CFIndex lineCount = [lines count];
                
        for (int i = 0; i < lineCount; i++)
        {
            CTLineRef line = (__bridge CTLineRef)lines[i];
            CFRange lineRange = CTLineGetStringRange(line);
            //            DDLogInfo(@"line location:%zd,line length:%zd",lineRange.location,lineRange.length);
            NSInteger lineMinIndex = lineRange.location;
            NSInteger lineMaxIndex = lineRange.location + lineRange.length;
            
            for (YCUrlLocationModel *urlModel in urls) {
                NSInteger urlMaxLocation = urlModel.range.location + urlModel.range.length - 1;
                NSInteger urlMinLocation = urlModel.range.location;
                if (urlModel.range.location >= lineMaxIndex) {
                    //在下一行
                    break;
                }else if (urlMinLocation >= lineMinIndex && urlMinLocation < lineMaxIndex){
                    //url在这一行
                    CGRect emojiRect = CGRectZero;
                    
                    //height
                    emojiRect.size.height = self.font.ascender - self.font.descender;
                    
                    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, urlMinLocation, NULL);
                    
                    //width
                    if (urlMaxLocation + 1 >= lineMaxIndex) {
                        emojiRect.size.width = self.width - xOffset;
                    }else{
                        CGFloat xMaxOffset = CTLineGetOffsetForStringIndex(line, urlMaxLocation, NULL);
                        emojiRect.size.width = xMaxOffset - xOffset;
                    }
                    //在这里使用时并没有设置offsetx，所以可以视为0
                    CGFloat lineOriginX = 0;
                    emojiRect.origin.x = lineOriginX + xOffset;
                    //一般emoji的坐标
                    emojiRect.origin.y = i * self.font.lineHeight;
                    
                    CGPathRef pathRef = CTFrameGetPath(frame);
                    CGRect colRect = CGPathGetBoundingBox(pathRef);
                    CGRect frame = CGRectOffset(emojiRect, colRect.origin.x, colRect.origin.y);
                    [urlModel.frames addObject:[NSValue valueWithCGRect:frame]];
                }
                
                if (urlMaxLocation >= lineMinIndex && urlMaxLocation < lineMaxIndex) {
                    //url在这一行
                    CGRect emojiRect = CGRectZero;
                    
                    //height
                    emojiRect.size.height = self.font.ascender - self.font.descender;
                    
                    CGFloat xOffset = CTLineGetOffsetForStringIndex(line, lineMinIndex, NULL);
                    
                    //width
                    CGFloat xMaxOffset = CTLineGetOffsetForStringIndex(line, urlMaxLocation, NULL);
                    emojiRect.size.width = xMaxOffset - xOffset;
                    
                    //在这里使用时并没有设置offsetx，所以可以视为0
                    CGFloat lineOriginX = 0;
                    emojiRect.origin.x = lineOriginX + xOffset;
                    //一般emoji的坐标
                    emojiRect.origin.y = i * self.font.lineHeight;
                    
                    CGPathRef pathRef = CTFrameGetPath(frame);
                    CGRect colRect = CGPathGetBoundingBox(pathRef);
                    CGRect frame = CGRectOffset(emojiRect, colRect.origin.x, colRect.origin.y);
                    [urlModel.frames addObject:[NSValue valueWithCGRect:frame]];
                }  
            }
        }
 
    }
}

@end
