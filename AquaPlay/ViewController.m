//
//  ViewController.m
//  AquaPlay
//
//  Created by Ramon Carvalho Maciel on 4/3/14.
//  Copyright (c) 2014 Rock Bottom. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *objView1;
@property (weak, nonatomic) IBOutlet UIView *objView2;
@property (weak, nonatomic) IBOutlet UIView *objView3;
@property (weak, nonatomic) IBOutlet UIView *objView4;
@property (weak, nonatomic) IBOutlet UIView *objView5;
@property (strong) UIDynamicAnimator* animator;
@property (strong) UIGravityBehavior* gravity;
@property (strong) UICollisionBehavior* collision;
@property (weak, nonatomic) IBOutlet UIView *obstacle1;
@property (weak, nonatomic) IBOutlet UIView *obstacle2;
@property (weak, nonatomic) IBOutlet UIView *obstacle3;
@property (strong) NSMutableArray* obstacles;
@property (strong) NSMutableArray* foregroundObjects;
@property (strong) NSMutableArray* etherealObjects;
@property (strong) NSMutableArray* foregroundCollisionArray;
@property (strong) NSMutableArray* allObjects;
@property (strong) UIDynamicItemBehavior* dynamicBehavior;

@property (weak, nonatomic) IBOutlet UIView *ringLeft;
@property (weak, nonatomic) IBOutlet UIView *ringRight;
@property (weak, nonatomic) IBOutlet UIView *ringCenter;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.obstacles = [[NSMutableArray alloc] initWithArray:@[self.obstacle1,self.obstacle2,self.obstacle3]];
    self.foregroundObjects = [[NSMutableArray alloc] initWithArray:@[self.objView1,self.objView2,self.objView3,self.objView4,self.objView5,self.ringLeft,self.ringRight]];
    self.etherealObjects = [[NSMutableArray alloc] initWithArray:@[self.ringCenter]];
    
    self.foregroundCollisionArray = [[NSMutableArray alloc] initWithArray:self.obstacles];
    [self.foregroundCollisionArray addObjectsFromArray:self.foregroundObjects];
    
    self.allObjects = [[NSMutableArray alloc] initWithArray:self.foregroundCollisionArray];
    [self.allObjects addObjectsFromArray:self.etherealObjects];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.gravity = [[UIGravityBehavior alloc] initWithItems:self.foregroundObjects];
    self.collision = [[UICollisionBehavior alloc] initWithItems:self.foregroundCollisionArray];
    self.dynamicBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.allObjects];
    
    for (UIView *obstacle in self.obstacles) {
        UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:obstacle attachedToAnchor:obstacle.center];
        [self.animator addBehavior:attachment];
    }
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.obstacles];
    itemBehavior.allowsRotation = NO;
    [self.animator addBehavior:itemBehavior];
    
    self.gravity.magnitude = 0.5;
    self.collision.translatesReferenceBoundsIntoBoundary = YES;
    self.dynamicBehavior.elasticity = 0.5;
    
    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.collision];
    [self.animator addBehavior:self.dynamicBehavior];
    
    
    UIAttachmentBehavior* attach = [[UIAttachmentBehavior alloc] initWithItem:self.ringLeft attachedToItem:self.ringRight];
    attach.damping = 0;
    [self.animator addBehavior:attach];
    
    attach = [[UIAttachmentBehavior alloc] initWithItem:self.ringCenter attachedToItem:self.ringRight];
    attach.damping = 0;
    [self.animator addBehavior:attach];
    
    attach = [[UIAttachmentBehavior alloc] initWithItem:self.ringCenter attachedToItem:self.ringLeft];
    attach.damping = 0;
    [self.animator addBehavior:attach];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer: singleTap];
    
}

- (IBAction)bottomLeftButton:(id)sender {
    for (UIView *obj in self.foregroundObjects) {
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
    for (UIView *obj in self.foregroundObjects) {
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


@end
