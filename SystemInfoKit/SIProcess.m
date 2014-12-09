//
//  SIProcess.m
//  SystemInfoKit
//
//  Created by Steve Dekorte on 10/7/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "SIProcess.h"

#include <sys/types.h>
#include <sys/sysctl.h>
#include <unistd.h>
#include <errno.h>

#import <Cocoa/Cocoa.h>

@implementation SIProcess

- (NSDictionary *)info
{
    NSDictionary *ret = nil;
    
    ProcessSerialNumber psn = { kNoProcess, kNoProcess };
    
    if (GetProcessForPID(self.pid.intValue, &psn) == noErr)
    {
        CFDictionaryRef cfDict = ProcessInformationCopyDictionary(&psn,kProcessDictionaryIncludeAllInformationMask);
        
        ret = [NSDictionary dictionaryWithDictionary:(__bridge NSDictionary *)cfDict];
        
        CFRelease(cfDict);
    }
    
    return ret;
}


- (NSString *)name
{
    NSString *name = [self.info objectForKey:(id)kCFBundleNameKey];
    
    if (name == nil)
    {
        name = _defaultName;
    }
    
    return name;
}

- (void)kill
{
    kill(self.pid.intValue, SIGKILL);
}

- (BOOL)isRunning
{
    return self.info != nil;
}

@end
