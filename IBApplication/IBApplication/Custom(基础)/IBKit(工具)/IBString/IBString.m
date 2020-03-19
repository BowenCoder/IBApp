//
//  IBString.m
//  IBApplication
//
//  Created by Bowen on 2018/6/27.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "IBString.h"

#define EmojiCodeToSymbol(c) ((((0x808080F0 | (c & 0x3F000) >> 4) | (c & 0xFC0) << 10) | (c & 0x1C0000) << 18) | (c & 0x3F) << 24)


@implementation IBString

/**
 *  @brief  判断URL中是否包含中文
 *
 *  @param string 字符串
 *
 *  @return 是否包含中文
 */
+ (BOOL)containChinese:(NSString *)string {
    
    NSUInteger length = [string length];
    for (NSUInteger i = 0; i < length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [string substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3) {
            return YES;
        }
    }
    return NO;
    
}

/**
 *  @brief 是否包含字符串
 *
 *  @param string 被包的字符串
 *  @param bag 包含的字符串
 *
 *  @return YES, 包含;
 */
+ (BOOL)containString:(NSString *)string inString:(NSString *)bag {
    
    NSRange rang = [bag rangeOfString:string];
    if (rang.location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

/**
 *  @brief 计算文字的高度
 *
 *  @param text  文本
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 *
 */
+ (CGFloat)height:(NSString *)text font:(UIFont *)font width:(CGFloat)width {
    
    return [self size:text font:font width:width].height;
}

/**
 *  @brief 计算文字的宽度
 *
 *  @param text   文本
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 *
 */
+ (CGFloat)width:(NSString *)text font:(UIFont *)font height:(CGFloat)height {
    
    return [self size:text font:font height:height].width;
}

/**
 *  @brief 计算文字的大小
 *
 *  @param text  文本
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 *
 */
+ (CGSize)size:(NSString *)text font:(UIFont *)font width:(CGFloat)width {
    
    return [self _size:text font:font value:width isWidth:YES];
}

/**
 *  @brief 计算文字的大小
 *
 *  @param text   文本
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 *
 */
+ (CGSize)size:(NSString *)text font:(UIFont *)font height:(CGFloat)height {
    
    return [self _size:text font:font value:height isWidth:NO];
}

+ (CGSize)_size:(NSString *)text font:(UIFont *)font value:(CGFloat)value isWidth:(BOOL)isWidth {
    
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
    CGSize computingSize;
    if (isWidth) {
        computingSize = CGSizeMake(value, CGFLOAT_MAX);
    } else {
        computingSize = CGSizeMake(CGFLOAT_MAX, value);
    }
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [text boundingRectWithSize:computingSize
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [text sizeWithFont:textFont
                    constrainedToSize:computingSize
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [text boundingRectWithSize:computingSize
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
    
}


/**
 *  @brief  清除html标签
 *
 *  @param  html html字符串
 *
 *  @return 清除后的结果
 */
+ (NSString *)clearHTML:(NSString *)html {
    
    return [html stringByReplacingOccurrencesOfString:@"<[^>]+>" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, html.length)];
}

/**
 *  @brief  清除js脚本
 *
 *  @param  js js字符串
 *
 *  @return 清楚js后的结果
 */
+ (NSString *)clearJS:(NSString *)js {
    
    NSMutableString *mString = [js mutableCopy];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<script[^>]*>[\\w\\W]*</script>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:mString options:NSMatchingReportProgress range:NSMakeRange(0, [mString length])];
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        [mString replaceCharactersInRange:match.range withString:@""];
    }
    return [self clearHTML:mString];
}

/// 清除所有空白
/// @param text 文本
+ (NSString *)clearAllWhitespace:(NSString *)text {
    
    return [text stringByReplacingOccurrencesOfString:@"\\s" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, text.length)];
}

/**
 *  @brief  清除空格，并判断是否过滤特殊字符
 *
 *  @param  text   字符串
 *  @param  filter 是否过滤
 *
 *  @return 清楚js后的结果
 */
+ (NSString *)clearWhitespace:(NSString *)text filter:(BOOL)filter {
    
    if (filter) {
        return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    } else {
        return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

/// 将文字中的换行符替换为空格
/// @param text 文本
+ (NSString *)clearLineBreak:(NSString *)text {
    
    return [text stringByReplacingOccurrencesOfString:@"[\r\n]" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, text.length)];
}

/**
 调整html返回的字符串的内容格式
 
 @param  content html字符串
 @return 调整后的字符串
 */
+ (NSString *)adjustHTMLFormat:(NSString *)content {
    
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

/**
 过滤非法字符
 
 @param string 原字符串
 @param target 过滤关键字 []{}（#%-*+=_）\\|~(＜＞$%^&*)_+
 @return 过滤后的字符串
 */
+(NSString *)filterString:(NSString *)string target:(NSString *)target{
    NSString *tempString = string;
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:target];
    tempString = [[tempString componentsSeparatedByCharactersInSet: doNotWant]componentsJoinedByString:@""];
    return tempString;
}

#pragma mark - 正则相关
+ (BOOL)isValidate:(NSString *)text regex:(NSString *)regex {
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pre evaluateWithObject:text];
}

/** 手机号有效性 */
+ (BOOL)isMobileNumber:(NSString *)text {
    /**
     *  手机号以13、15、18、170开头，8个 \d 数字字符
     *  小灵通 区号：010,020,021,022,023,024,025,027,028,029 还有未设置的新区号xxx
     */
    NSString *phoneRegex = @"^(13[0-9]|14[579]|15[0-3,5-9]|17[0135678]|18[0-9])\\d{8}$";
    NSString *phsRegex =@"^0(10|2[0-57-9]|\\d{3})\\d{7,8}$";
    
    BOOL ret = [self isValidate:text regex:phoneRegex];
    BOOL ret1 = [self isValidate:text regex:phsRegex];
    
    return (ret || ret1);
    
}

/** 邮箱的有效性 */
+ (BOOL)isEmail:(NSString *)text {
    
    NSString *emailRegex = @"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    return [self isValidate:text regex:emailRegex];
}

/** 车牌号的有效性 */
+ (BOOL)isCarNumber:(NSString *)text {
    
    /*
     车牌号:湘K-DE829 香港车牌号码:粤Z-J499港
     其中\u4e00-\u9fa5表示unicode编码中汉字已编码部分，\u9fa5-\u9fff是保留部分，将来可能会添加
     */
    NSString *carRegex = @"^[\u4e00-\u9fff]{1}[a-zA-Z]{1}[-][a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fff]$";
    return [self isValidate:text regex:carRegex];
}

/** 银行卡号有效性问题Luhn算法
 *  现行 16 位银联卡现行卡号开头 6 位是 622126～622925 之间的，7 到 15 位是银行自定义的，
 *  可能是发卡分行，发卡网点，发卡序号，第 16 位是校验码。
 *  16 位卡号校验位采用 Luhm 校验方法计算：
 *  1，将未带校验位的 15 位卡号从右依次编号 1 到 15，位于奇数位号上的数字乘以 2
 *  2，将奇位乘积的个十位全部相加，再加上所有偶数位上的数字
 *  3，将加法和加上校验位能被 10 整除。
 */
+ (BOOL)isValidBankCard:(NSString *)text {
    
    NSString *lastNum = [[text substringFromIndex:(text.length-1)] copy];//取出最后一位
    NSString *forwardNum = [[text substringToIndex:(text.length -1)] copy];//前15或18位
    
    NSMutableArray * forwardArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<forwardNum.length; i++) {
        NSString * subStr = [forwardNum substringWithRange:NSMakeRange(i, 1)];
        [forwardArr addObject:subStr];
    }
    
    NSMutableArray * forwardDescArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = (int)(forwardArr.count-1); i> -1; i--) {//前15位或者前18位倒序存进数组
        [forwardDescArr addObject:forwardArr[i]];
    }
    
    NSMutableArray * arrOddNum = [[NSMutableArray alloc] initWithCapacity:0];//奇数位*2的积 < 9
    NSMutableArray * arrOddNum2 = [[NSMutableArray alloc] initWithCapacity:0];//奇数位*2的积 > 9
    NSMutableArray * arrEvenNum = [[NSMutableArray alloc] initWithCapacity:0];//偶数位数组
    
    for (int i=0; i< forwardDescArr.count; i++) {
        NSInteger num = [forwardDescArr[i] intValue];
        if (i%2) {//偶数位
            [arrEvenNum addObject:[NSNumber numberWithInteger:num]];
        }else{//奇数位
            if (num * 2 < 9) {
                [arrOddNum addObject:[NSNumber numberWithInteger:num * 2]];
            }else{
                NSInteger decadeNum = (num * 2) / 10;
                NSInteger unitNum = (num * 2) % 10;
                [arrOddNum2 addObject:[NSNumber numberWithInteger:unitNum]];
                [arrOddNum2 addObject:[NSNumber numberWithInteger:decadeNum]];
            }
        }
    }
    
    __block  NSInteger sumOddNumTotal = 0;
    [arrOddNum enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumOddNumTotal += [obj integerValue];
    }];
    
    __block NSInteger sumOddNum2Total = 0;
    [arrOddNum2 enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumOddNum2Total += [obj integerValue];
    }];
    
    __block NSInteger sumEvenNumTotal =0 ;
    [arrEvenNum enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL *stop) {
        sumEvenNumTotal += [obj integerValue];
    }];
    
    NSInteger lastNumber = [lastNum integerValue];
    
    NSInteger luhmTotal = lastNumber + sumEvenNumTotal + sumOddNum2Total + sumOddNumTotal;
    
    return (luhmTotal%10 ==0)?YES:NO;
}

/** IP地址有效性 */
+ (BOOL)isIPAddress:(NSString *)text {
    
    NSString *regex = [NSString stringWithFormat:@"^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$"];
    BOOL rc = [self isValidate:text regex:regex];
    
    if (rc) {
        NSArray *componds = [text componentsSeparatedByString:@","];
        
        BOOL v = YES;
        for (NSString *s in componds) {
            if (s.integerValue > 255) {
                v = NO;
                break;
            }
        }
        return v;
    }
    return NO;
}

/** Mac地址有效性 */
+ (BOOL)isMacAddress:(NSString *)text {
    
    NSString * macAddRegex = @"([A-Fa-f\\d]{2}:){5}[A-Fa-f\\d]{2}";
    return  [self isValidate:text regex:macAddRegex];
}

/** 网址有效性 */
+ (BOOL)isValidUrl:(NSString *)text {
    
    NSString *regex = @"^((http)|(https))+:[^\\s]+\\.[^\\s]*$";
    return [self isValidate:text regex:regex];
}

/** 纯汉字 */
+ (BOOL)isValidChinese:(NSString *)text {
    
    NSString *chineseRegex = @"^[\u4e00-\u9fa5]+$";
    return [self isValidate:text regex:chineseRegex];
}

/** 邮政编码 */
+ (BOOL)isValidPostcode:(NSString *)text {
    
    NSString *postalRegex = @"^[0-8]\\d{5}(?!\\d)$";
    return [self isValidate:text regex:postalRegex];
}

/** 工商税号 */
+ (BOOL)isValidTaxNumber:(NSString *)text {
    
    NSString *taxNoRegex = @"[0-9]\\d{13}([0-9]|X)$";
    return [self isValidate:text regex:taxNoRegex];
}

/** 简单的身份证有效性 */
+ (BOOL)simpleVerifyIDCardNumber:(NSString *)text {
    
    NSString *regex = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    return [self isValidate:text regex:regex];
}

/** 精确的身份证号码有效性检测
 
 *  @param text 身份证号
 */
+ (BOOL)accurateVerifyIDCardNumber:(NSString *)text {
    
    
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    int length =0;
    if (!text) {
        return NO;
    }else {
        length = (int)text.length;
        
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [text substringToIndex:2];
    BOOL areaFlag =NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return false;
    }
    
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;
    switch (length) {
        case 15:
            year = [text substringWithRange:NSMakeRange(6,2)].intValue +1900;
            
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];//测试出生日期的合法性
            } else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive
                                                                          error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:text
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, text.length)];
            
            if(numberofMatch >0) {
                return YES;
            }else {
                return NO;
            }
        case 18:
            year = [text substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];//测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];//测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:text
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, text.length)];
            
            if(numberofMatch >0) {
                int S = ([text substringWithRange:NSMakeRange(0,1)].intValue + [text substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([text substringWithRange:NSMakeRange(1,1)].intValue + [text substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([text substringWithRange:NSMakeRange(2,1)].intValue + [text substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([text substringWithRange:NSMakeRange(3,1)].intValue + [text substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([text substringWithRange:NSMakeRange(4,1)].intValue + [text substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([text substringWithRange:NSMakeRange(5,1)].intValue + [text substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([text substringWithRange:NSMakeRange(6,1)].intValue + [text substringWithRange:NSMakeRange(16,1)].intValue) *2 + [text substringWithRange:NSMakeRange(7,1)].intValue *1 + [text substringWithRange:NSMakeRange(8,1)].intValue *6 + [text substringWithRange:NSMakeRange(9,1)].intValue *3;
                int Y = S %11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                if ([M isEqualToString:[text substringWithRange:NSMakeRange(17,1)]]) {
                    return YES;// 检测ID的校验位
                }else {
                    return NO;
                }
                
            }else {
                return NO;
            }
        default:
            return NO;
    }
}

/**
 @brief     是否符合最小长度、最长长度，是否包含中文,首字母是否可以为数字
 
 @param     text     文本
 @param     minLenth 账号最小长度
 @param     maxLenth 账号最长长度
 @param     chinese  是否包含中文
 @param     firstNotDigtal 首字母不能为数字
 @return    正则验证成功返回YES, 否则返回NO
 */
+ (BOOL)isValidText:(NSString *)text
           minLenth:(NSInteger)minLenth
           maxLenth:(NSInteger)maxLenth
            chinese:(BOOL)chinese
     firstNotDigtal:(BOOL)firstNotDigtal {
    
    //  [\u4e00-\u9fa5A-Za-z0-9_]{4,20}
    NSString *hanzi = chinese ? @"\u4e00-\u9fa5" : @"";
    NSString *first = firstNotDigtal ? @"^[a-zA-Z_]" : @"";
    
    NSString *regex = [NSString stringWithFormat:@"%@[%@A-Za-z0-9_]{%d,%d}", first, hanzi, (int)(minLenth-1), (int)(maxLenth-1)];
    return [self isValidate:text regex:regex];
}

/**
 @brief     是否符合最小长度、最长长度，是否包含中文,数字，字母，其他字符，首字母是否可以为数字
 
 @param     text     文本
 @param     minLenth 账号最小长度
 @param     maxLenth 账号最长长度
 @param     chinese  是否包含中文
 @param     digtal   包含数字
 @param     letter   包含字母
 @param     otherCharacter 包含其他字符
 @param     firstNotDigtal 首字母不能为数字
 
 @return    正则验证成功返回YES, 否则返回NO
 */
+ (BOOL)isValidText:(NSString *)text
           minLenth:(NSInteger)minLenth
           maxLenth:(NSInteger)maxLenth
            chinese:(BOOL)chinese
             digtal:(BOOL)digtal
             letter:(BOOL)letter
     otherCharacter:(NSString *)otherCharacter
     firstNotDigtal:(BOOL)firstNotDigtal {
    
    NSString *hanzi = chinese ? @"\u4e00-\u9fa5" : @"";
    NSString *first = firstNotDigtal ? @"^[a-zA-Z_]" : @"";
    NSString *lengthRegex = [NSString stringWithFormat:@"(?=^.{%@,%@}$)", @(minLenth), @(maxLenth)];
    NSString *digtalRegex = digtal ? @"(?=(.*\\d.*){1})" : @"";
    NSString *letterRegex = letter ? @"(?=(.*[a-zA-Z].*){1})" : @"";
    NSString *characterRegex = [NSString stringWithFormat:@"(?:%@[%@A-Za-z0-9%@]+)", first, hanzi, otherCharacter ? otherCharacter : @""];
    NSString *regex = [NSString stringWithFormat:@"%@%@%@%@", lengthRegex, digtalRegex, letterRegex, characterRegex];
    return [self isValidate:text regex:regex];
}


+ (NSString *)emojiWithIntCode:(int)intCode {
    
    int symbol = EmojiCodeToSymbol(intCode);
    NSString *string = [[NSString alloc] initWithBytes:&symbol length:sizeof(symbol) encoding:NSUTF8StringEncoding];
    if (string == nil) { // 新版Emoji
        string = [NSString stringWithFormat:@"%C", (unichar) intCode];
    }
    return string;
}


+ (NSString *)emojiWithStringCode:(NSString *)stringCode {
    
    char *charCode = (char *) stringCode.UTF8String;
    int intCode = (int) strtol(charCode, NULL, 16);
    return [self emojiWithIntCode:intCode];
}

// 判断是否是 emoji表情
+ (BOOL)isEmoji:(NSString *)emoji {
    BOOL returnValue = NO;
    
    const unichar hs = [emoji characterAtIndex:0];
    // surrogate pair
    if (0xd800 <= hs && hs <= 0xdbff) {
        if (emoji.length > 1) {
            const unichar ls = [emoji characterAtIndex:1];
            const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
            if (0x1d000 <= uc && uc <= 0x1f77f) {
                returnValue = YES;
            }
        }
    } else if (emoji.length > 1) {
        const unichar ls = [emoji characterAtIndex:1];
        if (ls == 0x20e3) {
            returnValue = YES;
        }
    } else {
        // non surrogate
        if (0x2100 <= hs && hs <= 0x27ff) {
            returnValue = YES;
        } else if (0x2B05 <= hs && hs <= 0x2b07) {
            returnValue = YES;
        } else if (0x2934 <= hs && hs <= 0x2935) {
            returnValue = YES;
        } else if (0x3297 <= hs && hs <= 0x3299) {
            returnValue = YES;
        } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
            returnValue = YES;
        }
    }
    
    return returnValue;
}

//去掉 表情符号
+ (NSString *)disableEmoji:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

#pragma mark - 其他

/// 首字母大写
/// @param text 文本
+ (NSString *)capitalizedString:(NSString *)text
{
    if (text.length)
        return [NSString stringWithFormat:@"%@%@", [text substringToIndex:1].uppercaseString, [text substringFromIndex:1]].copy;
    return nil;
}

/// 按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
/// @param text 其他
+ (NSUInteger)countingTextLength:(NSString *)text
{
    NSUInteger length = 0;
    for (NSUInteger i = 0, l = text.length; i < l; i++) {
        unichar character = [text characterAtIndex:i];
        if (isascii(character)) {
            length += 1;
        } else {
            length += 2;
        }
    }
    return length;
}

@end
