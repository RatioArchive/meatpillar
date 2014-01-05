//
//  RedeemViewController.m
//  MeatPiller
//
//  Created by Nathan on 1/4/14.
//  Copyright (c) 2014 Qualcomm. All rights reserved.
//

#import "RedeemViewController.h"
#import "GothButton.h"

@interface RedeemViewController () <UITextFieldDelegate>

- (IBAction)purchaseTapped:(UIButton *)sender;

@end

@implementation RedeemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)disableView
{
    for (id view in [self.view subviews])
    {
        if ([view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UITextField class]])
        {
            [view setEnabled:NO];
        }
    }
}

- (void)enableView
{
    for (id view in [self.view subviews])
    {
        if ([view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UITextField class]])
        {
            [view setEnabled:YES];
        }
    }
}

- (IBAction)purchaseTapped:(GothButton *)sender
{
    [self disableView];
    
    [sender showActivity];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}
@end
