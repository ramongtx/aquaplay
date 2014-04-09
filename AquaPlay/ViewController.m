//
//  ViewController.m
//  AquaPlay
//
//  Created by Ramon Carvalho Maciel on 4/3/14.
//  Copyright (c) 2014 Rock Bottom. All rights reserved.
//

#import "ViewController.h"
#import "RingView.h"

#define RING_WIDTH 60
#define RING_HEIGHT 20

@interface ViewController ()
@property (strong) UIDynamicAnimator* animator;
@property (strong) UIGravityBehavior* gravity;
@property (strong) UICollisionBehavior* collisionForeground;
@property (strong) UICollisionBehavior* collisionBackground;

@property (weak, nonatomic) IBOutlet UIView *objView1;
@property (weak, nonatomic) IBOutlet UIView *obstacle1;
@property (weak, nonatomic) IBOutlet UIView *obstacle2;
@property (weak, nonatomic) IBOutlet UIView *obstacle3;
@property (strong) NSMutableArray* obstacles;
@property (strong) NSMutableArray* collisionGroup;
@property (strong) NSMutableArray* etherealObjects;
@property (strong) NSMutableArray* foregroundCollisionArray;
@property (strong) NSMutableArray* allObjects;
@property (strong) UIDynamicItemBehavior* dynamicBehavior;

@property (weak, nonatomic) IBOutlet UIView *ringLeft;
@property (weak, nonatomic) IBOutlet UIView *ringRight;
@property (weak, nonatomic) IBOutlet UIView *ringCenter;

@property (strong) NSMutableArray* ringArray;
@property (strong) NSMutableArray* leftArray;
@property (strong) NSMutableArray* rightArray;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    self.ringArray = [[NSMutableArray alloc] init];
    self.leftArray = [[NSMutableArray alloc] init];
    self.rightArray = [[NSMutableArray alloc] init];
    [self createRings:3];
 
    self.gravity = [[UIGravityBehavior alloc] initWithItems:self.ringArray];
    self.gravity.magnitude = 0.5;
    [self.animator addBehavior:self.gravity];

    self.collisionBackground = [[UICollisionBehavior alloc] initWithItems:self.ringArray];
    self.collisionBackground.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:self.collisionBackground];

    self.dynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.ringArray];
    self.dynamicBehavior.density = 0.3;
    self.dynamicBehavior.elasticity = 0.5;
    [self.animator addBehavior:self.dynamicBehavior];


    for (UIView *obstacle in self.obstacles) {
        UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:obstacle attachedToAnchor:obstacle.center];
        [self.animator addBehavior:attachment];
    }
//
//    for (RingView* ring in self.ringArray) {
//        UIAttachmentBehavior *leftAttachment = [[UIAttachmentBehavior alloc] initWithItem:ring.left attachedToItem:ring];
//        [self.animator addBehavior:leftAttachment];
//        UIAttachmentBehavior *rightAttachment = [[UIAttachmentBehavior alloc] initWithItem:ring.right attachedToItem:ring];
//        [self.animator addBehavior:rightAttachment];
//    }
//
    
    
    
    self.obstacles = [[NSMutableArray alloc] initWithArray:@[self.obstacle1,self.obstacle2,self.obstacle3]];
    
    self.collisionGroup = [[NSMutableArray alloc] initWithArray:self.obstacles];
//    [self.collisionGroup addObjectsFromArray:self.leftArray];
//    [self.collisionGroup addObjectsFromArray:self.rightArray];
    
    self.collisionForeground = [[UICollisionBehavior alloc] initWithItems:self.collisionGroup];
    [self.animator addBehavior:self.collisionForeground];

    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.obstacles];
    itemBehavior.allowsRotation = NO;
    [self.animator addBehavior:itemBehavior];
    
    
    
    
    // Tap Gesture Recognizer
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer: singleTap];
}

- (IBAction)bottomLeftButton:(id)sender {
    for (UIView *obj in self.ringArray) {
        UIPushBehavior* pushBehavior;
        pushBehavior = [[UIPushBehavior alloc] initWithItems:@[obj] mode:UIPushBehaviorModeInstantaneous];
        pushBehavior.magnitude = 0.0f;
        pushBehavior.angle = 0.0f;
        [self.animator addBehavior:pushBehavior];
        
        CGPoint leftCorner = CGPointMake(self.view.frame.origin.x, self.view.frame.size.height);
        CGPoint distanceVector = [self vectorFromPoint:obj.center toPoint:leftCorner];
        CGFloat distance = sqrt((distanceVector.x*distanceVector.x)+(distanceVector.y*distanceVector.y))+10;
        CGFloat originForce = -7.0f;
        originForce /= pow(distance,2.05);
        
        NSLog(@"%f %f",distanceVector.x, distanceVector.y);
        
        pushBehavior.pushDirection = CGVectorMake(originForce*distanceVector.y,2*originForce*distanceVector.x);
        pushBehavior.active = YES;
        
    }
}

- (IBAction)bottomRightButton:(id)sender {
    for (UIView *obj in self.ringArray) {
        UIPushBehavior* pushBehavior;
        pushBehavior = [[UIPushBehavior alloc] initWithItems:@[obj] mode:UIPushBehaviorModeInstantaneous];
        pushBehavior.magnitude = 0.0f;
        pushBehavior.angle = 0.0f;
        [self.animator addBehavior:pushBehavior];
        
        CGPoint rightCorner = CGPointMake(self.view.frame.size.width, self.view.frame.size.height);
        CGPoint distanceVector = [self vectorFromPoint:obj.center toPoint:rightCorner];
        CGFloat distance = sqrt((distanceVector.x*distanceVector.x)+(distanceVector.y*distanceVector.y))+10;
        CGFloat originForce = 7.0f;
        originForce /= pow(distance,2.05);
        
        NSLog(@"%f %f",distanceVector.x, distanceVector.y);
        
        pushBehavior.pushDirection = CGVectorMake(originForce*distanceVector.y,2*originForce*distanceVector.x);
        pushBehavior.active = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startMyMotionDetect];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.motionManager stopAccelerometerUpdates];
}

- (CMMotionManager *)motionManager
{
    CMMotionManager *motionManager = nil;
    
    id appDelegate = [UIApplication sharedApplication].delegate;
    
    if ([appDelegate respondsToSelector:@selector(motionManager)]) {
        motionManager = [appDelegate motionManager];
    }
    
    return motionManager;
}

- (void)startMyMotionDetect
{
    
    [self.motionManager
     startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
     withHandler:^(CMAccelerometerData *data, NSError *error)
     {
         
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            self.gravity.gravityDirection = CGVectorMake(data.acceleration.x/6, -data.acceleration.y/6);
                        }
                        );
     }
     ];
    
}

-(CGPoint) vectorFromPoint:(CGPoint)point toPoint:(CGPoint)origin{
    return CGPointMake(point.x-origin.x, point.y-origin.y);
}

-(void) handleSingleTap:(UITapGestureRecognizer *)gr {
    CGPoint point = [gr locationInView:self.view];
    if (point.x < self.view.frame.size.width/2.0f) [self bottomLeftButton:self];
    else [self bottomRightButton:self];
    NSLog(@"handleSingleTap");
}

- (void) createRingAtPosition:(CGPoint)point
{
    RingView* ring = [[RingView alloc] initWithFrame:CGRectMake(point.x, point.y, RING_WIDTH, RING_HEIGHT)];
    [self.view addSubview:ring];
    [self.ringArray addObject:ring];
    [self.leftArray addObject:ring.left];
    [self.rightArray addObject:ring.right];
}

-(void) createRings:(int)number
{
    int numViews = 0;
    while (numViews < number) {
        BOOL goodView = YES;
        RingView *ring = [[RingView alloc] initWithFrame:CGRectMake(arc4random() % (int)self.view.frame.size.width, arc4random() % (int)self.view.frame.size.height, RING_WIDTH, RING_HEIGHT)];
        if (!CGRectContainsRect(self.view.frame, ring.frame)) {
            goodView = NO;
        } else {
            for (UIView *placedView in self.view.subviews) {
                if (CGRectIntersectsRect(CGRectInset(ring.frame, -10, -10), placedView.frame)) {
                    goodView = NO;
                    break;
                }
            }
        }
        if (goodView) {
            [self.view addSubview:ring];
            [self.ringArray addObject:ring];
            [self.leftArray addObject:ring.left];
            [self.rightArray addObject:ring.right];
            numViews += 1;
        }
    }
}

@end
