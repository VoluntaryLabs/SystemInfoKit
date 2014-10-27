//
//  SIPort.h
//  SystemInfoKit
//
//  Created by Steve Dekorte on 10/12/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIPort : NSObject

//@property (retain, nonatomic) NSString *hostName;
@property (retain, nonatomic) NSNumber *portNumber;

+ (SIPort *)portWithNumber:(NSNumber *)aNumber;

- (BOOL)canConnect;
- (BOOL)canBind;

//+ (NSMutableArray *)bindablePortsBetween:(NSNumber *)lowPort and:(NSNumber *)highPort;
//+ (SIPort *)firstBindablePortBetween:(NSNumber *)lowPort and:(NSNumber *)highPort;

- (SIPort *)nextPort;

- (SIPort *)nextBindablePort;


@end
