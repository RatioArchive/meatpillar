//
//  CongratsViewController.m
//  MeatPiller
//
//  Created by Nathan on 1/4/14.
//  Copyright (c) 2014 Qualcomm. All rights reserved.
//

#import "CongratsViewController.h"

@interface CongratsViewController ()

- (IBAction)redeemButtonTapped:(UIButton *)sender;

@end

@implementation CongratsViewController

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

- (IBAction)redeemButtonTapped:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowRedeem" object:nil];
}
@end
