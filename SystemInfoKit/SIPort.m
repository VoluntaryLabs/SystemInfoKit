//
//  SIPort.m
//  SystemInfoKit
//
//  Created by Steve Dekorte on 10/12/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import "SIPort.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

@implementation SIPort

static SIPort *sharedSIPort = nil;

+ (SIPort *)portWithNumber:(NSNumber *)aPortNumber
{
    SIPort *port = [[SIPort alloc] init];
    port.portNumber = aPortNumber;
    return port;
}

- (id)init
{
    self = [super init];
    //self.hostName = @"127.0.0.1";
    self.debug = NO;
    return self;
}

- (BOOL)canBind
{
    int sockfd;
    int portno = self.portNumber.intValue;
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
    
    /*
    int option = 1;
    sockfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, (char*)&option, sizeof(option));
    */
    
    // bind socket
    if (bind(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) == 0)
    {
        canBind = YES;
        //printf("V bind %i; ", portno);
    }
    else
    {
        canBind = NO;
        //printf("X bind %i; ", portno);
    }
    
    //goto label;
    close(sockfd);
    
    return canBind;
}

- (BOOL)canConnect
{
    const char *hostname = self.hostName ? self.hostName.UTF8String : "127.0.0.1";
    int portno = self.portNumber.intValue;
    
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
        canConnect = YES;
        
        if (self.debug)
        {
            printf("V conn %i\n", portno);
        }
    }
    else
    {
        canConnect = NO;
        
        if (self.debug)
        {
            printf("X conn %i\n", portno);
        }
    }
    
    close(sockfd);
    return canConnect;
}

- (SIPort *)nextPort
{
    return [SIPort portWithNumber:@(self.portNumber.intValue + 1)];
}

- (SIPort *)nextBindablePort
{
    SIPort *port = [self nextPort];
    int maxPort = 65535 - 1;
    
    while (port.portNumber.intValue < maxPort)
    {
        if ([port canBind] && ![port canConnect])
        {
            return port;
        }
        
        port = [port nextPort];
    }
    
    return nil;
}

@end
