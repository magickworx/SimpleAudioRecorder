/*****************************************************************************
 *
 * FILE:	AppDelegate.m
 * DESCRIPTION:	Recorder: Application Main Controller
 * DATE:	Mon, Feb 18 2013
 * UPDATED:	Mon, Feb 18 2013
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2013 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2013 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
 *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *   INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *   THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id: AppDelegate.m,v 1.2 2013/01/22 15:23:51 kouichi Exp $
 *
 *****************************************************************************/

#import "AppDelegate.h"
#import "RootViewController.h"

@interface AppDelegate ()
@property (nonatomic,retain) UINavigationController *	navigationController;
@end

@implementation AppDelegate

@synthesize	navigationController	= _navigationController;

#if     DEBUG
static void uncaughtExceptionHandler(NSException * exception)
{
  NSLog(@"CRASH: %@", exception);
  NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
  // Internal error reporting
}
#endif	// DEBUG

-(void)dealloc
{
  [_window release];
  [_navigationController release];
  [super dealloc];
}

#pragma mark UIApplication delegate
-(BOOL)application:(UIApplication *)application
	didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if     DEBUG
  NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#endif	// DEBUG

  UIWindow *	window;
  window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  window.backgroundColor = [UIColor whiteColor];
  self.window = window;
  [window release];

  RootViewController *	viewController;
  viewController = [[RootViewController alloc] init];
  UINavigationController *	navigationController;
  navigationController = [[UINavigationController alloc]
			  initWithRootViewController:viewController];
  self.window.rootViewController = navigationController;
  self.navigationController = navigationController;
  [viewController release];
  [navigationController release];

  [self.window makeKeyAndVisible];

  return YES;
}

#pragma mark UIApplication delegate
-(void)applicationWillResignActive:(UIApplication *)application
{
  /*
   * Sent when the application is about to move from active to inactive state.
   * This can occur for certain types of temporary interruptions (such as an
   * incoming phone call or SMS message) or when the user quits the application
   * and it begins the transition to the background state.
   * Use this method to pause ongoing tasks, disable timers, and throttle down
   * OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

#pragma mark UIApplication delegate
-(void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   * Use this method to release shared resources, save user data, invalidate
   * timers, and store enough application state information to restore your
   * application to its current state in case it is terminated later. 
   * If your application supports background execution, this method is called
   * instead of applicationWillTerminate: when the user quits.
   */
}

#pragma mark UIApplication delegate
-(void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   * Called as part of the transition from the background to the inactive state;
   * here you can undo many of the changes made on entering the background.
   */
}

#pragma mark UIApplication delegate
-(void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   * Restart any tasks that were paused (or not yet started)
   * while the application was inactive. If the application was previously
   * in the background, optionally refresh the user interface.
   */
}

#pragma mark UIApplication delegate
-(void)applicationWillTerminate:(UIApplication *)application
{
}

@end
