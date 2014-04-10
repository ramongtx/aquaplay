//
//  RingView.h
//  AquaPlay
//
//  Created by Ramon Carvalho Maciel on 4/9/14.
//  Copyright (c) 2014 Rock Bottom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RingView : UIView
@property (strong) UIView *left, *right;

- (void)initiateRing;
- (void)setColor:(UIColor *)newColor;
- (void)addSidesToSuperView;
@end
