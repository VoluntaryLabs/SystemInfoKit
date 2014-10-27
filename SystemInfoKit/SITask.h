//
//  SITask.h
//  SystemInfoKit
//
//  Created by Steve Dekorte on 10/24/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//
// subclass of NSTask that:
//
// - registers for app termination notification and termites task when received
//
// - stores name and pid of task with SIProcessKiller so it will kill it
//   when app restarts in case there was a app crash that failed to terminate the task
//
// - can wait after launching for a list of ports to accept connections
//   this is useful for making sure the server is running
//
//
// Looks like we can't subclass NSTask thanks to NSRequestConcreteImplementation
// so we have to wrap it...

#import <Foundation/Foundation.h>

@interface SITask : NSObject

@property (retain, nonatomic) NSTask *task;
@property (retain, nonatomic) NSMutableSet *waitOnConnectToPorts;
@property (assign, nonatomic) NSInteger connectTimeout;

- (void)addWaitOnConnectToPortNumber:(NSNumber *)portNumber;
- (void)launch;
- (void)terminate;

// wrapper

- (BOOL)isRunning;

- (void)setLaunchPath:(NSString *)path;
- (NSString *)launchPath;

- (void)setArguments:(NSArray *)args;
- (void)setEnvironment:(NSDictionary *)dict;

- (void)setStandardInput:(NSFileHandle *)fileHandle;
- (void)setStandardOutput:(NSFileHandle *)fileHandle;
- (void)setStandardError:(NSFileHandle *)fileHandle;

- (int)processIdentifier;

@end
