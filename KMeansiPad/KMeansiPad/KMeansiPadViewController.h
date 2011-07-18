//
//  KMeansiPadViewController.h
//  KMeansiPad
//
//  Created by Daniel Bokser on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "LXSocket.h"
#include <sys/types.h>
#include <netinet/in.h> 
#include <arpa/inet.h>
#include <netdb.h>


@interface KMeansiPadViewController : UIViewController {
    
    UIImageView *imgV;
    LXSocket *s;
    NSTimer *timer;
    IBOutlet UITextField *pts, *dim, *seed;
    IBOutlet UIButton *button;
    IBOutlet UIActivityIndicatorView *loading;
    IBOutlet UISwitch *sw;
    BOOL isFinished;
}



@property (retain, nonatomic) IBOutlet UITextField *pts, *dim, *seed, *clusters;
@property (retain, nonatomic) IBOutlet UIButton *button;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (retain, nonatomic) IBOutlet UISwitch *sw;

-(IBAction) kmeansAhoy: (id) sender;
-(void) tapGesture: (UITapGestureRecognizer*) tgr;
-(BOOL) connectToSever;
-(void) releaseAll;
-(void) updateView;
-(void) showAlertTitle: (NSString*) title withMessage:(NSString*) msg; 
-(UIImage *) getImageFromServer;
-(void) doInBackground;
-(void) advancePic: (UITapGestureRecognizer *) sender;


@end
