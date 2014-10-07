//
//  SINetworkMonitor.h
//  TorBar
//
//  Created by Steve Dekorte on 9/6/14.
//
//

#import <Foundation/Foundation.h>

#define SINetworkMonitorChangeNotification @"SINetworkMonitorChange"

// posts a SINetworkMonitorChangeNotification notification when SSID changes

@interface SINetworkMonitor : NSObject

@property (retain, nonatomic) NSTimer *ssidTimer;
@property (retain, nonatomic) NSString *ssid;

- (void)start;
- (void)stop;

@end
