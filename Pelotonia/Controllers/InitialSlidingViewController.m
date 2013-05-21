//
//  InitialSlidingViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 4/14/13.
//
//

#import "InitialSlidingViewController.h"
#import "SplashScreenViewController.h"

@interface InitialSlidingViewController ()

@end

@implementation InitialSlidingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    self.topViewController = [storyboard instantiateViewControllerWithIdentifier:@"RidersNavViewController"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
