//
//  GothLabel.m
//  MeatPiller
//
//  Created by Nathan on 1/4/14.
//  Copyright (c) 2014 Qualcomm. All rights reserved.
//

#import "GothLabel.h"

@implementation GothLabel

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
    self.font = [UIFont fontWithName:@"GothamCondensed-Light" size:self.font.pointSize];
    self.layer.shadowRadius = 1.0;
    self.layer.shadowOpacity = 0.25;
    self.layer.shadowOffset = CGSizeMake(0, 1);
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
