//
//  SIProcessKiller.h
//  BitmessageKit
//
//  Created by Steve Dekorte on 10/3/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIProcess.h"

@interface SIProcessKiller : NSObject

+ (SIProcessKiller *)sharedSIProcessKiller;

- (void)onRestartKillTask:(NSTask *)aTask;
- (void)removeKillTask:(NSTask *)aTask;

@end
