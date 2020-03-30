//
//  MBInline.h
//  IBApplication
//
//  Created by Bowen on 2020/3/30.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#ifndef MBInline_h
#define MBInline_h

#import "IBString.h"

/**
 根据给定的 getter selector 获取对应的 setter selector
 @param getter 目标 getter selector
 @return 对应的 setter selector
 */
CG_INLINE SEL
setterWithGetter(SEL getter)
{
    NSString *getterString = NSStringFromSelector(getter);
    NSMutableString *setterString = [[NSMutableString alloc] initWithString:@"set"];
    [setterString appendString:[IBString capitalizedString:getterString]];
    [setterString appendString:@":"];
    SEL setter = NSSelectorFromString(setterString);
    return setter;
}

#endif /* MBInline_h */
