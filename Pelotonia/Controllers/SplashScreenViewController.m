//
//  SplashScreenViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 5/21/13.
//
//

#import "SplashScreenViewController.h"
#import "InitialSlidingViewController.h"
#import "ECSlidingViewController.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    UIImage *bgImage = [UIImage imageNamed:@"default.png"];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight > 480)
    {
        // we're on iPhone 5
        bgImage = [UIImage imageNamed:@"default-568h.png"];
    }
    UIImageView *iv = [[UIImageView alloc] initWithImage:bgImage];
    iv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    iv.contentMode = UIViewContentModeCenter;
    self.view = iv;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hide
{
    [self performSegueWithIdentifier:@"fadeToInitial:" sender:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(hide) withObject:nil afterDelay:0];
}

- (void)fadeToInitial:(InitialSlidingViewController *)initialSlidingViewController
{
    // first hide the current view
    UIApplication *app = [UIApplication sharedApplication];
    [app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    // now start up our initial view controller for the sliding menu
    initialSlidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RidersNavViewController"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self performSelector:NSSelectorFromString(segue.identifier) withObject:segue.destinationViewController];
}

@end
