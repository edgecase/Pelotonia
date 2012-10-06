//
//  AppDelegate.h
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RiderDataController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    RiderDataController *_riderDataController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RiderDataController *riderDataController;

- (void)archiveData;

@end
