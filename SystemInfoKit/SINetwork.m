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
    BOOL canBind = NO;
    
label:
    
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
    if (bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) == 0)
    {
        canBind = YES;
        printf("V bind %i; ", portno);
    }
    else
    {
        canBind = NO;
        printf("X bind %i; ", portno);
    }
    
    //goto label;
    close(sockfd);
    
    return canBind;
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
        printf("V conn %i\n", portno);
    }
    else
    {
        canConnect = NO;
        printf("X conn %i\n", portno);
    }
    
    close(sockfd);
    return canConnect;
}

- (NSNumber *)firstBindablePortBetween:(NSNumber *)lowPort and:(NSNumber *)highPort
{
    for (int port = lowPort.intValue; port < highPort.intValue + 1; port ++)
    {
        NSNumber *portNumber = [NSNumber numberWithInt:port];
        
        if ([self canBindPort:portNumber] && ![self canConnectToPort:portNumber])
        {
            printf("found unused port %i\n", portNumber.intValue);
            return portNumber;
        }
    }
    
    return nil;
}

- (NSMutableArray *)bindablePortsBetween:(NSNumber *)lowPort and:(NSNumber *)highPort
{
    NSMutableArray *openPorts = [NSMutableArray array];
    
    for (int port = lowPort.intValue; port < highPort.intValue + 1; port ++)
    {
        NSNumber *portNumber = [NSNumber numberWithInt:port];
        
        if ([self canBindPort:portNumber] && ![self canConnectToPort:portNumber])
        {
            [openPorts addObject:portNumber];
        }
    }
    
    return openPorts;
}

@end
