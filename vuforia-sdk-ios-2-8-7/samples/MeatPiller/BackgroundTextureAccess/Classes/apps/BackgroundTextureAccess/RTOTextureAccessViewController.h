/*==============================================================================
 Copyright (c) 2012-2013 Qualcomm Connected Experiences, Inc.
 All Rights Reserved.
 ==============================================================================*/

#import <UIKit/UIKit.h>
#import "SampleAppMenu.h"
#import "BackgroundTextureAccessEAGLView.h"
#import "SampleApplicationSession.h"
#import <QCAR/DataSet.h>

extern NSString *const kDidFindAllRequiredTrackables;

@interface RTOTextureAccessViewController : UIViewController <SampleApplicationControl, SampleAppMenuCommandProtocol>{
    CGRect viewFrame;
    CGRect arViewRect; // the size of the AR view

    BackgroundTextureAccessEAGLView* eaglView;
    UITapGestureRecognizer * tapGestureRecognizer;
    SampleApplicationSession * vapp;
    QCAR::DataSet*  dataSet;
    
}

@property (nonatomic, strong) id backgroundObserver;
@property (nonatomic, strong) id activeObserver;
@property (assign, nonatomic) NSInteger currentStep;

@end
