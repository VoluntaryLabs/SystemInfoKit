//
//  SINetwork.h
//  SystemInfoKit
//
//  Created by Steve Dekorte on 10/12/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SINetwork : NSObject

+ (SINetwork *)sharedSINetwork;

- (BOOL)hasOpenPort:(NSNumber *)aPort;

- (NSMutableArray *)openPortsBetween:(NSNumber *)lowPort and:(NSNumber *)highPort;
- (NSNumber *)firstOpenPortBetween:(NSNumber *)lowPort and:(NSNumber *)highPort;

@end
