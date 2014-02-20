//
//  PhotoViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 2/19/14.
//
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

@synthesize pageViewController = _pageViewController;
@synthesize photos;
@synthesize currentPhotoIndex;

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
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoPageViewController"];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    SinglePhotoViewController *startingViewController = [self viewControllerAtIndex:currentPhotoIndex];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- convenience methods

- (SinglePhotoViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // Return the data view controller for the given index.
    if (([self.photos count] == 0) ||
        (index >= [self.photos count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    SinglePhotoViewController *photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePhotoViewController"];
    
    photoViewController.imageData = [self.photos objectAtIndex:index];
    return photoViewController;
}

- (NSUInteger)indexOfViewController:(SinglePhotoViewController *)viewController
{
    return [self.photos indexOfObject:viewController.imageData];
}

#pragma mark -- UIPageViewControllerDelegate and DataSource methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(SinglePhotoViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:
(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(SinglePhotoViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.photos count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.photos count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return self.currentPhotoIndex;
}


@end
