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
    UIImage *bgImage = [UIImage imageNamed:@"default"];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight > 480)
    {
        // we're on iPhone 5
        bgImage = [UIImage imageNamed:@"default-568h"];
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


- (void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(transitionToMainView) withObject:nil afterDelay:3];
}

- (void)transitionToMainView
{
    [self performSegueWithIdentifier:@"fadetToInitial:" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fadeToInitial"]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
}

@end
