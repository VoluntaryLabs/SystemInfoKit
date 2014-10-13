//
//  SIProcessKiller.m
//  BitmessageKit
//
//  Created by Steve Dekorte on 10/3/14.
//  Copyright (c) 2014 Adam Thorsen. All rights reserved.
//

#import "SIProcessKiller.h"
#import "SIProcesses.h"

@implementation SIProcessKiller

static SIProcessKiller *sharedSIProcessKiller = nil;

+ (SIProcessKiller *)sharedSIProcessKiller
{
    if (!sharedSIProcessKiller)
    {
        sharedSIProcessKiller = [[SIProcessKiller alloc] init];
        [sharedSIProcessKiller killOldTasks];
    }
    
    return sharedSIProcessKiller;
}

- (NSString *)userDefaultsKey
{
    return @"SIProcessKiller";
}

- (NSDictionary *)oldTasksDict
{
    NSDictionary *dict = [NSUserDefaults.standardUserDefaults dictionaryForKey:self.userDefaultsKey];
    
    if (dict)
    {
        return dict;
    }
    
    return [NSDictionary dictionary];
}

- (void)setOldTasksDict:(NSDictionary *)aDict
{
    [NSUserDefaults.standardUserDefaults setObject:aDict forKey:self.userDefaultsKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)onRestartKillTask:(NSTask *)aTask
{
    NSString *processName = [aTask.launchPath lastPathComponent];
    NSNumber *processId = [NSNumber numberWithInt:aTask.processIdentifier];
    NSMutableDictionary *oldTasksDict = self.oldTasksDict.mutableCopy;
    
    // what to do about multiple processes with the same name?
    // index by processId?
    
    [oldTasksDict setObject:processId forKey:processName];
    
    [self setOldTasksDict:oldTasksDict];
}

- (void)removeKillTask:(NSTask *)aTask
{
    assert(aTask);
    
    NSString *processName = [aTask.launchPath lastPathComponent];
    //NSNumber *processId = [NSNumber numberWithInt:aTask.processIdentifier];
    NSMutableDictionary *oldTasksDict = self.oldTasksDict.mutableCopy;

    if (processName && [oldTasksDict objectForKey:processName])
    {
        [oldTasksDict removeObjectForKey:processName];
    }
    
    [self setOldTasksDict:oldTasksDict];
}

- (void)killOldTasks
{
    NSDictionary *dict = self.oldTasksDict;
    NSMutableDictionary *newDict = self.oldTasksDict.mutableCopy;
    
    for (NSString *processName in dict.allKeys)
    {
        NSNumber *processId = [dict objectForKey:processName];
        
        BOOL processExists = [SIProcesses.sharedSIProcesses isProcessRunningWithName:processName pid:processId.intValue];
        
        if(processExists)
        {
            //NSLog(@"killing old process '%@' with pid: %@", processName, processId);
            kill([processId intValue], SIGKILL);
            sleep(1);
        }
        else
        {
            [newDict removeObjectForKey:processName];
            continue;
        }
        
        processExists = [SIProcesses.sharedSIProcesses isProcessRunningWithName:processName pid:processId.intValue];
        
        if (processExists)
        {
            [NSException raise:@"Unable to kill process" format:nil];
        }
        else
        {
            NSLog(@"killed old process '%@' with pid: %@", processName, processId);
            [newDict removeObjectForKey:processName];
        }
    }
    
    [self setOldTasksDict:newDict];
}

@end
