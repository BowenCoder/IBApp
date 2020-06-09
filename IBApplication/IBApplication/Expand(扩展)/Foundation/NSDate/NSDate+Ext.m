//
//  NSDate+Ext.m
//  IBApplication
//
//  Created by Bowen on 2018/6/25.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import "NSDate+Ext.h"

#define IBTimeSecondsPerMinute    60
#define IBTimeSecondsPerHour      60*60
#define IBTimeSecondsPerDay       60*60*24
#define IBTimeSecondsPerWeek      60*60*24*7
#define IBTimeSecondsPerYear      31556926 //回归年(365天5时48分46秒)

#ifndef NSDateTimeAgoLocalizedStrings
#define NSDateTimeAgoLocalizedStrings(key) \
NSLocalizedStringFromTableInBundle(key, @"NSDateTimeAgo", [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"NSDateTimeAgo.bundle" ofType:nil]], nil)
#endif

static const unsigned unitFlags = (NSCalendarUnitYear| NSCalendarUnitMonth| NSCalendarUnitDay| NSCalendarUnitWeekOfYear| NSCalendarUnitWeekOfMonth| NSCalendarUnitHour| NSCalendarUnitMinute| NSCalendarUnitSecond| NSCalendarUnitWeekday| NSCalendarUnitWeekdayOrdinal);

@implementation NSDate (Ext)

//当前日历
+ (NSCalendar *)currentCalendar {
    
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar)
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    return sharedCalendar;
}

//日期信息
- (IBDateInfo)mb_dateInfo {
    
    IBDateInfo info;
    NSDateComponents *components = [[NSDate currentCalendar] components:unitFlags fromDate:self];
    info.year           = components.year;
    info.month          = components.month;
    info.day            = components.day;
    info.hour           = components.hour;
    info.minute         = components.minute;
    info.seconds        = components.second;
    info.nanosecond     = components.nanosecond;
    info.weekday        = components.weekday;
    info.weekOfYear     = components.weekOfYear;
    info.weekOfMonth    = components.weekOfMonth;
    
    return info;
}

//获取时间戳
- (NSTimeInterval)mb_timestamp {
    return [self timeIntervalSince1970];
}

//毫秒：时间戳*1000
- (NSTimeInterval)mb_microsecond {
    return [self timeIntervalSince1970] * 1000.f;
}

+ (NSString *)mb_timestampFormat:(NSInteger)interval {
    
    int hour = (int)(interval / 3600);
    int min = (interval % 3600) / 60;
    int second = interval % 60;
    NSString *h = [NSString stringWithFormat:@"%02d", hour];
    NSString *m = [NSString stringWithFormat:@"%02d", min];
    NSString *s = [NSString stringWithFormat:@"%02d", second];
    
    if ([h isEqualToString:@"00"]) {
        return [NSString stringWithFormat:@"%@:%@", m, s];
    }
    return [NSString stringWithFormat:@"%@:%@:%@", h, m, s];
}

//时间戳转换成日期
+ (NSDate *)mb_timestampToDate:(NSInteger)timestamp {
    
    if (timestamp / 1000000000 > 10) {
        // 毫秒级时间戳->秒
        timestamp = timestamp / 1000;
    }
    return [NSDate dateWithTimeIntervalSince1970:timestamp];
}

//时间戳转换成时间字符串
+ (NSString *)mb_timestampToTime:(NSInteger)timestamp formatter:(NSString *)format {
    
    if (timestamp / 1000000000 > 10) {
        // 毫秒级时间戳->秒
        timestamp = timestamp / 1000;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format]; //（@"YYYY-MM-dd hh:mm:ss"）-----设置格式,hh与HH的区别:分别表示12小时制,24小时制
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [formatter setTimeZone:timeZone];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    return confromTimespStr;
}

//日期字符串转换成日期
+ (NSDate *)mb_dateWithString:(NSString *)dateString formatter:(NSString *)format {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format]; //（@"YYYY-MM-dd hh:mm:ss"）-----设置格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];

    return [formatter dateFromString:dateString];

}

//显示时间
+ (NSString *)mb_displayHalfDay:(NSDate *)date formatter:(NSString *)format {
    
    if (format == nil) {
        format = @"aaahh:ss";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    IBDateInfo info = [date mb_dateInfo];
    
    if (info.hour >= 0  && info.hour < 6) {
        formatter.AMSymbol = @"凌晨";
    }
    if (info.hour >= 6  && info.hour < 12) {
        formatter.AMSymbol = @"上午";
    }
    if (info.hour >= 12  && info.hour < 19) {
        formatter.AMSymbol = @"下午";
    }
    if (info.hour >= 19  && info.hour < 24) {
        formatter.AMSymbol = @"晚上";
    }

    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat: format];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    return [formatter stringFromDate:date];

}

+ (NSString *)mb_displayWeek:(NSDate *)date {
    
    IBDateInfo info = [date mb_dateInfo];
    if (info.weekday == 1) {
        return NSDateTimeAgoLocalizedStrings(@"Sunday");
    }
    if (info.weekday == 2) {
        return NSDateTimeAgoLocalizedStrings(@"Monday");
    }
    if (info.weekday == 3) {
        return NSDateTimeAgoLocalizedStrings(@"Tuesday");
    }
    if (info.weekday == 4) {
        return NSDateTimeAgoLocalizedStrings(@"Wednesday");
    }
    if (info.weekday == 5) {
        return NSDateTimeAgoLocalizedStrings(@"Thursday");
    }
    if (info.weekday == 6) {
        return NSDateTimeAgoLocalizedStrings(@"Friday");
    }
    if (info.weekday == 7) {
        return NSDateTimeAgoLocalizedStrings(@"Saturday");
    }
    
    return nil;
}

- (NSString *)mb_constellation {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *birthStr = [formatter stringFromDate:self];
    
    //将获取的时间转换为数组
    NSArray *birthArr = [birthStr componentsSeparatedByString:@"-"];
    
    //获取月份和日期
    NSInteger mouth = [[birthArr objectAtIndex:1] integerValue];
    NSInteger day = [[birthArr objectAtIndex:2] integerValue];
    
    NSString *constellationStr;
    //根据日子得到相应的星座
    switch (mouth) {
        case 1:
            if (day > 0 && day < 20) {
                constellationStr = @"摩羯座";
            } else {
                constellationStr = @"水瓶座";
            }
            break;
        case 2:
            if (day > 0 && day < 19) {
                constellationStr = @"水瓶座";
            } else {
                constellationStr = @"双鱼座";
            }
            break;
        case 3:
            if (day > 0 && day < 21) {
                constellationStr = @"双鱼座";
            } else {
                constellationStr = @"白羊座";
            }
            break;
        case 4:
            if (day > 0 && day < 20) {
                constellationStr = @"白羊座";
            } else {
                constellationStr = @"金牛座";
            }
            break;
        case 5:
            if (day > 0 && day < 21) {
                constellationStr = @"金牛座";
            } else {
                constellationStr = @"双子座";
            }
            break;
        case 6:
            if (day > 0 && day < 22) {
                constellationStr = @"双子座";
            } else {
                constellationStr = @"巨蟹座";
            }
            break;
        case 7:
            if (day > 0 && day < 23) {
                constellationStr = @"巨蟹座";
            } else {
                constellationStr = @"狮子座";
            }
            break;
        case 8:
            if (day > 0 && day < 23) {
                constellationStr = @"狮子座";
            } else {
                constellationStr = @"处女座";
            }
            break;
        case 9:
            if (day > 0 && day < 23) {
                constellationStr = @"处女座";
            } else {
                constellationStr = @"天秤座";
            }
            break;
            
        case 10:
            if (day > 0 && day < 24) {
                constellationStr = @"天秤座";
            } else {
                constellationStr = @"天蝎座";
            }
            break;
        case 11:
            if (day > 0 && day < 23) {
                constellationStr = @"天蝎座";
            } else {
                constellationStr = @"射手座";
            }
            break;
        case 12:
            if (day > 0 && day < 22) {
                constellationStr = @"射手座";
            } else {
                constellationStr = @"摩羯座";
            }
            break;
        default:
            break;
    }
    return constellationStr;
}

@end


@implementation NSDate (Date)

/**
 改变时间

 @param times 时间
 @param option 决定改变是年月日还是时份周
 @return 返回改变后的时间
 */
- (NSDate *)mb_dateAlterTimes:(NSInteger)times option:(IBTimeOption)option {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    switch (option) {
        case IBTimeOptionYear:
            [components setYear:times];
            break;
        case IBTimeOptionMonth:
            [components setMonth:times];
            break;
        case IBTimeOptionDay:
            [components setDay:times];
            break;
        case IBTimeOptionWeek:
            [components setWeekOfYear:times];
            break;
        case IBTimeOptionHour:
            [components setHour:times];
            break;
        case IBTimeOptionMinute:
            [components setMinute:times];
            break;
        default:
            break;
    }
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self options:0];
    return newDate;
}

- (NSDate *)mb_dateAtStartOfDay {
    
    NSDateComponents *components = [[NSDate currentCalendar] components:unitFlags fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

- (NSDate *)mb_dateAtEndOfDay {
    
    NSDateComponents *components = [[NSDate currentCalendar] components:unitFlags fromDate:self];
    components.hour = 23; // Thanks Aleksey Kononov
    components.minute = 59;
    components.second = 59;
    return [[NSDate currentCalendar] dateFromComponents:components];
}

+ (NSDate *)mb_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    
    NSDate *newDate = nil;
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year   = year;
    components.month  = month;
    components.day    = day;
    components.hour   = hour;
    components.minute = minute;
    components.second = second;
    
    newDate = [[self currentCalendar] dateFromComponents:components];
    
    return newDate;
}

@end

@implementation NSDate (Compare)

- (BOOL)isEqualTime:(NSDate *)date interval:(NSInteger)interval option:(IBTimeOption)option {
    
    IBDateInfo currentInfo = [self mb_dateInfo];
    IBDateInfo dateInfo = [date mb_dateInfo];
    
    if (option == IBTimeOptionYear) {
        return currentInfo.year == dateInfo.year + interval;
    }
    if (option == IBTimeOptionMonth) {
        return (currentInfo.year == dateInfo.year) && (currentInfo.month == dateInfo.month + interval);
    }
    if (option == IBTimeOptionWeek) { //元旦时可能出现bug
        return currentInfo.weekOfYear == dateInfo.weekOfYear + interval;
    }
    if (option == IBTimeOptionDay) {
        return ((currentInfo.year  == dateInfo.year) &&
                (currentInfo.month == dateInfo.month) &&
                (currentInfo.day   == dateInfo.day + interval));
    }
    if (option == IBTimeOptionHour) {
        return ((currentInfo.year  == dateInfo.year) &&
                (currentInfo.month == dateInfo.month) &&
                (currentInfo.day   == dateInfo.day) &&
                (currentInfo.hour  == dateInfo.hour + interval));
    }

    return NO;
}

- (BOOL)isToday {
    
    NSDate *date = [NSDate date];
    return [self isEqualTime:date interval:0 option:IBTimeOptionDay];
}

- (BOOL)isTomorrow {
    
    NSDate *date = [NSDate date];
    return [self isEqualTime:date interval:1 option:IBTimeOptionDay];
}

- (BOOL)isYesterday {
    
    NSDate *date = [NSDate date];
    return [self isEqualTime:date interval:-1 option:IBTimeOptionDay];
}

- (BOOL)isThisWeek {
    
    NSDate *date = [NSDate date];
    return [self isEqualTime:date interval:0 option:IBTimeOptionWeek];
}

- (BOOL)isNextWeek {
    
    NSDate *date = [NSDate date];
    return [self isEqualTime:date interval:1 option:IBTimeOptionWeek];
}

- (BOOL)isLastWeek {
    
    NSDate *date = [NSDate date];
    return [self isEqualTime:date interval:-1 option:IBTimeOptionWeek];
}

- (BOOL)isThisMonth {
    
    NSDate *date = [NSDate date];
    return [self isEqualTime:date interval:0 option:IBTimeOptionMonth];
}

- (BOOL)isLastMonth {
    
    NSDate *date = [NSDate date];
    return [self isEqualTime:date interval:-1 option:IBTimeOptionMonth];
}

- (BOOL)isNextMonth {
    
    NSDate *date = [NSDate date];
    return [self isEqualTime:date interval:1 option:IBTimeOptionMonth];
}

- (BOOL)isThisYear {
    
    NSDate *date = [NSDate date];
    return [self isEqualTime:date interval:0 option:IBTimeOptionYear];
}

- (BOOL)isNextYear {
    
    NSDate *date = [NSDate date];
    return [self isEqualTime:date interval:1 option:IBTimeOptionYear];
}

- (BOOL)isLastYear {
    
    NSDate *date = [NSDate date];
    return [self isEqualTime:date interval:-1 option:IBTimeOptionYear];
}

- (BOOL)isEarlierThanDate:(NSDate *)date {
    
    return ([self compare:date] == NSOrderedAscending);
}

- (BOOL)isLaterThanDate:(NSDate *)date {
    
    return ([self compare:date] == NSOrderedDescending);
}

// Thanks, markrickert
- (BOOL)isInFuture {
    
    return ([self isLaterThanDate:[NSDate date]]);
}

// Thanks, markrickert
 - (BOOL)isInPast {
     
    return ([self isEarlierThanDate:[NSDate date]]);
}

- (BOOL)isWithinDays:(NSInteger)days {
    
    NSDate *nowDate = [NSDate date];
    double seconds = fabs([self timeIntervalSinceDate:nowDate]);
    if (seconds < IBTimeSecondsPerDay * days) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Roles
- (BOOL)isTypicallyWeekend {
    
    IBDateInfo currentInfo = [self mb_dateInfo];

    if ((currentInfo.weekday == 1) || (currentInfo.weekday == 7)) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isTypicallyWorkday {
    
    return ![self isTypicallyWeekend];
}

@end

@implementation NSDate (TimeAgo)

- (NSString *)mb_timeAgo {
    
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([self timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    int minutes;
    
    if(deltaSeconds < 5) {
        return NSDateTimeAgoLocalizedStrings(@"Just now");
    }
    else if(deltaSeconds < 60) {
        return [self stringFromFormat:@"%%d %@seconds ago" withValue:deltaSeconds];
    }
    else if(deltaSeconds < 120) {
        return NSDateTimeAgoLocalizedStrings(@"A minute ago");
    }
    else if (deltaMinutes < 60) {
        return [self stringFromFormat:@"%%d %@minutes ago" withValue:deltaMinutes];
    }
    else if (deltaMinutes < 120) {
        return NSDateTimeAgoLocalizedStrings(@"An hour ago");
    }
    else if (deltaMinutes < (24 * 60)) {
        minutes = (int)floor(deltaMinutes/60);
        return [self stringFromFormat:@"%%d %@hours ago" withValue:minutes];
    }
    else if (deltaMinutes < (24 * 60 * 2)) {
        return NSDateTimeAgoLocalizedStrings(@"Yesterday");
    }
    else if (deltaMinutes < (24 * 60 * 7)) {
        minutes = (int)floor(deltaMinutes/(60 * 24));
        return [self stringFromFormat:@"%%d %@days ago" withValue:minutes];
    }
    else if (deltaMinutes < (24 * 60 * 7 * 2)) {
        return NSDateTimeAgoLocalizedStrings(@"Last week");
    }
    else if (deltaMinutes < (24 * 60 * 7 * 3)) {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 7));
        return [self stringFromFormat:@"%%d %@weeks ago" withValue:minutes];
    }
    else if (deltaMinutes < (24 * 60 * (30 + 31))) {
        return NSDateTimeAgoLocalizedStrings(@"Last month");
    }
    else if (deltaMinutes < (24 * 60 * 365.25)) {
        minutes = (int)floor(deltaMinutes/(60 * 24 * 30));
        return [self stringFromFormat:@"%%d %@months ago" withValue:minutes];
    }
    else if (deltaMinutes < (24 * 60 * 731)) {
        return NSDateTimeAgoLocalizedStrings(@"Last year");
    }
    
    minutes = (int)floor(deltaMinutes/(60 * 24 * 365));
    return [self stringFromFormat:@"%%d %@years ago" withValue:minutes];
}

- (NSString *)mb_timeAgoSimple {
    
    NSDate *now = [NSDate date];
    NSDateComponents *components = [[NSDate currentCalendar] components:unitFlags fromDate:self toDate:now options:0];

    if (components.year >= 1) {
        if (components.year == 1) {
            return NSDateTimeAgoLocalizedStrings(@"1 year ago");
        }
        return [self stringFromFormat:@"%%d %@years ago" withValue:components.year];
    }
    else if (components.month >= 1) {
        if (components.month == 1) {
            return NSDateTimeAgoLocalizedStrings(@"1 month ago");
        }
        return [self stringFromFormat:@"%%d %@months ago" withValue:components.month];
    }
    else if (components.weekOfYear >= 1) {
        if (components.weekOfYear == 1) {
            return NSDateTimeAgoLocalizedStrings(@"1 week ago");
        }
        return [self stringFromFormat:@"%%d %@weeks ago" withValue:components.weekOfYear];
    }
    else if (components.day >= 1) { // up to 6 days ago
        if (components.day == 1) {
            return NSDateTimeAgoLocalizedStrings(@"1 day ago");
        }
        return [self stringFromFormat:@"%%d %@days ago" withValue:components.day];
    }
    else if (components.hour >= 1) { // up to 23 hours ago
        if (components.hour == 1) {
            return NSDateTimeAgoLocalizedStrings(@"An hour ago");
        }
        return [self stringFromFormat:@"%%d %@hours ago" withValue:components.hour];
    }
    else if (components.minute >= 1) {  // up to 59 minutes ago
        if (components.minute == 1) {
            return NSDateTimeAgoLocalizedStrings(@"A minute ago");
        }
        return [self stringFromFormat:@"%%d %@minutes ago" withValue:components.minute];
    }
    else if (components.second < 5) {
        return NSDateTimeAgoLocalizedStrings(@"Just now");
    }
    
    // between 5 and 59 seconds ago
    return [self stringFromFormat:@"%%d %@seconds ago" withValue:components.second];
}

- (NSString *)mb_timeAgoWithLimit:(NSTimeInterval)limit {
    
    if (fabs([self timeIntervalSinceDate:[NSDate date]]) <= limit)
        return [self mb_timeAgo];
    
    return [NSDateFormatter localizedStringFromDate:self
                                          dateStyle:NSDateFormatterMediumStyle
                                          timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)mb_displayTime {
    
    if ([self isToday]) {
        return [NSDate mb_displayHalfDay:self formatter:nil];
    }
    NSString *prefix;
    if ([self isYesterday]) {
        prefix = NSDateTimeAgoLocalizedStrings(@"Yesterday");
        return [NSString stringWithFormat:@"%@ %@",prefix,[NSDate mb_displayHalfDay:self formatter:nil]];
    }
    //7天以内
    if ([self isWithinDays:7]) {
        prefix = [NSDate mb_displayWeek:self];
        return [NSString stringWithFormat:@"%@ %@",prefix,[NSDate mb_displayHalfDay:self formatter:nil]];
    }
    
    return [NSDateFormatter localizedStringFromDate:self
                                          dateStyle:NSDateFormatterMediumStyle
                                          timeStyle:NSDateFormatterShortStyle];
}



- (NSString *)stringFromFormat:(NSString *)format withValue:(NSInteger)value {
    
    NSString *localeFormat = [NSString stringWithFormat:format, [self localeFormatUnderscoresWithValue:value]];
    return [NSString stringWithFormat:NSDateTimeAgoLocalizedStrings(localeFormat), value];
}

-(NSString *)localeFormatUnderscoresWithValue:(double)value {
    
    NSString *localeCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    // Russian (ru)
    if([localeCode hasPrefix:@"ru"] || [localeCode hasPrefix:@"uk"]) {
        int XY = (int)floor(value) % 100;
        int Y = (int)floor(value) % 10;
        
        if(Y == 0 || Y > 4 || (XY > 10 && XY < 15)) return @"";
        if(Y > 1 && Y < 5 && (XY < 10 || XY > 20))  return @"_";
        if(Y == 1 && XY != 11)                      return @"__";
    }
    
    return @"";
}



@end


