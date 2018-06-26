//
//  NSString+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/6/23.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSString+Ext.h"

@implementation NSString (Ext)

+ (BOOL)isEmpty:(id)string {
    
    if (![string isKindOfClass:[NSString class]]) {
        return TRUE;
    }else if (string == nil) {
        return TRUE;
    }else if(!string) {
        // null object
        return TRUE;
    } else if(string == NULL) {
        // null object
        return TRUE;
    } else if([string isEqualToString:@"NULL"]) {
        // null object
        return TRUE;
    }else if([string isEqualToString:@"(null)"]){
        return TRUE;
    }else{
        //  使用whitespaceAndNewlineCharacterSet删除周围的空白字符串
        //  然后在判断首位字符串是否为空
        NSString *trimedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            // empty string
            return TRUE;
        } else {
            // is neither empty nor null
            return FALSE;
        }
    }
}

- (BOOL)containChinese {
    
    NSUInteger length = [self length];
    for (NSUInteger i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [self substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)containsaString:(NSString *)string {
    
    NSRange rang = [self rangeOfString:string];
    if (rang.location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

@end

@implementation NSString (Size)

//根据文字宽度获取文字高度
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width {
    
    return [self sizeWithFont:font constrainedToWidth:width].height;
}

//根据文字高度获取文字宽度
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height {
    
    return [self sizeWithFont:font constrainedToHeight:height].width;
}

//根据宽度获取文字大小
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width {
    
    return [self _sizeWithFont:font value:width isWidth:YES];
}

//根据高度获取文字大小
- (CGSize)sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height {
    
    return [self _sizeWithFont:font value:height isWidth:NO];
}

- (CGSize)_sizeWithFont:(UIFont *)font value:(CGFloat)value isWidth:(BOOL)isWidth {
    
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
    CGSize computingSize;
    if (isWidth) {
        computingSize = CGSizeMake(value, CGFLOAT_MAX);
    } else {
        computingSize = CGSizeMake(CGFLOAT_MAX, value);
    }
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:computingSize
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:computingSize
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:computingSize
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
    
}

@end


@implementation NSString (Trims)

/**
 *  @brief  清除html标签
 *
 *  @return 清除后的结果
 */
- (NSString *)stringByStrippingHTML {
    return [self stringByReplacingOccurrencesOfString:@"<[^>]+>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}
/**
 *  @brief  清除js脚本
 *
 *  @return 清楚js后的结果
 */
- (NSString *)stringByRemovingScriptsAndStrippingHTML {
    
    NSMutableString *mString = [self mutableCopy];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<script[^>]*>[\\w\\W]*</script>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:mString options:NSMatchingReportProgress range:NSMakeRange(0, [mString length])];
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        [mString replaceCharactersInRange:match.range withString:@""];
    }
    return [mString stringByStrippingHTML];
}

/**
 *  @brief  去除空格
 *
 *  @return 去除空格后的字符串
 */
- (NSString *)trimmingWhitespace {
    
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

/**
 *  @brief  去除字符串与空行
 *
 *  @return 去除字符串与空行的字符串
 */
- (NSString *)trimmingWhitespaceAndNewlines {
    
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/**
 @brief 调整html字符串
 
 @param content 原来html字符串
 @return 调整后的字符串
 */
+ (NSString*)adjustHTMLFormat:(NSString *)content {
    
    NSMutableString *tmpMutable = [NSMutableString stringWithString:content];
    NSRange range = [tmpMutable rangeOfString:@"<a "];
    while (range.location != NSNotFound) {
        
        [tmpMutable replaceCharactersInRange:range
                                  withString:@"<a style=\"background:green; color:white; line-height:35px; border-radius:5px; height:50x; display:block;\" "];
        range = [tmpMutable rangeOfString:@"<a " options:NSLiteralSearch range:NSMakeRange(range.location+3, content.length-range.location-3)];
        
    }
    
    range = [tmpMutable rangeOfString:@"<img"];
    while (range.location != NSNotFound) {
        
        [tmpMutable replaceCharactersInRange:range
                                  withString:@"<img width=100% "];
        range = [tmpMutable rangeOfString:@"<img" options:NSLiteralSearch range:NSMakeRange(range.location+4, content.length-range.location-4)];
        
    }
    return tmpMutable;
}

@end


