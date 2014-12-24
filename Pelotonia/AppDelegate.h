//
//  AppDelegate.h
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "RiderDataController.h"
#import <SDWebImage/SDImageCache.h>

#define IF_IOS60_OR_GREATER(...) \
if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_6_0) \
{ \
__VA_ARGS__ \
}


@class RiderDataController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    RiderDataController *_riderDataController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RiderDataController *riderDataController;

+ (RiderDataController *)sharedDataController;

- (void)archiveData;


@end
