//
//  ViewController.m
//  SimplePalette
//
//  Created by Kyle Yoon on 3/6/15.
//  Copyright (c) 2015 Kyle Yoon. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *centerLabel;
@property NSMutableArray *hexCodes;
@property NSMutableArray *colorViews;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *firstView = [[UIView alloc] initWithFrame:self.view.frame];
    firstView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:firstView];
    [self.view bringSubviewToFront:self.centerLabel];
    
    self.hexCodes = [NSMutableArray array];
    self.colorViews = [NSMutableArray arrayWithObject:firstView];
}

- (IBAction)tappedView:(UITapGestureRecognizer *)tap
{
    CGPoint tapPoint = [tap locationInView:self.view];
    UIView *tappedView = [self findViewUsingPoint:tapPoint];
    if (tappedView) {
        [self getRandomColorWithCompletion:^(UIColor *color) {
            [self displayRandomColor:color forView:tappedView];
        }];
    }
}

- (UIView *)findViewUsingPoint:(CGPoint)point
{
    for (UIView *colorView in self.colorViews) {
        NSLog(@"colorView: %@", colorView);
        if (CGRectContainsPoint(colorView.frame, point)) {
            NSLog(@"RETURNING");
            return colorView;
        }
    }
    return nil;
}

- (void)getRandomColorWithCompletion:(void (^)(UIColor *color))completion
{
    NSString *urlString = @"http://www.colourlovers.com/api/colors/random&format=json";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"Connection error: %@", connectionError.description);
        } else {
            NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"array: %@", array);
            NSDictionary *colorDictionary = array.firstObject;
            NSDictionary *RGB = colorDictionary[@"rgb"];
            NSString *hex = colorDictionary[@"hex"];
            [self.hexCodes addObject:hex];

            UIColor *randomColor = [UIColor colorWithRed:[[RGB objectForKey:@"red"] floatValue]/255.0 green:[[RGB objectForKey:@"green"] floatValue]/255.0 blue:[[RGB objectForKey:@"blue"] floatValue]/255.0 alpha:1.0];
            completion(randomColor);
        }
    }];
}

- (void)displayRandomColor:(UIColor *)color forView:(UIView *)view
{
    [UIView animateWithDuration:0.5 animations:^{
        self.centerLabel.hidden = YES;
        view.backgroundColor = color;
    }];
}

- (IBAction)longPressedView:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self.view bringSubviewToFront:self.centerLabel];
        self.centerLabel.hidden = NO;
        self.centerLabel.text = self.hexCodes.firstObject;
        NSLog(@"%@", self.centerLabel.text);
    } else if (longPress.state == UIGestureRecognizerStateEnded) {
        self.centerLabel.hidden = YES;
    }
}

- (IBAction)pinchedView:(UIPinchGestureRecognizer *)pinch
{
    if (pinch.state == UIGestureRecognizerStateBegan) {
        NSLog(@"PINCHED");
        UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, self.colorViews.count * self.view.frame.size.height / (self.colorViews.count + 1), self.view.frame.size.width, self.view.frame.size.height / (self.colorViews.count + 1))];
        newView.backgroundColor = [UIColor whiteColor];
        for (int i = 0; i < self.colorViews.count; i++) {
            UIView *view = self.colorViews[i];
            NSLog(@"view: %@", view);
            view.frame = CGRectMake(0, i * self.view.frame.size.height / (self.colorViews.count + 1), self.view.frame.size.width, self.view.frame.size.height / (self.colorViews.count + 1));
            NSLog(@"view: %@", view);
            [self.view layoutSubviews];
        }
        [self.view addSubview:newView];
        [self.colorViews addObject:newView];
    }
}

@end
