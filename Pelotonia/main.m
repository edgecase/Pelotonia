//
//  main.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    int retval = 0;
    @autoreleasepool {
        @try
        {
            retval =  UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException *exception)
        {
            NSLog(@"Exception - %@",[exception description]);
            NSLog(@"%@", [exception reason]);
            exit(EXIT_FAILURE);
        }
    }
    return retval;
}
