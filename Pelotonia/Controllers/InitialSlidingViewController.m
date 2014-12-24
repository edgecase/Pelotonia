//
//  InitialSlidingViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 4/14/13.
//
//

#import "InitialSlidingViewController.h"
#import "SplashScreenViewController.h"
#import <Socialize/Socialize.h>
#import "NSDictionary+JSONConversion.h"
#import "Rider.h"
#import "ProfileTableViewController.h"

@interface InitialSlidingViewController ()

@end

@implementation InitialSlidingViewController

@synthesize iv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)fadeBGImage {
    [self.iv removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate

{
    return YES;
    
}
@end
