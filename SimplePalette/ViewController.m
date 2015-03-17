//
//  ViewController.m
//  SimplePalette
//
//  Created by Kyle Yoon on 3/6/15.
//  Copyright (c) 2015 Kyle Yoon. All rights reserved.
//

#import "ViewController.h"
#import "ColorView.h"

@interface ViewController () <UICollisionBehaviorDelegate>

@property (weak, nonatomic) IBOutlet UILabel *centerLabel;
@property NSMutableArray *colorViews;

@property UIView *shadeView;
@property UIDynamicAnimator *dynamicAnimator;
@property UICollisionBehavior *collisionBehavior;
@property UIGravityBehavior *gravityBehavior;
@property UIDynamicItemBehavior *dynamicItemBehavior;
@property UIPushBehavior *pushBehavior;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ColorView *firstView = [[ColorView alloc] initWithFrame:self.view.frame];
    firstView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:firstView];
    self.colorViews = [NSMutableArray arrayWithObject:firstView];
    
    [self.view bringSubviewToFront:self.centerLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.shadeView = [[UIView alloc] initWithFrame:self.view.frame];
    self.shadeView.backgroundColor = [UIColor whiteColor];
    self.shadeView.alpha = 0.0;
    [self.view addSubview:self.shadeView];
}

#pragma mark - IBActions

- (IBAction)tappedView:(UITapGestureRecognizer *)tap
{
    CGPoint tapPoint = [tap locationInView:self.view];
    ColorView *tappedView = [self findViewUsingPoint:tapPoint];
    if (tappedView) {
        [self getRandomColorAndHexForColorView:tappedView];
    }
}

- (IBAction)pinchedView:(UIPinchGestureRecognizer *)pinch
{
    if (pinch.state == UIGestureRecognizerStateBegan) {
        ColorView *newView = [[ColorView alloc] initWithFrame:CGRectMake(0, self.colorViews.count * self.view.frame.size.height / (self.colorViews.count + 1), self.view.frame.size.width, self.view.frame.size.height / (self.colorViews.count + 1))];
        newView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:newView];
        [self getRandomColorAndHexForColorView:newView];

        for (int i = 0; i < self.colorViews.count; i++) {
            ColorView *view = self.colorViews[i];
            view.frame = CGRectMake(0, i * self.view.frame.size.height / (self.colorViews.count + 1), self.view.frame.size.width, self.view.frame.size.height / (self.colorViews.count + 1));
        }
        
        [self.colorViews addObject:newView];
        [self.view bringSubviewToFront:self.shadeView];
    }
}

- (IBAction)longPressed:(UILongPressGestureRecognizer *)press
{
    if (press.state == UIGestureRecognizerStateBegan) {
        for (ColorView *view in self.colorViews) {
            UILabel *hexLabel = [[UILabel alloc] initWithFrame:view.frame];
            hexLabel.text = [NSString stringWithFormat:@"%@\r%@", view.colorName, view.hexString];
            hexLabel.textAlignment = NSTextAlignmentCenter;
            hexLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
            hexLabel.textColor = [UIColor darkGrayColor];
            hexLabel.numberOfLines = 0;
            hexLabel.alpha = 0.0;
            [self.shadeView addSubview:hexLabel];
        }
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.shadeView.alpha = 0.5;
            [self.shadeView.subviews setValue:@1.0 forKey:@"alpha"];
        } completion:nil];
    } else if (press.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.shadeView.alpha = 0.0;
            [self.shadeView.subviews setValue:@0 forKey:@"alpha"];
        } completion:^(BOOL finished) {
            [self.shadeView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }];
    }

}

#pragma mark - Convenience

- (ColorView *)findViewUsingPoint:(CGPoint)point
{
    for (ColorView *colorView in self.colorViews) {
        if (CGRectContainsPoint(colorView.frame, point)) {
            return colorView;
        }
    }
    return nil;
}

- (void)displayColorView:(ColorView *)view withColor:(UIColor *)color
{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.centerLabel.hidden = YES;
                         view.backgroundColor = color;
                     }
                     completion:nil];
}

#pragma mark - Networking

- (void)getRandomColorAndHexForColorView:(ColorView *)view
{
    NSString *urlString = @"http://www.colourlovers.com/api/colors/random&format=json";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __weak typeof(self) weakSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"Connection error: %@", connectionError.description);
        } else {
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];
            NSDictionary *colorDictionary = array.firstObject;
            view.colorName = colorDictionary[@"title"];
            view.hexString = colorDictionary[@"hex"];
            
            NSDictionary *RGB = colorDictionary[@"rgb"];
            UIColor *randomColor = [UIColor colorWithRed:[[RGB objectForKey:@"red"] floatValue]/255.0
                                                   green:[[RGB objectForKey:@"green"] floatValue]/255.0
                                                    blue:[[RGB objectForKey:@"blue"] floatValue]/255.0
                                                   alpha:1.0];
            [weakSelf displayColorView:view withColor:randomColor];
        }
    }];
}



@end
