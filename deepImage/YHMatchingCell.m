//
//  YHMatchingCell.m
//  deepImage
//
//  Created by Yihhann on 13/6/15.
//  Copyright (c) 2013 Yihhann. All rights reserved.
//  Remark:
//    The only purpose of this class is to add an image to animate.
//

#import "YHMatchingCell.h"

@implementation YHMatchingCell
@synthesize imageInside;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [imageInside release];
    [super dealloc];
}
@end
