/*==============================================================================
 Copyright (c) 2012-2013 Qualcomm Connected Experiences, Inc.
 All Rights Reserved.
 ==============================================================================*/

#import "MeatPillerAccessAppDelegate.h"
#import <Parse/Parse.h>
#import <FYX/FYX.h>

@implementation MeatPillerAccessAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"AM3Ba0uWhovNKUhmkbHbc0HO7TqbamVzFdlJnboi"
                  clientKey:@"y2CIkImxavjwVpPNO2xMQc3SADvmzmeYbO7fj29r"];
    
    [FYX setAppId:@"85af6a87cb02839e078e5070f3f6ab0a7ea6a48fa66da68765653f70aa364627"
        appSecret:@"e6d0ca4c2f1bed69c9c7e014f25d3ba8150117da59c9d35df93305c9d78fad94"
      callbackUrl:@"meatpillar://authcode"];

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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didBuyStuffNotification" object:self];
}

@end
