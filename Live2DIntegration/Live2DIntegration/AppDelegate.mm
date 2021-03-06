//
//  AppDelegate.m
//  Live2DIntegration
//
//  Created by VanJay on 2020/12/17.
//

#import "AppDelegate.h"
#include "Live2DCubismCore.hpp"
#include "L2DCubism.h"
#import "FaceDetectionViewController.h"

using namespace Live2D;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [L2DCubism initialize];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    self.window.backgroundColor = UIColor.whiteColor;

    self.window.rootViewController = [[FaceDetectionViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}
@end
