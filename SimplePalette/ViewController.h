//
//  ViewController.h
//  SimplePalette
//
//  Created by Kyle Yoon on 3/6/15.
//  Copyright (c) 2015 Kyle Yoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property NSMutableArray *colorViews;

@property UIView *shadeView;
@property UIDynamicAnimator *dynamicAnimator;
@property UICollisionBehavior *collisionBehavior;
@property UIGravityBehavior *gravityBehavior;
@property UIDynamicItemBehavior *dynamicItemBehavior;
@property UIPushBehavior *pushBehavior;

@end

