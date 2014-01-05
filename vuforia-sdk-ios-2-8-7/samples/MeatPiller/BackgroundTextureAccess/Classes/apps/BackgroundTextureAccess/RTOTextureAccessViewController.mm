/*==============================================================================
 Copyright (c) 2012-2013 Qualcomm Connected Experiences, Inc.
 All Rights Reserved.
 ==============================================================================*/

#import "RTOTextureAccessViewController.h"
#import <QCAR/QCAR.h>
#import <QCAR/TrackerManager.h>
#import <QCAR/ImageTracker.h>
#import <QCAR/DataSet.h>
#import <QCAR/CameraDevice.h>
#import <QCAR/TrackableResult.h>

@interface RTOTextureAccessViewController () <BackgroundTextureAccessEAGLDelegate>
@property (nonatomic, strong) NSMutableSet *foundItems;
@property (strong, nonatomic) UIImageView *titleImage;
@property (strong, nonatomic) UIView *congratsView;
@property (strong, nonatomic) UIView *redeemView;
@end

@implementation RTOTextureAccessViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        vapp = [[SampleApplicationSession alloc] initWithDelegate:self];
        
        // Create the EAGLView with the screen dimensions
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        viewFrame = screenBounds;
        
        arViewRect.size = [[UIScreen mainScreen] bounds].size;
        arViewRect.origin.x = arViewRect.origin.y = 0;
        
        
        // If this device has a retina display, scale the view bounds that will
        // be passed to QCAR; this allows it to calculate the size and position of
        // the viewport correctly when rendering the video background
        if (YES == vapp.isRetinaDisplay) {
            viewFrame.size.width *= 2.0;
            viewFrame.size.height *= 2.0;
        }
        
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autofocus:)];
        
        self.titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Title"]];
        self.titleImage.frame = CGRectMake(-100, 114, 320, 89);
        self.titleImage.contentMode = UIViewContentModeCenter;
        self.titleImage.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        [self.view addSubview:self.titleImage];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.backgroundObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.activeObserver];
    
    self.backgroundObserver = nil;
    self.activeObserver = nil;
    
}

- (void)showCongrats
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect windowFrame = self.view.window.frame;
        windowFrame.origin.y -= 124;
        windowFrame.origin.x += 124;
        
        UIView *shadowView = [[UIView alloc] initWithFrame:windowFrame];
        shadowView.backgroundColor = [UIColor blackColor];
        shadowView.alpha = 0;
        shadowView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        [self.view insertSubview:shadowView belowSubview:self.titleImage];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone_Storyboard" bundle:nil];
        UIViewController* congratsViewController = [storyboard instantiateViewControllerWithIdentifier:@"Congrats"];
        self.congratsView = congratsViewController.view;
        
        [self addChildViewController:congratsViewController];
        [self.view insertSubview:self.congratsView belowSubview:self.titleImage];
        self.congratsView.frame = windowFrame;
        self.congratsView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        self.congratsView.alpha = 0;
        [congratsViewController didMoveToParentViewController:self];
        
        [UIView animateWithDuration:.5 animations:^{
            
            shadowView.alpha = .7;
            self.congratsView.alpha = 1;
            
        } completion:nil];
    });
}

- (void)showRedeem
{
    CGRect windowFrame = self.view.window.frame;
    windowFrame.origin.y -= 124;
    windowFrame.origin.x += 124;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"iPhone_Storyboard" bundle:nil];
    UIViewController* redeemViewController = [storyboard instantiateViewControllerWithIdentifier:@"Redeem"];
    self.redeemView = redeemViewController.view;
    
    [self addChildViewController:redeemViewController];
    [self.view insertSubview:self.redeemView belowSubview:self.titleImage];
    self.redeemView.frame = CGRectMake(windowFrame.origin.x + 380, windowFrame.origin.y, windowFrame.size.width, windowFrame.size.height);
    self.redeemView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    [redeemViewController didMoveToParentViewController:self];
    
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        CGRect frame = self.congratsView.frame;
        frame.origin.x += CGRectGetHeight(self.view.window.frame);
        self.congratsView.frame = frame;
        
    } completion:nil];
    
    [UIView animateKeyframesWithDuration:.5 delay:.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        CGRect frame = self.redeemView.frame;
        frame.origin.x = self.view.window.frame.origin.x;
        self.redeemView.frame = frame;
        
    } completion:nil];
}

- (void)loadView {
    self.foundItems = [NSMutableSet setWithCapacity:3];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showRedeem)
                                                 name:@"ShowRedeem"
                                               object:nil];
    
    // Create the EAGLView
    eaglView = [[BackgroundTextureAccessEAGLView alloc] initWithFrame:viewFrame appSession:vapp];
    eaglView.delegate = self;
    [self setView:eaglView];
    
    // as the view is in landscape, we need to adjust the position of the spinner accordingly
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    CGRect indicatorBounds = CGRectMake(mainBounds.size.height / 2 - 12,
                                        mainBounds.size.width / 2 - 12, 24, 24);
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc]
                                          initWithFrame:indicatorBounds];
    
    loadingIndicator.tag  = 1;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [eaglView addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
    
    [vapp initAR:QCAR::GL_20 ARViewBoundsSize:viewFrame.size orientation:UIInterfaceOrientationLandscapeRight];
    
    self.backgroundObserver = [[NSNotificationCenter defaultCenter]
                          addObserverForName:UIApplicationWillResignActiveNotification
                          object:nil
                          queue:nil
                          usingBlock:^(NSNotification *note) {
                              NSError * error = nil;
                              if(! [vapp pauseAR:&error]) {
                                  NSLog(@"Error pausing AR:%@", [error description]);
                              }
                          } ];
    
    self.activeObserver = [[NSNotificationCenter defaultCenter]
                      addObserverForName:UIApplicationDidBecomeActiveNotification
                      object:nil
                      queue:nil
                      usingBlock:^(NSNotification *note) {
                          NSError * error = nil;
                          if(! [vapp resumeAR:&error]) {
                              NSLog(@"Error resuming AR:%@", [error description]);
                          }
                          // on resume, we reset the flash and the associated menu item
                          QCAR::CameraDevice::getInstance().setFlashTorchMode(false);
                          SampleAppMenu * menu = [SampleAppMenu instance];
                          [menu setSelectionValueForCommand:C_FLASH value:false];
                      } ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self handleARViewRotation:self.interfaceOrientation];

    [self prepareMenu];

  // Do any additional setup after loading the view.
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
//    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    NSLog(@"self.navigationController.navigationBarHidden:%d",self.navigationController.navigationBarHidden);
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self showCongrats];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // make sure we're oriented/sized properly before reappearing/restarting
    [self handleARViewRotation:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [vapp stopAR:nil];
    // Be a good OpenGL ES citizen: now that QCAR is paused and the render
    // thread is not executing, inform the root view controller that the
    // EAGLView should finish any OpenGL ES commands
    [eaglView finishOpenGLESCommands];

}

- (void)finishOpenGLESCommands
{
    // Called in response to applicationWillResignActive.  Inform the EAGLView
    [eaglView finishOpenGLESCommands];
}


- (void)freeOpenGLESResources
{
    // Called in response to applicationDidEnterBackground.  Inform the EAGLView
    [eaglView freeOpenGLESResources];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This is called on iOS 4 devices (when built with SDK 5.1 or 6.0) and iOS 6
// devices (when built with SDK 5.1)
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    // ensure overlay size and AR orientation is correct for screen orientation
    [self handleARViewRotation:self.interfaceOrientation];
}


- (void) handleARViewRotation:(UIInterfaceOrientation)interfaceOrientation
{
    CGPoint centre, pos;
    NSInteger rot;
    
    // Set the EAGLView's position (its centre) to be the centre of the window, based on orientation
    centre.x = arViewRect.size.width / 2;
    centre.y = arViewRect.size.height / 2;
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        NSLog(@"ARVC: Rotating to Portrait");
        pos = centre;
        rot = 90;
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        NSLog(@"ARVC: Rotating to Upside Down");
        pos = centre;
        rot = 270;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        NSLog(@"ARVC: Rotating to Landscape Left");
        pos.x = centre.y;
        pos.y = centre.x;
        rot = 180;
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        NSLog(@"ARParent: Rotating to Landscape Right");
        pos.x = centre.y;
        pos.y = centre.x;
        rot = 0;
    } else {
        pos = centre;
        rot = 90;
    }
    
    CGAffineTransform rotate = CGAffineTransformMakeRotation(rot * M_PI  / 180);
    
    [eaglView setOrientationTransform:rotate withLayerPosition:pos];
}



#pragma mark - SampleApplicationControl

// Initialize the application trackers        
- (bool) doInitTrackers {
    // Initialize the image tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* trackerBase = trackerManager.initTracker(QCAR::ImageTracker::getClassType());
    if (trackerBase == NULL)
    {
        NSLog(@"Failed to initialize ImageTracker.");
        return false;
    }
    return true;
}

// load the data associated to the trackers
- (bool) doLoadTrackersData {
    return [self loadAndActivateImageTrackerDataSet:@"MeatPiller.xml"];;
}

// start the application trackers
- (bool) doStartTrackers {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ImageTracker::getClassType());
    if(tracker == 0) {
        return false;
    }
    tracker->start();
    return true;
}

// callback called when the initailization of the AR is done
- (void) onInitARDone:(NSError *)initError {
    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[eaglView viewWithTag:1];
    [loadingIndicator removeFromSuperview];
    
    if (initError == nil) {
        NSError * error = nil;
        [vapp startAR:QCAR::CameraDevice::CAMERA_BACK error:&error];

        //notify the opengl view that the camera is started
        [eaglView cameraDidStart];

        
        // by default, we try to set the continuous auto focus mode
        // and we update menu to reflect the state of continuous auto-focus
        bool isContinuousAutofocus = QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO);
        SampleAppMenu * menu = [SampleAppMenu instance];
        [menu setSelectionValueForCommand:C_AUTOFOCUS value:isContinuousAutofocus];

    } else {
        NSLog(@"Error initializing AR:%@", [initError description]);
    }
}

// update from the QCAR loop
- (void) onQCARUpdate: (QCAR::State *) state {
}

// stop your trackerts
- (bool) doStopTrackers {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ImageTracker::getClassType());
    
    if (NULL == tracker) {
        NSLog(@"ERROR: failed to get the tracker from the tracker manager");
        return false;
    }
    
    tracker->stop();
    return true;
}

// unload the data associated to your trackers
- (bool) doUnloadTrackersData {
    if (dataSet != NULL) {
        // Get the image tracker:
        QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
        QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
        
        if (imageTracker == NULL)
        {
            NSLog(@"Failed to unload tracking data set because the ImageTracker has not been initialized.");
            return false;
        }
        // Activate the data set:
        if (!imageTracker->deactivateDataSet(dataSet))
        {
            NSLog(@"Failed to deactivate data set.");
            return false;
        }
        dataSet = NULL;
    }
    return true;
}

// deinitialize your trackers
- (bool) doDeinitTrackers {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    trackerManager.deinitTracker(QCAR::ImageTracker::getClassType());
    return true;
}

- (void)autofocus:(UITapGestureRecognizer *)sender
{
    [self performSelector:@selector(cameraPerformAutoFocus) withObject:nil afterDelay:.4];
}

- (void)cameraPerformAutoFocus
{
    QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_TRIGGERAUTO);
}

// Load the image tracker data set
- (BOOL)loadAndActivateImageTrackerDataSet:(NSString*)dataFile
{
    NSLog(@"loadAndActivateImageTrackerDataSet (%@)", dataFile);
    BOOL ret = YES;
    dataSet = NULL;
    
    // Get the QCAR tracker manager image tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    
    if (NULL == imageTracker) {
        NSLog(@"ERROR: failed to get the ImageTracker from the tracker manager");
        ret = NO;
    } else {
        dataSet = imageTracker->createDataSet();
        
        if (NULL != dataSet) {
            // Load the data set from the app's resources location
            bool didLoadData = dataSet->load([dataFile cStringUsingEncoding:NSASCIIStringEncoding], QCAR::DataSet::STORAGE_APPRESOURCE);
            if (!didLoadData) {
                NSLog(@"ERROR: failed to load data set");
                imageTracker->destroyDataSet(dataSet);
                dataSet = NULL;
                ret = NO;
            } else {
                // Activate the data set
                if (imageTracker->activateDataSet(dataSet)) {
                    NSLog(@"INFO: successfully activated data set");
                }
                else {
                    NSLog(@"ERROR: failed to activate data set");
                    ret = NO;
                }
            }
        }
        else {
            NSLog(@"ERROR: failed to create data set");
            ret = NO;
        }
        
    }
    
    return ret;
}



#pragma mark - left menu

typedef enum {
    C_AUTOFOCUS,
    C_FLASH
} MENU_COMMAND;

- (void) prepareMenu {
    
    SampleAppMenu * menu = [SampleAppMenu prepareWithCommandProtocol:self title:@"Background Texture"];
    SampleAppMenuGroup * group;
    
    group = [menu addGroup:@""];
    [group addTextItem:@"About" command:-1];

    group = [menu addGroup:@""];
    [group addSelectionItem:@"Autofocus" command:C_AUTOFOCUS isSelected:true];
    [group addSelectionItem:@"Flash" command:C_FLASH isSelected:false];

}

- (bool) menuProcess:(SampleAppMenu *) menu command:(int) command value:(bool) value{
    bool result = true;

    switch(command) {
        case C_FLASH:
            if (!QCAR::CameraDevice::getInstance().setFlashTorchMode(value)) {
                result = false;
            }
            break;
            
        case C_AUTOFOCUS: {
            int focusMode = value ? QCAR::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO : QCAR::CameraDevice::FOCUS_MODE_NORMAL;
            result = QCAR::CameraDevice::getInstance().setFocusMode(focusMode);
        }
            break;
            
            
        default:
            result = false;
            break;
    }
    return result;
}


- (void)foundTrackableWithName:(NSString *)name {
    NSLog(@"%@", name);
    [self.foundItems addObject:name];
    if ([self.foundItems count]==2) {
        [self showCongrats];
    }
}


#pragma mark - Delegates

- (void)backgroundTextureView:(id)view addedTrackableWithNames:(NSMutableSet *)trackableNames {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *name = [trackableNames anyObject];
        self.title = name;
        [self foundTrackableWithName:name];
    }];
}

- (void)backgroundTextureView:(id)view removedTrackableWithNames:(NSMutableSet *)trackableNames {
    if ([self.title isEqualToString:[trackableNames anyObject]]) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.title = @"";
        }];
    }
}

- (void)backgroundTextureView:(id)view willRenderTrackable:(const QCAR::Trackable&)trackable {
    const char* name = trackable.getName();
    NSString *nameString = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    
    NSInteger trackableID = trackable.getId();
    NSLog(@"name %@ %d", nameString, trackableID);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.title = nameString;
    }];
    
}

@end

