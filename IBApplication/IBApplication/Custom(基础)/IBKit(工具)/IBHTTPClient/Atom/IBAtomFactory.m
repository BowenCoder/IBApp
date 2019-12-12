//
//  IBAtomFactory.m
//  IBApplication
//
//  Created by Bowen on 2019/5/27.
//  Copyright © 2019 BowenCoder. All rights reserved.
//

#import "IBAtomFactory.h"
#import "IBNetworkConfig.h"

@interface IBAtomFactory ()

@property (nonatomic, strong) IBAtomInfo *atom;
@property (nonatomic) dispatch_queue_t serialQueue;

@end

@implementation IBAtomFactory

+ (instancetype)sharedInstance
{
    static IBAtomFactory *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[IBAtomFactory alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _atom = [[IBAtomInfo alloc] init];
        _serialQueue = dispatch_queue_create("com.bowen.atom.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)updateSmid:(NSString *)smid
{
    dispatch_sync(self.serialQueue, ^{
        self.atom.smid = smid;
    });
}

- (void)updateLogId:(NSString *)logId
{
    dispatch_sync(self.serialQueue, ^{
        self.atom.logId = logId;
    });
}

- (void)updateUserId:(NSString *)userId
{
    dispatch_sync(self.serialQueue, ^{
        self.atom.userId = userId;
    });
}

- (void)updateSessionId:(NSString *)sessionId
{
    dispatch_sync(self.serialQueue, ^{
        self.atom.sessionId = sessionId;
    });
}

- (void)updateCoordinate:(CLLocationCoordinate2D)coord
{
    dispatch_sync(self.serialQueue, ^{
        if (CLLocationCoordinate2DIsValid(coord)) {
            self.atom.coordinate = coord;
        }
    });
}

- (NSString *)appendAtomInfo:(NSString *)url
{
   __block NSString *query;
    dispatch_sync(self.serialQueue, ^{
        query = [self.atom createQuery];
    });
    
    NSString *symbol = @"?";
    if ([url containsString:@"?"]) {
        symbol = @"&";
    }
    
    url = [url stringByAppendingString:symbol];
    url = [url stringByAppendingString:query];
    
    return url;
}

- (void)clear
{
    [self updateUserId:@""];
    [self updateSessionId:@""];
}

#pragma mark - getter

- (NSDictionary *)atomDict {
    __block NSDictionary *dict;
    dispatch_sync(self.serialQueue, ^{
        dict = [self.atom atomDict];
    });
    return dict;
}

@end
