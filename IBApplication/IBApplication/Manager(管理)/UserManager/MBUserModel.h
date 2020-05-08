//
//  MBUserModel.h
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBModel.h"
#import "MBPhoneNumber.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBUserModel : IBModel

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *session;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *portrait;
@property (nonatomic, copy) NSString *birth;
@property (nonatomic, copy) MBPhoneNumber *phoneNumber;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) CGFloat lat;
@property (nonatomic, assign) CGFloat lng;

@end

NS_ASSUME_NONNULL_END
