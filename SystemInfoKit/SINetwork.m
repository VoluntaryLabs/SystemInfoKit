//
//  SINetwork.m
//  SystemInfoKit
//
//  Created by Steve Dekorte on 10/12/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "SINetwork.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

@implementation SINetwork

static SINetwork *sharedSINetwork = nil;

+ (SINetwork *)sharedSINetwork
{
    if (sharedSINetwork == nil)
    {
        sharedSINetwork = [[SINetwork alloc] init];
    }
    
    return sharedSINetwork;
    
}

- (BOOL)hasOpenPort:(NSNumber *)aPort
{
    int portno     = aPort.intValue;
    char *hostname = "127.0.0.1";
    
    int sockfd;
    struct sockaddr_in serv_addr;
    struct hostent *server;
    
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    
    if (sockfd < 0)
    {
        NSLog(@"ERROR opening socket");
    }
    
    server = gethostbyname(hostname);
    
    if (server == NULL)
    {
        NSLog(@"ERROR, no such host\n");
        return NO;
    }
    
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr,
          (char *)&serv_addr.sin_addr.s_addr,
          server->h_length);
    
    serv_addr.sin_port = htons(portno);
    
    BOOL isOpen = YES;
    
    if (connect(sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) == 0)
    {
        // we could connect so the port must be active
        isOpen = NO;
        //printf("Port %s:%i is active", hostname, portno);
    }
    else
    {
        //printf("Port %s:%i is open", hostname, portno);
    }
    
    close(sockfd);
    return isOpen;
}

- (NSNumber *)firstOpenPortBetween:(NSNumber *)lowPort and:(NSNumber *)highPort
{
    for (int port = lowPort.intValue; port < highPort.intValue + 1; port ++)
    {
        NSNumber *portNumber = [NSNumber numberWithInt:port];
        
        if ([self hasOpenPort:portNumber])
        {
            return portNumber;
        }
    }
    
    return nil;
}

- (NSMutableArray *)openPortsBetween:(NSNumber *)lowPort and:(NSNumber *)highPort
{
    NSMutableArray *openPorts = [NSMutableArray array];
    
    for (int port = lowPort.intValue; port < highPort.intValue + 1; port ++)
    {
        NSNumber *portNumber = [NSNumber numberWithInt:port];
        
        if ([self hasOpenPort:portNumber])
        {
            [openPorts addObject:portNumber];
        }
    }
    
    return openPorts;
}

@end
