//
//  AppDelegate.m
//  Pelotonia
//
//  Created by Adam McCrea on 7/11/12.
//  Copyright (c) 2012 Sandlot Software, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "RiderDataController.h"
#import "Pelotonia-Colors.h"
#import "Appirater.h"
#import "SHK.h"
#import "SHKConfiguration.h"
#import "SHKFacebook.h"
#import "PelotoniaSHKConfigurator.h"
#import "TestFlight.h"
#import <Parse/Parse.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize riderDataController = _riderDataController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
    [TestFlight takeOff:@"55b1afb9-fb17-43db-91a9-5b9797d9f481"];
    [[UINavigationBar appearance] setTintColor:PRIMARY_DARK_GRAY];
    [[UIButton appearance] setTintColor:PRIMARY_GREEN];

    DefaultSHKConfigurator *configurator = [[PelotoniaSHKConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];

    // send any cached messages
    [SHK flushOfflineQueue];
    
    // set up Parse
    [Parse setApplicationId:@"9CUxtD0xEc85ZoN3D9wv5H5li7fQMBx6XjZ6GhqP"
                  clientKey:@"JMsMecnjVTIsjWNyradXSMVSeflHq6StaQmN3Eqz"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // call the Appirater class
    [Appirater appLaunched:YES];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self archiveData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


// data controller methods
#pragma mark -- data controller
- (NSString *)PelotoniaFiles:(NSString *)fileName
{
    // get list of directories in sandbox
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    
    // get the only directory from the list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    // append passed in file name to the return value
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

- (NSString *)riderFilePath 
{
    return [self PelotoniaFiles:@"Riders"];
}

- (BOOL)handleOpenURL:(NSURL*)url
{
    NSString* scheme = [url scheme];
    NSString* prefix = [NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)];
    if ([scheme hasPrefix:prefix])
        return [SHKFacebook handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [self handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self handleOpenURL:url];
}

- (RiderDataController *)riderDataController {
    if (_riderDataController == nil) {
        _riderDataController = [NSKeyedUnarchiver unarchiveObjectWithFile:[self riderFilePath]];
        if (_riderDataController == nil) {
            _riderDataController = [[RiderDataController alloc] init]; 
        }
    }
    return _riderDataController;
}

- (void)archiveData
{
    // get the game list & write it out
    [NSKeyedArchiver archiveRootObject:self.riderDataController toFile:[self riderFilePath]];
    
}




@end
