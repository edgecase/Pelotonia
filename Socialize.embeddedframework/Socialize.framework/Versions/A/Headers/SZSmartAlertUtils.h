//
//  SZSmartAlertUtils.h
//  SocializeSDK
//
//  Created by Nathaniel Griswold on 6/4/12.
//  Copyright (c) 2012 Socialize, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SZSmartAlertUtils : NSObject

+ (BOOL)isAvailable;
+ (BOOL)handleNotification:(NSDictionary*)userInfo; // __attribute__((deprecated("Please use `openNotification:` (which unconditionally opens the notification), instead")));
+ (BOOL)isSocializeNotification:(NSDictionary*)userInfo;
+ (void)registerDeviceToken:(NSData*)deviceToken;
+ (BOOL)openNotification:(NSDictionary*)userInfo;

@end