//
//  SIProcess.h
//  SystemInfoKit
//
//  Created by Steve Dekorte on 10/7/14.
//  Copyright (c) 2014 voluntary.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIProcess : NSObject

@property (retain, nonatomic) NSString *defaultName;
@property (retain, nonatomic) NSNumber *pid;

- (NSDictionary *)info;
- (NSString *)name;

@end
