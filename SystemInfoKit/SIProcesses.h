//
//  SIProcesses.h
//  BitmessageKit
//
//  Created by Steve Dekorte on 8/22/14.
//  Copyright (c) 2014 Adam Thorsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/types.h>

@interface SIProcesses : NSObject

+ (SIProcesses *)sharedSIProcesses;

- (NSDictionary *)processes; // pid -> SIProcess map

- (BOOL)isProcessRunningWithName:(NSString *)name pid:(pid_t)pid;

@end
