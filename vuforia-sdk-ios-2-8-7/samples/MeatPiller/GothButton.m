//
//  GothButton.m
//  MeatPiller
//
//  Created by Nathan on 1/4/14.
//  Copyright (c) 2014 Qualcomm. All rights reserved.
//

#import "GothButton.h"

@interface GothButton ()

@property (strong, nonatomic) UIActivityIndicatorView *activityView;

@end

@implementation GothButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [UIFont fontWithName:@"GothamCondensed-Light" size:32];
    self.titleLabel.layer.shadowRadius = 1.0;
    self.titleLabel.layer.shadowOpacity = 0.25;
    self.titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
}

- (void)showActivity
{
    self.titleLabel.alpha = 0;
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityView setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
    [self.activityView startAnimating];
    [self addSubview:self.activityView];
}

- (void)hideActivity
{
    self.titleLabel.alpha = 1;
    
    [self.activityView removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
