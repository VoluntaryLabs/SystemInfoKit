//
//  SITask.m
//  SystemInfoKit
//
//  Created by Steve Dekorte on 10/24/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "SITask.h"
#import "SIPort.h"
#import "SIProcessKiller.h"
#import <Cocoa/Cocoa.h>

@implementation SITask

- (id)init
{
    self = [super init];
    
    self.task = [[NSTask alloc] init];
    self.connectTimeout = 5;
    
    [SIProcessKiller sharedSIProcessKiller]; // kill old zombie processes
    
    return self;
}

- (NSMutableSet *)waitOnConnectToPorts
{
    if (!_waitOnConnectToPorts)
    {
        _waitOnConnectToPorts = [NSMutableSet set];
    }
    
    return _waitOnConnectToPorts;
}

- (void)addWaitOnConnectToPortNumber:(NSNumber *)portNumber
{
    [self.waitOnConnectToPorts addObject:portNumber];
}

- (void)dealloc
{
    [self unregisterForAppTermination];
}

- (void)unregisterForAppTermination
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSApplicationWillTerminateNotification
                                                  object:nil];
}

- (void)registerForAppTermination
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(terminate)
                                                 name:NSApplicationWillTerminateNotification
                                               object:nil];
}

- (void)launch
{
    if (self.isRunning)
    {
        //NSLog(@"Attempted to launch task more than once.");
        [NSException raise:@"task already running" format:nil];
        return;
    }

    if (![self checkPortsAreOpen])
    {
        return;
    }
    
    [self.task launch];

    if (self.task.isRunning)
    {
        [self registerForAppTermination];
        [SIProcessKiller.sharedSIProcessKiller onRestartKillTask:self.task];
        
        [NSNotificationCenter.defaultCenter postNotificationName:@"ProgressPushNotification" object:self];

        if (![self waitOnConnections])
        {
            [self terminate];
            [NSException raise:@"SITask timeout on waitOnConnections" format:nil];
        }
        
        [NSNotificationCenter.defaultCenter postNotificationName:@"ProgressPopNotification" object:self];

    }
    else
    {
        [NSException raise:@"SITask not running after launch" format:nil];
    }
}

- (NSString *)taskName
{
    return [self.task.launchPath lastPathComponent];
}

- (BOOL)checkPortsAreOpen
{
    
    if (self.waitOnConnectToPorts)
    {
        for (NSNumber *port in self.waitOnConnectToPorts)
        {
            SIPort *siPort = [SIPort portWithNumber:port];
            
            while (!siPort.canBind)
            {
                NSString *error = [NSString stringWithFormat:@"SITask %@ was assigned port %@ but we can't bind to it before launch.", self.taskName, port];
                [NSException raise:error format:nil];
                return NO;
            }
            
            while (siPort.canConnect)
            {
                NSString *error = [NSString stringWithFormat:@"SITask %@ was assigned port %@ but we can connect to it before launch.", self.taskName, port];
                [NSException raise:error format:nil];
                return NO;
            }
            
        }
    }
    
    return YES;
}

- (BOOL)waitOnConnections
{
    NSInteger count = 0;
    
    if (self.waitOnConnectToPorts)
    {
        for (NSNumber *port in self.waitOnConnectToPorts)
        {
            SIPort *siPort = [SIPort portWithNumber:port];
            
            while (!siPort.canConnect)
            {
                sleep(1);
                count ++;
                
                if (count >= self.connectTimeout)
                {
                    // timeout
                    return NO;
                }
            }
            
            NSLog(@"SITask %@ able to connect on port %@", self.taskName, port);
        }
    }
    
    return YES;
}

- (void)terminate
{
    if (self.isRunning)
    {
        [SIProcessKiller.sharedSIProcessKiller removeKillTask:self.task];
        [self unregisterForAppTermination];
        [self.task terminate];
        self.task = nil;
        self.task = [[NSTask alloc] init];
    }
}

// wrapper


- (BOOL)isRunning
{
    return [self.task isRunning];
}

- (void)setLaunchPath:(NSString *)path
{
    [self.task setLaunchPath:path];
}

- (NSString *)launchPath
{
    return self.task.launchPath;
}

- (void)setArguments:(NSArray *)args
{
    [self.task setArguments:args];
}

- (void)setEnvironment:(NSDictionary *)dict
{
    [self.task setEnvironment:dict];
}

- (void)setStandardInput:(NSFileHandle *)fileHandle
{
    [self.task setStandardInput:fileHandle];
}

- (void)setStandardOutput:(NSFileHandle *)fileHandle
{
    [self.task setStandardOutput:fileHandle];
}

- (void)setStandardError:(NSFileHandle *)fileHandle
{
    [self.task setStandardError:fileHandle];
}

- (int)processIdentifier
{
    return self.task.processIdentifier;
}



@end
