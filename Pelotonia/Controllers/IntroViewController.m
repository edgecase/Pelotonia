//
//  IntroViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 3/9/14.
//
//

#import "IntroViewController.h"
#import "IntroContentViewController.h"
#import "IntroPageViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

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
    self.pageTitles = @[@"Rides, Photos, & Donations", @"Your Profile at a Glance", @"Solicit Donations on the Go", @"Support your Team", @"Share Your Progress"];
    self.pageDetailText = @[@"Everything you need to remember a great Pelotonia",
                            @"Track your stats in the palm of your hand",
                            @"Solicit donations through email in real time",
                            @"Follow your favorite riders' progress",
                            @"Keep friends & family up to date on Facebook or Twitter"];
    self.pageImages = @[@"user_profile", @"rider_profile", @"solicit_donations", @"follow_friends", @"share_progress"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroPageViewController"];
    self.pageViewController.dataSource = self;
    
    IntroContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate

{
    return NO;
    
}

#pragma mark -- UI Actions
- (IBAction)startWalkthrough:(id)sender
{
    NSLog(@"we're done!");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Page View Controller Helpers

- (IntroContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    IntroContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.detailText = self.pageDetailText[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((IntroContentViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((IntroContentViewController *) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


@end
