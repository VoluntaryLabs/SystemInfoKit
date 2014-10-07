//
//  SIProcesses.m
//  BitmessageKit
//
//  Created by Steve Dekorte on 8/22/14.
//  Copyright (c) 2014 Adam Thorsen. All rights reserved.
//

#import "SIProcesses.h"
#import "SIProcess.h"

#include <sys/sysctl.h>
#include <unistd.h>
#include <errno.h>

@implementation SIProcesses

static id sharedSIProcesses = nil;

+ (SIProcesses *)sharedSIProcesses
{
    if (sharedSIProcesses == nil)
    {
        sharedSIProcesses = [[self.class alloc] init];
    }
    
    return sharedSIProcesses;
}


typedef struct kinfo_proc kinfo_proc;

static int GetBSDProcessList(kinfo_proc **procList, size_t *procCount)
// Returns a list of all BSD processes on the system.  This routine
// allocates the list and puts it in *procList and a count of the
// number of entries in *procCount.  You are responsible for freeing
// this list (use "free" from System framework).
// On success, the function returns 0.
// On error, the function returns a BSD errno value.
{
    int                 err;
    kinfo_proc *        result;
    bool                done;
    static const int    name[] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    // Declaring name as const requires us to cast it when passing it to
    // sysctl because the prototype doesn't include the const modifier.
    size_t              length;
    
    assert( procList != NULL);
    assert(*procList == NULL);
    assert(procCount != NULL);
    
    *procCount = 0;
    
    // We start by calling sysctl with result == NULL and length == 0.
    // That will succeed, and set length to the appropriate length.
    // We then allocate a buffer of that size and call sysctl again
    // with that buffer.  If that succeeds, we're done.  If that fails
    // with ENOMEM, we have to throw away our buffer and loop.  Note
    // that the loop causes use to call sysctl with NULL again; this
    // is necessary because the ENOMEM failure case sets length to
    // the amount of data returned, not the amount of data that
    // could have been returned.
    
    result = NULL;
    done = false;
    
    do {
        assert(result == NULL);
        
        // Call sysctl with a NULL buffer.
        
        length = 0;
        err = sysctl( (int *) name, (sizeof(name) / sizeof(*name)) - 1,
                     NULL, &length,
                     NULL, 0);
        
        if (err == -1)
        {
            err = errno;
        }
        
        // Allocate an appropriately sized buffer based on the results
        // from the previous call.
        
        if (err == 0)
        {
            result = malloc(length);
            
            if (result == NULL)
            {
                err = ENOMEM;
            }
        }
        
        // Call sysctl again with the new buffer.  If we get an ENOMEM
        // error, toss away our buffer and start again.
        
        if (err == 0)
        {
            err = sysctl( (int *) name, (sizeof(name) / sizeof(*name)) - 1,
                         result, &length,
                         NULL, 0);
            
            if (err == -1)
            {
                err = errno;
            }
            if (err == 0)
            {
                done = true;
            }
            else if (err == ENOMEM)
            {
                assert(result != NULL);
                free(result);
                result = NULL;
                err = 0;
            }
        }
    } while (err == 0 && ! done);
    
    // Clean up and establish post conditions.
    
    if (err != 0 && result != NULL)
    {
        free(result);
        result = NULL;
    }
    
    *procList = result;
    
    if (err == 0)
    {
        *procCount = length / sizeof(kinfo_proc);
    }
    
    assert( (err == 0) == (*procList != NULL) );
    
    return err;
}

- (NSDictionary *)processes
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    kinfo_proc *mylist = NULL;
    size_t mycount = 0;
    GetBSDProcessList(&mylist, &mycount);
    
    for(int k = 0; k < mycount; k++)
    {
        kinfo_proc *proc = NULL;
        proc = &mylist[k];
        
        NSNumber *pid = [NSNumber numberWithLongLong:proc->kp_proc.p_pid];
        NSString *defaultName = [NSString stringWithFormat:@"%s",proc->kp_proc.p_comm];

        SIProcess *process = [[SIProcess alloc] init];
        [process setPid:pid];
        [process setDefaultName:defaultName];
        
        [dict setObject:process forKey:pid];
    }
    
    free(mylist);
    
    return dict;
}

- (BOOL)isProcessRunningWithName:(NSString *)name pid:(pid_t)pid
{
    NSDictionary *processes = self.processes;
    
    for (NSNumber *pidNumber in processes)
    {
        SIProcess *process = [processes objectForKey:pidNumber];
        
        if ([process.name isEqualToString:name] && pidNumber.longLongValue == pid)
        {
            return YES;
        }
    }
    
    return NO;
}

@end
