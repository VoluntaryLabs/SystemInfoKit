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

- (BOOL)canBindPort:(NSNumber *)aPort
{
    int sockfd;
    int portno = aPort.intValue;
    struct sockaddr_in serv_addr;
    
//label:
    
    // create socket
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0)
    {
        perror("ERROR opening socket");
        return NO;
    }
    
    // init socket
    bzero((char *) &serv_addr, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = htons(portno);
    
    // reuse
    
    int option = 1;
    sockfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, (char*)&option, sizeof(option));
    
    // bind socket
    if (bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0)
    {
        printf("could NOT bind to port %i\n", portno);
        return NO;
    }
    printf("could bind to port %i\n", portno);
    
    close(sockfd);
    //goto label;
    
    return YES;
}

- (BOOL)canConnectToPort:(NSNumber *)aPort
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
    
    BOOL canConnect = NO;
    
    if (connect(sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) == 0)
    {
        // we could connect so the port must be active
        canConnect = YES;
        printf("can connect to port %s:%i", hostname, portno);
    }
    else
    {
        printf("can't connect to port %s:%i", hostname, portno);
    }
    
    close(sockfd);
    return canConnect;
}

- (NSNumber *)firstBindablePortBetween:(NSNumber *)lowPort and:(NSNumber *)highPort
{
    for (int port = lowPort.intValue; port < highPort.intValue + 1; port ++)
    {
        NSNumber *portNumber = [NSNumber numberWithInt:port];
        
        if ([self canBindPort:portNumber])
        {
            return portNumber;
        }
    }
    
    return nil;
}

- (NSMutableArray *)BindablePortsBetween:(NSNumber *)lowPort and:(NSNumber *)highPort
{
    NSMutableArray *openPorts = [NSMutableArray array];
    
    for (int port = lowPort.intValue; port < highPort.intValue + 1; port ++)
    {
        NSNumber *portNumber = [NSNumber numberWithInt:port];
        
        if ([self canBindPort:portNumber])
        {
            [openPorts addObject:portNumber];
        }
    }
    
    return openPorts;
}

@end
