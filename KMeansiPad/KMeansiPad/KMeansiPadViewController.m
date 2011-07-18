//
//  KMeansiPadViewController.m
//  KMeansiPad
//
//  Created by Daniel Bokser on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KMeansiPadViewController.h"

@implementation KMeansiPadViewController

@synthesize dim, seed, clusters, pts, button, loading, sw;

- (void)dealloc
{
    [self releaseAll];
    [super dealloc];
}

-(void) releaseAll
{
    [imgV release];
    [s release];
    [dim release];
    [seed release];
    [clusters release];
    [pts release];
    [button release];
    [loading release];
    
}

- (void) showAlertTitle:(NSString *)title withMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    
    [alert release];
}

-(IBAction) kmeansAhoy:(id)sender
{
    
    
    
    if (!(pts.text && dim.text && clusters.text && seed.text) ||
        [pts.text integerValue] <= 0 || [dim.text integerValue] <= 0 ||
        [clusters.text integerValue] <= 0 || [seed.text integerValue] <= 0 ) 
    {
        
        [self showAlertTitle:@"Error" withMessage:@"Please Fill in all Fields Correctly"];
        return;
    }
    
    if (dim.editing) 
        [dim resignFirstResponder];
    else if(pts.editing)
        [pts resignFirstResponder];
    else if(clusters.editing)
        [clusters resignFirstResponder];
    else if(seed.editing)
        [seed resignFirstResponder];
    
    button.enabled = NO;
    loading.hidden = NO;
    
    [loading startAnimating];
    
    //try to connect to server
    if(![self connectToSever])
    {
        loading.hidden = YES;
        [loading stopAnimating];
        button.enabled = YES;
        return;
    }
    
    [self performSelectorInBackground:@selector(doInBackground) withObject:nil];
    
    
}

- (void) startTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateView) userInfo:nil repeats:YES];  
}

- (void) doInBackground
{
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    //get image
    UIImage *img = [self getImageFromServer];
    
    //if there is an image, start timer and add image to sub view
    if (img) {
        imgV = [[UIImageView alloc]initWithFrame:self.view.bounds];
        
        imgV.image = img;
        
        imgV.contentMode = UIViewContentModeScaleToFill;
        
        [self.view addSubview:imgV];
        
        
        imgV.contentMode = UIViewContentModeScaleAspectFit;
        
        
        if (sw.on) {
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(advancePic:)];
            
            [tapGesture setNumberOfTapsRequired:1];
            [tapGesture setNumberOfTouchesRequired:1];
            
            tapGesture.cancelsTouchesInView = NO;
            [self.view addGestureRecognizer:tapGesture];
            [tapGesture release];
            
        }
        else
            [self performSelectorOnMainThread:@selector(startTimer) withObject:nil waitUntilDone:NO];
        
        
        
        
    }
    //else produce error
    else{
        
        [self showAlertTitle:@"Error" withMessage:@"Failed to get Image!"];
        
        loading.hidden = YES;
        [loading stopAnimating];
        button.enabled = YES;
        
    }
    
    
    
    [pool release];
    
    
    
    
}

- (void) updateView
{
    
    
    
    UIImage *img = [self getImageFromServer];
    
    if (img) {
        imgV.image = img;
    }
    else{
        
        
        [self showAlertTitle:@"Success!" withMessage:@"K-Means Finished!"];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        
        [tapGesture setNumberOfTapsRequired:1];
        [tapGesture setNumberOfTouchesRequired:1];
        
        tapGesture.cancelsTouchesInView = NO;
        [self.view addGestureRecognizer:tapGesture];
        [tapGesture release];
        [timer invalidate];
        
        isFinished = YES;
    }
    
}

- (void) tapGesture:(UITapGestureRecognizer *)tgr
{
    [imgV removeFromSuperview];
    loading.hidden = YES;
    [loading stopAnimating];
    button.enabled = YES;
    
    
    [imgV release];
    [self.view removeGestureRecognizer:tgr];
    
}


- (void) advancePic: (UITapGestureRecognizer *) sender
{
    if(!isFinished)
        [self updateView];
    
}



- (UIImage *) getImageFromServer
{
    
    
    
    
    char *sizeStr = (char*)[s readBytesWithLength:10];
    
    if(sizeStr == NULL)
    {
        
        
        
        
        [timer invalidate];
        
        return nil;
    }
    
    int size = atoi(sizeStr);
    
    void *imgData = [s readBytesWithLength:size];
    
    /*
     char *charImgData = (char*) imgData;
     
     
     NSLog(@"First 30:");
     for (int i = 0; i < 30; i++) {
     NSLog(@"%x", charImgData[i]);
     }
     
     NSLog(@"Last 30:");
     for (int i = size - 30; i < size; i++) {
     
     NSLog(@"%x", charImgData[i]);
     }
     */
    
    
    
    return [UIImage imageWithData:[NSData dataWithBytesNoCopy:imgData length:size]];
    
    
    
    
    
}


-(BOOL) connectToSever
{
    
    
    s = [LXSocket socket];
    
    [s retain];
    
    
    
    
    NSString *ip = [s resolveHostName:@"reu1.cs.rit.edu"];
    
    
    if (![s connect:ip port:9996]) {
        
        [self showAlertTitle:@"Error" withMessage:@"Failed to Connect"];
        return NO;
        
    }
    
    
    
    
    
    char *points = (char *)[pts.text UTF8String];
    int pLen = strlen(points) + 1;
    
    points[strlen(points)] = '\n';
    
    char *k = (char *)[clusters.text UTF8String];
    int kLen = strlen(k) + 1;
    k[strlen(k)] = '\n';
    
    
    char *d = (char *)[dim.text UTF8String];
    int dLen = strlen(d) + 1;
    d[strlen(d)] = '\n';
    
    char *seedNum = (char *)[seed.text UTF8String];
    int sLen = strlen(seedNum) + 1;
    seedNum[strlen(seedNum)] = '\n';
    
    
    [s sendBytes:points length:pLen];
    [s sendBytes:k length:kLen];
    [s sendBytes:d length:dLen];
    [s sendBytes:seedNum length:sLen];
    
    return YES;
    
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [button setTitle:@"K-Means Ahoy!!!" forState:UIControlStateNormal];
    [button setTitle:@"Loading..." forState:UIControlStateDisabled];
    
    
    isFinished = NO;
    self.view.autoresizesSubviews = YES;
}


- (void)viewDidUnload
{
    
    [self releaseAll];
    seed = pts = clusters = dim = nil;
    button = nil; 
    loading =  nil;
    imgV = nil;
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}



@end
