//
//  RingView.m
//  AquaPlay
//
//  Created by Ramon Carvalho Maciel on 4/9/14.
//  Copyright (c) 2014 Rock Bottom. All rights reserved.
//

#import "RingView.h"
#define BLOCK_MODE NO

@implementation RingView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		[self initiateRing];
	}
	return self;
}

#pragma mark - View Generator

UIColor *color;

- (void)initiateRing {
	// drop shadow
	if (!self.left) {
		CGRect rect = CGRectApplyAffineTransform(self.frame, CGAffineTransformMakeScale(0.25, 1));
		rect.origin.x = 0;
		rect.origin.y = 0;
		self.left = [[UIView alloc] initWithFrame:rect];
//		[self addSubview:self.left];
	}

	if (!self.right) {
		CGRect rect = CGRectApplyAffineTransform(self.frame, CGAffineTransformMakeScale(0.25, 1));
		rect.origin.x = self.frame.size.width - rect.size.width;
		rect.origin.y = 0;
		self.right = [[UIView alloc] initWithFrame:rect];
//		[self addSubview:self.right];
	}

	[self setColor:[self randomColor]];
}

- (void)addSidesToSuperView {
	[self.superview addSubview:self.right];
	[self.superview addSubview:self.left];
}

#pragma mark - Colors

- (UIColor *)randomColor {
	CGFloat hue = (arc4random() % 256 / 256.0);   // 0.0 to 1.0
	CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;   // 0.5 to 1.0, away from white
	CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;   // 0.5 to 1.0, away from black
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (UIColor *)lighterColor:(UIColor *)c {
	CGFloat h, s, b, a;
	if ([c getHue:&h saturation:&s brightness:&b alpha:&a])
		return [UIColor colorWithHue:h
		                  saturation:s
		                  brightness:MIN(b * 1.3, 1.0)
		                       alpha:a];
	return nil;
}

- (UIColor *)darkerColor:(UIColor *)c {
	CGFloat h, s, b, a;
	if ([c getHue:&h saturation:&s brightness:&b alpha:&a])
		return [UIColor colorWithHue:h
		                  saturation:s
		                  brightness:b * 0.75
		                       alpha:a];
	return nil;
}

- (void)setColor:(UIColor *)newColor {
	color = newColor;
	self.backgroundColor = color;
	if (BLOCK_MODE) {
		self.left.backgroundColor = color;
		self.right.backgroundColor = color;
	}
	else {
		self.left.backgroundColor = [self darkerColor:color];
		self.right.backgroundColor = [self darkerColor:color];
	}
}

@end
