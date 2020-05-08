//
//  MBUserManager.m
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "MBUserManager.h"
#import "IBAtomFactory.h"
#import "IBSecurity.h"
#import "IBFile.h"
#import "MBLogger.h"
#import "IBMacros.h"

@interface MBUserManager ()

@property (nonatomic, strong) MBUserModel *user;

@end

@implementation MBUserManager

+ (instancetype)sharedManager
{
    static MBUserManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MBUserManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self restore];
    }
    return self;
}

/**
 从本地恢复数据
 */
- (void)restore
{
    NSString *lastUserPath = [self loginFile];
    if (![IBFile isFileExists:lastUserPath]) {
        return;
    }
    NSDictionary *uidDic    = [IBFile readFileAtPathAsDictionary:lastUserPath];
    NSString     *lastUid   = [uidDic valueForKey:@"uid"];
    NSString     *userFile  = [self userInfoFileName:lastUid];
    NSDictionary *userDic   = [IBFile readFileAtPathAsDictionary:userFile];
    MBUserModel  *userModel = [MBUserModel yy_modelWithDictionary:userDic];
    _user = userModel;
    [self refreshAtom];
}

- (BOOL)isLoginUser:(NSString *)uid
{
    return [_user.uid isEqualToString:uid];
}

- (void)updateLoginUser:(MBUserModel *)user
{
    _user = user;
    [self saveUserInfo];
}

- (void)refreshLoginUser:(dispatch_block_t)completion
{
    /*
     1、网络请求用户数据
     2、设置用户数据（[self setLoginUser:nil];）
     */
}

- (void)setLogin:(NSString *)uid session:(NSString *)session phoneNum:(MBPhoneNumber *)phoneNumber
{
    _user = [[MBUserModel alloc] init];
    _user.uid = uid;
    _user.session = NSStringNONil(session);
    _user.phoneNumber = phoneNumber;
    [self refreshAtom];
    [self saveUserInfo];
}

- (void)logout
{
    [[IBAtomFactory sharedInstance] clear];
    [self clear];
}

- (void)clear
{
    NSString *filePath = [self userInfoFileName:_user.uid];
    [IBFile removeItemAtPath:filePath error:nil];
    [IBFile removeItemAtPath:[self loginFile] error:nil];
    _user = nil;
    [self refreshAtom];
}

- (void)refreshAtom
{
    if (_user) {
        [[IBAtomFactory sharedInstance] updateUserId:_user.uid];
        [[IBAtomFactory sharedInstance] updateSessionId:_user.session];
    } else {
        [[IBAtomFactory sharedInstance] updateUserId:@""];
        [[IBAtomFactory sharedInstance] updateSessionId:@""];
    }
}

#pragma mark - 存储

- (void)saveUserInfo
{
    if (!_user || _user.uid == 0) {
        return;
    }
    NSMutableDictionary *userDic = [self.user yy_modelToJSONObject];
    NSString *filePath = [self userInfoFileName:self.user.uid];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [IBFile writeFileAtPath:filePath content:userDic error:nil];
    });
    [self saveLastUserWithDict:userDic];
    [self syncSharedData:userDic];
}

- (void)saveLastUserWithDict:(NSMutableDictionary *)userDic
{
    if (!_user || _user.uid == 0) {
        return;
    }
    NSString *fileName = [self loginFile];
    NSMutableDictionary *dict = @{}.mutableCopy;
    [dict setObject:userDic[@"uid"] forKey:@"uid"];
    [dict setObject:userDic[@"nick"] forKey:@"nick"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [IBFile writeFileAtPath:fileName content:dict error:nil];
    });
}

- (void)syncSharedData:(NSDictionary *)dic
{
    NSError *err = nil;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.bowen.coder"];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches/ext_shared_userinfo"];
    
    NSDictionary *dict;
    
    if (_user && _user.uid>0 && _user.session) {
        NSString *filePath = [self userInfoFileName:_user.uid];
        dict = [IBFile readFileAtPathAsDictionary:filePath];
    } else {
        dict = @{};
    }
    
    BOOL result = [dict writeToURL:containerURL atomically:YES];
    
    if (!result) {
        MBLogI(@"sync userinfo failed: %@",err);
    }
}

- (NSString *)userInfoFileName:(NSString *)uid
{
    NSString *filename = [NSString stringWithFormat:@"User/login_%@.plist", uid];
    return [IBFile filePathInLibrary:filename];
}

- (NSString *)loginFile
{
    return [IBFile filePathInLibrary:@"User/login_uid.plist"];
}

#pragma mark - getter

- (MBUserModel *)loginUser
{
    return _user;
}

- (BOOL)isLogin
{
    return _user && _user.session;
}

@end
