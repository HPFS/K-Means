//
//  KMeansiPadAppDelegate.h
//  KMeansiPad
//
//  Created by Daniel Bokser on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMeansiPadViewController;

@interface KMeansiPadAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet KMeansiPadViewController *viewController;

@end
