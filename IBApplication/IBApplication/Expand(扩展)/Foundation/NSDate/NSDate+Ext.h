//
//  NSDate+Ext.h
//  IBApplication
//
//  Created by Bowen on 2018/6/25.
//  Copyright © 2018年 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>

//用于获取日期的详细信息
 struct IBDateInfo {
    NSInteger year, month, day;//年月日
    NSInteger hour, minute, seconds, nanosecond;//时分秒纳秒
    NSInteger weekday, weekOfYear, weekOfMonth;//周，一年第几周，一月第几周
};
typedef struct IBDateInfo IBDateInfo;

//时间类型
typedef NS_ENUM(NSInteger, IBTimeOption) {
    IBTimeOptionYear, //年
    IBTimeOptionMonth, //月
    IBTimeOptionWeek, //周
    IBTimeOptionDay, //日
    IBTimeOptionHour, //小时
    IBTimeOptionMinute//分钟
};

@interface NSDate (Ext)

/**
 获取日期详细信息

 @return 时间信息
 */
- (IBDateInfo)mb_dateInfo;

/**
 获取时间戳，建议使用

 @return 返回时间戳
 */
- (NSTimeInterval)mb_timestamp;

/**
 获取时间戳（毫秒）
 
 @return 返回时间戳
 */
- (NSTimeInterval)mb_microsecond;

/**
 把一段时间间隔按"时：分：秒"的格式显示
 */
+ (NSString *)mb_timestampFormat:(NSInteger)interval;

/**
 时间戳转化成日期

 @param timestamp 时间戳(默认从1970年开始)
 @return 日期
 */
+ (NSDate *)mb_timestampToDate:(NSInteger)timestamp;

/**
 时间戳转换成日期字符串

 @param timestamp 时间戳
 @param format 时间格式 例如,YYYY-MM-dd HH:mm:ss
 @return 日期字符串
 */
+ (NSString *)mb_timestampToTime:(NSInteger)timestamp formatter:(NSString *)format;

/**
 日期字符串转换成日期
 
 @param dateString 时间字符串
 @param format 时间格式 例如,YYYY-MM-dd HH:mm:ss
 @return 字符串时间
 */
+ (NSDate *)mb_dateWithString:(NSString *)dateString formatter:(NSString *)format;

/**
 显示上下午+时分

 @param date 日期
 @param format 要显示格式
 @return 上下午+时分的字符串
 */
+ (NSString *)mb_displayHalfDay:(NSDate *)date formatter:(NSString *)format;

/**
 显示星期几

 @param date 日期
 @return 星期字符串
 */
+ (NSString *)mb_displayWeek:(NSDate *)date;

/**
 星座
 */
- (NSString *)mb_constellation;

@end

@interface NSDate (Date)

/**
 改变时间
 
 @param times 时间(正数代表以后时间，负数代表以前时间)
 @param option 决定改变是年月日还是时份周
 @return 返回改变后的时间
 */
- (NSDate *)mb_dateAlterTimes:(NSInteger)times option:(IBTimeOption)option;

/**
 时间初始化

 @param year 年
 @param month 月
 @param day 日
 @param hour 时
 @param minute 分
 @param second 秒
 @return 时间
 */
+ (NSDate *)mb_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

/**
 一天开始的时候

 @return 日期
 */
- (NSDate *)mb_dateAtStartOfDay;

/**
 一天结束的时候

 @return 日期
 */
- (NSDate *)mb_dateAtEndOfDay;

@end

@interface NSDate (Compare)

//今天
- (BOOL)isToday;
//明天
- (BOOL)isTomorrow;
//昨天
- (BOOL)isYesterday;
//这周
- (BOOL)isThisWeek;
//下周
- (BOOL)isNextWeek;
//上周
- (BOOL)isLastWeek;
//这个月
- (BOOL)isThisMonth;
//下个月
- (BOOL)isNextMonth;
//上个月
- (BOOL)isLastMonth;
//今年
- (BOOL)isThisYear;
//明年
- (BOOL)isNextYear;
//去年
- (BOOL)isLastYear;
//将来
- (BOOL)isInFuture;
//以前
- (BOOL)isInPast;

//工作日
- (BOOL)isTypicallyWorkday;
//周末
- (BOOL)isTypicallyWeekend;

//多少天之内
- (BOOL)isWithinDays:(NSInteger)days;
//什么日期以前
- (BOOL)isLaterThanDate:(NSDate *)date;
//什么日期以后
- (BOOL)isEarlierThanDate:(NSDate *)date;

/**
 判断时间是否相等
 
 @param date 传入日期
 @param interval 和date时间间隔
 @param option  1、决定判断是年月日时周哪个相等 2、决定interval是年月日时周
 @return 是否相等
 */
- (BOOL)isEqualTime:(NSDate *)date interval:(NSInteger)interval option:(IBTimeOption)option;

@end

@interface NSDate (TimeAgo)


/**
 定制日期展示（仿微信消息时间）

 @return 时间字符串
 */
- (NSString *)mb_displayTime;

/**
 显示过去多久时间
 像：“刚刚”，“30秒前”，“5分钟前”，“昨天”，“上个月”，“2年前”
 
 @return 时间字符串
 */
- (NSString *)mb_timeAgo;

/**
 显示过去多久时间
 像：“刚刚”，“30秒前”，“5分钟前”，“2年前”

 @return 时间字符串
 */
- (NSString *)mb_timeAgoSimple;

/**
 限制多少时间以内显示过去多久时间，以外显示日期

 @param limit 时间戳
 @return 时间字符串
 */
- (NSString *)mb_timeAgoWithLimit:(NSTimeInterval)limit;

@end




