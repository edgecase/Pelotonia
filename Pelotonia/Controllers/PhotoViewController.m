//
//  PhotoViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 2/19/14.
//
//

#import "PhotoViewController.h"
#import "TestFlight.h"
#import "AppDelegate.h"
#import <Socialize/Socialize.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Social/Social.h>

@interface PhotoViewController () {
    ALAssetsLibrary *library;
}

@end

@implementation PhotoViewController

@synthesize pageViewController = _pageViewController;
@synthesize photos;
@synthesize initialPhotoIndex;

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
    library = [[ALAssetsLibrary alloc] init];
    
    SinglePhotoViewController *startingViewController = [self viewControllerAtIndex:self.initialPhotoIndex];
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

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
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
    return self.initialPhotoIndex;
}


- (IBAction)sharePhoto:(id)sender {
    // prompt for which service to share with (FB/Twitter/etc)
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Share photo to...?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", nil];
    [sheet showFromBarButtonItem:[self.navigationItem rightBarButtonItem] animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) {
            [self shareCurrentPhotoWithFacebook];
        }
        if (buttonIndex == 1) {
            [self shareCurrentPhotoWithTwitter];
        }
    }
}


- (void)shareCurrentPhotoWithFacebook
{
    NSInteger currentIndex = [self indexOfViewController:[[self.pageViewController viewControllers] objectAtIndex:0]];
    NSDictionary *photo = [self.photos objectAtIndex:currentIndex];
    
    [library assetForURL:[NSURL URLWithString:[photo objectForKey:@"key"]] resultBlock:^(ALAsset *asset) {
        // success - share the photo via facebook
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            [controller setInitialText:@""];
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            CGImageRef image = [rep fullScreenImage];
            [controller addImage:[UIImage imageWithCGImage:image]];
            [self presentViewController:controller animated:YES completion:Nil];
        }
    } failureBlock:^(NSError *error) {
        // failure
        NSLog(@"An error occurred: %@", [error localizedDescription]);
    }];
}

- (void)shareCurrentPhotoWithTwitter
{
    NSInteger currentIndex = [self indexOfViewController:[[self.pageViewController viewControllers] objectAtIndex:0]];
    NSDictionary *photo = [self.photos objectAtIndex:currentIndex];
    
    [library assetForURL:[NSURL URLWithString:[photo objectForKey:@"key"]] resultBlock:^(ALAsset *asset) {
        // success - share the photo via twitter
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *controller = [SLComposeViewController
                                                   composeViewControllerForServiceType:SLServiceTypeTwitter];
            [controller setInitialText:@""];
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            CGImageRef image = [rep fullScreenImage];
            [controller addImage:[UIImage imageWithCGImage:image]];
            [self presentViewController:controller animated:YES completion:nil];
        }
    } failureBlock:^(NSError *error) {
        // failure
        NSLog(@"An error occurred: %@", [error localizedDescription]);
    }];

}
@end
