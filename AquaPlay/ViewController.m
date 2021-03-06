//
//  ViewController.m
//  AquaPlay
//
//  Created by Ramon Carvalho Maciel on 4/3/14.
//  Copyright (c) 2014 Rock Bottom. All rights reserved.
//

#import "ViewController.h"
#import "RingView.h"

#define RING_WIDTH 50
#define RING_SIDE RING_WIDTH / 4
#define RING_HEIGHT 18
#define RING_DENSITY 0.40
#define RING_ELASTICITY 0.05
#define NUMBER_RINGS 6

@interface ViewController ()
@property (strong) UIDynamicAnimator *animator;
@property (strong) UIGravityBehavior *gravity;
@property (strong) UICollisionBehavior *collisionForeground;
@property (strong) UICollisionBehavior *collisionBackground;

@property (weak, nonatomic) IBOutlet UIView *obstacle1;
@property (weak, nonatomic) IBOutlet UIView *obstacle2;
@property (weak, nonatomic) IBOutlet UIView *obstacle3;
@property (weak, nonatomic) IBOutlet UIView *bottomObstacle;


@property (strong) NSMutableArray *obstacles;
@property (strong) NSMutableArray *collisionGroup;
@property (strong) NSMutableArray *etherealObjects;
@property (strong) NSMutableArray *allObjects;

@property (strong) UIDynamicItemBehavior *dynamicBehavior;

@property (strong) NSMutableArray *ringArray;
@property (strong) NSMutableArray *leftArray;
@property (strong) NSMutableArray *rightArray;

@end

@implementation ViewController

CGPoint rightCorner;
CGPoint leftCorner;

- (void)viewDidLoad {
	self.rippleImageName = @"background.jpg";

	[super viewDidLoad];

	leftCorner = CGPointMake(self.view.frame.origin.x, self.view.frame.size.height - self.bottomObstacle.frame.size.height);
	rightCorner = CGPointMake(self.view.frame.size.width, self.view.frame.size.height - self.bottomObstacle.frame.size.height);

	self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

	self.ringArray = [[NSMutableArray alloc] init];
	self.leftArray = [[NSMutableArray alloc] init];
	self.rightArray = [[NSMutableArray alloc] init];
	[self createRings:NUMBER_RINGS];

	self.dynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.ringArray];
	self.dynamicBehavior.density = RING_DENSITY;
	self.dynamicBehavior.elasticity = RING_ELASTICITY;
	[self.animator addBehavior:self.dynamicBehavior];

	for (RingView *ring in self.ringArray) {
		UIAttachmentBehavior *leftAttachment = [[UIAttachmentBehavior alloc] initWithItem:ring.left offsetFromCenter:UIOffsetMake(0, -RING_HEIGHT / 4) attachedToItem:ring offsetFromCenter:UIOffsetMake(-1.5 * RING_SIDE, -RING_HEIGHT / 4)];
		[leftAttachment setLength:0];
		[self.animator addBehavior:leftAttachment];
		UIAttachmentBehavior *rightAttachment = [[UIAttachmentBehavior alloc] initWithItem:ring.right offsetFromCenter:UIOffsetMake(0, -RING_HEIGHT / 4) attachedToItem:ring offsetFromCenter:UIOffsetMake(1.5 * RING_SIDE, -RING_HEIGHT / 4)];
		[rightAttachment setLength:0];
		[self.animator addBehavior:rightAttachment];
	}

	for (RingView *ring in self.ringArray) {
		UIAttachmentBehavior *leftAttachment = [[UIAttachmentBehavior alloc] initWithItem:ring.left offsetFromCenter:UIOffsetMake(0, RING_HEIGHT / 4) attachedToItem:ring offsetFromCenter:UIOffsetMake(-1.5 * RING_SIDE, RING_HEIGHT / 4)];
		[leftAttachment setLength:0];
		[self.animator addBehavior:leftAttachment];
		UIAttachmentBehavior *rightAttachment = [[UIAttachmentBehavior alloc] initWithItem:ring.right offsetFromCenter:UIOffsetMake(0, RING_HEIGHT / 4) attachedToItem:ring offsetFromCenter:UIOffsetMake(1.5 * RING_SIDE, RING_HEIGHT / 4)];
		[rightAttachment setLength:0];
		[self.animator addBehavior:rightAttachment];
	}


	self.obstacles = [[NSMutableArray alloc] initWithArray:@[self.obstacle1, self.obstacle2, self.obstacle3, self.bottomObstacle]];
	for (UIView *obstacle in self.obstacles) {
		UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:obstacle attachedToAnchor:obstacle.center];
		[self.animator addBehavior:attachment];
	}

	self.collisionGroup = [[NSMutableArray alloc] initWithArray:self.obstacles];
	[self.collisionGroup addObjectsFromArray:self.leftArray];
	[self.collisionGroup addObjectsFromArray:self.rightArray];

	self.collisionForeground = [[UICollisionBehavior alloc] initWithItems:self.collisionGroup];
	self.collisionForeground.translatesReferenceBoundsIntoBoundary = YES;
	[self.animator addBehavior:self.collisionForeground];

	self.collisionBackground = [[UICollisionBehavior alloc] initWithItems:self.ringArray];
	self.collisionBackground.translatesReferenceBoundsIntoBoundary = YES;
	[self.animator addBehavior:self.collisionBackground];

	UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.obstacles];
	itemBehavior.allowsRotation = NO;
	[self.animator addBehavior:itemBehavior];

	self.gravity = [[UIGravityBehavior alloc] initWithItems:self.ringArray];
	self.gravity.magnitude = 0.5;
	[self.animator addBehavior:self.gravity];


	// Tap Gesture Recognizer
//	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//
//	singleTap.numberOfTapsRequired = 1;
//	singleTap.numberOfTouchesRequired = 1;
//	[self.view addGestureRecognizer:singleTap];
}

- (IBAction)bottomLeftButton:(id)sender {
	for (UIView *obj in self.ringArray) {
		UIPushBehavior *pushBehavior;
		pushBehavior = [[UIPushBehavior alloc] initWithItems:@[obj] mode:UIPushBehaviorModeInstantaneous];
		pushBehavior.magnitude = 0.0f;
		pushBehavior.angle = 0.0f;
		[self.animator addBehavior:pushBehavior];

		CGPoint distanceVector = [self vectorFromPoint:obj.center toPoint:leftCorner];
		CGFloat distance = sqrt((distanceVector.x * distanceVector.x) + (distanceVector.y * distanceVector.y)) + 10;
		CGFloat originForce = -7.0f;
		originForce /= pow(distance, 2.05);

		NSLog(@"%f %f", distanceVector.x, distanceVector.y);

		pushBehavior.pushDirection = CGVectorMake(originForce * distanceVector.y, 2 * originForce * distanceVector.x);
		pushBehavior.active = YES;
		[_ripple initiateRippleAtLocation:leftCorner];
	}
}

- (IBAction)bottomRightButton:(id)sender {
	for (UIView *obj in self.ringArray) {
		UIPushBehavior *pushBehavior;
		pushBehavior = [[UIPushBehavior alloc] initWithItems:@[obj] mode:UIPushBehaviorModeInstantaneous];
		pushBehavior.magnitude = 0.0f;
		pushBehavior.angle = 0.0f;
		[self.animator addBehavior:pushBehavior];

		CGPoint distanceVector = [self vectorFromPoint:obj.center toPoint:rightCorner];
		CGFloat distance = sqrt((distanceVector.x * distanceVector.x) + (distanceVector.y * distanceVector.y)) + 10;
		CGFloat originForce = 7.0f;
		originForce /= pow(distance, 2.05);

		NSLog(@"%f %f", distanceVector.x, distanceVector.y);

		pushBehavior.pushDirection = CGVectorMake(originForce * distanceVector.y, 2 * originForce * distanceVector.x);
		pushBehavior.active = YES;
		[_ripple initiateRippleAtLocation:rightCorner];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self startMyMotionDetect];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.motionManager stopAccelerometerUpdates];
}

- (CMMotionManager *)motionManager {
	CMMotionManager *motionManager = nil;

	id appDelegate = [UIApplication sharedApplication].delegate;

	if ([appDelegate respondsToSelector:@selector(motionManager)]) {
		motionManager = [appDelegate motionManager];
	}

	return motionManager;
}

- (void)startMyMotionDetect {
	[self.motionManager
	 startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
	                      withHandler: ^(CMAccelerometerData *data, NSError *error)
	{
	    dispatch_async(dispatch_get_main_queue(),
	                   ^{
	        self.gravity.gravityDirection = CGVectorMake(data.acceleration.x / 6, -data.acceleration.y / 6);
		}

	                   );
	}

	];
}

- (CGPoint)vectorFromPoint:(CGPoint)point toPoint:(CGPoint)origin {
	return CGPointMake(point.x - origin.x, point.y - origin.y);
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gr {
	CGPoint point = [gr locationInView:self.view];
	if (point.x < self.view.frame.size.width / 2.0f) [self bottomLeftButton:self];
	else [self bottomRightButton:self];
	NSLog(@"handleSingleTap");
}

- (void)createRings:(int)number {
	int numViews = 0;
	while (numViews < number) {
		BOOL goodView = YES;
		RingView *ring = [[RingView alloc] initWithFrame:CGRectMake(arc4random() % (int)self.view.frame.size.width, arc4random() % (int)self.view.frame.size.height, RING_WIDTH, RING_HEIGHT)];
		if (!CGRectContainsRect(self.view.frame, ring.frame)) {
			goodView = NO;
		}
		else {
			for (UIView *placedView in self.view.subviews) {
				if (CGRectIntersectsRect(CGRectInset(ring.frame, -10, -10), placedView.frame)) {
					goodView = NO;
					break;
				}
			}
		}
		if (goodView) {
			[self.view addSubview:ring];
			[ring addSidesToSuperView];
			ring.alpha = 0.8;

			UIColor *color;
			switch (arc4random() % 4) {
				case 0:
					color = [UIColor colorWithRed:1.000 green:0.027 blue:0.322 alpha:1.000];
					break;

				case 1:
					color = [UIColor colorWithRed:0.380 green:0.020 blue:1.000 alpha:1.000];
					break;

				case 2:
					color = [UIColor colorWithRed:0.126 green:0.728 blue:0.612 alpha:1.000];
					break;

				case 3:
					color = [UIColor colorWithRed:0.872 green:0.621 blue:0.068 alpha:1.000];
					break;

				default:
					break;
			}
			[ring setColor:color];

			[self.ringArray addObject:ring];
			[self.leftArray addObject:ring.left];
			[self.rightArray addObject:ring.right];
			numViews += 1;
		}
	}
}

@end
