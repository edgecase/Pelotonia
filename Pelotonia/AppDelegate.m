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
#import "TestFlight.h"
#import "NSDictionary+JSONConversion.h"
#import "ProfileTableViewController.h"
#import <Socialize/Socialize.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize riderDataController = _riderDataController;


- (void)handleNotification:(NSDictionary*)userInfo {
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        if ([SZSmartAlertUtils openNotification:userInfo]) {
            NSLog(@"Socialize handled the notification (background).");
            
        } else {
            NSLog(@"Socialize did not handle the notification (background).");
            
        }
    } else {
        
        NSLog(@"Notification received in foreground");
        
        // You may want to display an alert or other popup instead of immediately opening the notification here.
        
        if ([SZSmartAlertUtils openNotification:userInfo]) {
            NSLog(@"Socialize handled the notification (foreground).");
        } else {
            NSLog(@"Socialize did not handle the notification (foreground).");
        }
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    
    [TestFlight takeOff:@"55b1afb9-fb17-43db-91a9-5b9797d9f481"];
    [[UINavigationBar appearance] setTintColor:PRIMARY_DARK_GRAY];
    [[UIButton appearance] setTintColor:PRIMARY_GREEN];

    // set the socialize api key and secret, register your app here: http://www.getsocialize.com/apps/
    [Socialize storeConsumerKey:@"26caf692-9893-4f89-86d4-d1f1ae45eb3b"];
    [Socialize storeConsumerSecret:@"6b070689-31a9-4f5a-907e-4422d87a9e42"];
    [SZFacebookUtils setAppId:@"269799726466566"];
    [SZTwitterUtils setConsumerKey:@"5wwPWS7GpGvcygqmfyPIcQ" consumerSecret:@"95FOLBeQqgv0uYGMWewxf50U0sVAVIbVBlvsmjiB4V8"];
    
    // Specify a Socialize entity loader block
    [Socialize setEntityLoaderBlock:^(UINavigationController *navigationController, id<SocializeEntity>entity) {
        NSDictionary *metaDict = [NSDictionary dictionaryWithContentsOfJSONString:[entity meta]];
        NSString *riderID = [metaDict objectForKey:@"riderID"];
        Rider *rider = [[Rider alloc] initWithName:[entity name] andId:riderID];
        
        ProfileTableViewController *entityLoader = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"ProfileTableViewController"];
        [rider refreshFromWebOnComplete:^(Rider *rider) {
            if (navigationController == nil)
            {
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:entityLoader];
                [self.window.rootViewController presentModalViewController:navigationController animated:YES];
            } else {
                [navigationController pushViewController:entityLoader animated:YES];
            }
        } onFailure:^(NSString *errorMessage) {
            NSLog(@"Unknown Rider: %@. Error: %@", [entity name], errorMessage);
        }];
    }];
    
    // Register for Apple Push Notification Service
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];

    // Handle Socialize notification at launch
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo != nil) {
        [self handleNotification:userInfo];
    }
    
    // call the Appirater class
    [Appirater appLaunched:YES];

    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Handle Socialize notification at foreground
    [self handleNotification:userInfo];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken
{
    // If you are testing development (sandbox) notifications, you should instead pass development:YES
    
#if DEBUG
    [SZSmartAlertUtils registerDeviceToken:deviceToken development:YES];
#else
    [SZSmartAlertUtils registerDeviceToken:deviceToken development:NO];
#endif
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
    [Socialize handleOpenURL:url];
    
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
