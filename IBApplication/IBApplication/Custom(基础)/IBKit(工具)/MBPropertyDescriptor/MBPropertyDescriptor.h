//
//  MBPropertyDescriptor.h
//  IBApplication
//
//  Created by Bowen on 2020/3/30.
//  Copyright © 2020 BowenCoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBPropertyDescriptor : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) SEL getter;
@property(nonatomic, assign) SEL setter;

@property(nonatomic, assign) BOOL isAtomic;
@property(nonatomic, assign) BOOL isNonatomic;

@property(nonatomic, assign) BOOL isAssign;
@property(nonatomic, assign) BOOL isWeak;
@property(nonatomic, assign) BOOL isStrong;
@property(nonatomic, assign) BOOL isCopy;

@property(nonatomic, assign) BOOL isReadonly;
@property(nonatomic, assign) BOOL isReadwrite;

@property(nonatomic, copy) NSString *type;

+ (instancetype)descriptorWithProperty:(objc_property_t)property;

@end

NS_ASSUME_NONNULL_END
