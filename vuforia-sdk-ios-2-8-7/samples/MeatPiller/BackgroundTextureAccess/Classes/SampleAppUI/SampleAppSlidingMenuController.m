/*==============================================================================
 Copyright (c) 2012-2013 Qualcomm Connected Experiences, Inc.
 All Rights Reserved.
 ==============================================================================*/

#import <QuartzCore/QuartzCore.h>
#import "SampleAppSlidingMenuController.h"


// the duration of the animation to display the menu
#define kSlidingMenuSlideDuration .3f

#define MAX_PAN_VELOCITY 600

// shadow properties
#define SHADOW_OPACITY 0.8f
#define SHADOW_RADIUS_CORNER 3.0f

#define ANIMATION_DURATION .3

@interface SampleAppSlidingMenuController ()

@property(nonatomic,strong) UIViewController *rootViewController;

@end

@implementation SampleAppSlidingMenuController

@synthesize rootViewController;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        Class vcClass = NSClassFromString(@"BackgroundTextureAccessViewController");
        id vc = [[vcClass alloc]  initWithNibName:nil bundle:nil];
        
        self.rootViewController = vc;
    }
    return self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // add the view associated to the root view controller
    UIView *view = self.rootViewController.view;
    view.frame = self.view.bounds;
    [self.view addSubview:view];
    
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
}




@end
