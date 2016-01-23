//
//  SinglePhotoViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 2/18/14.
//
//

#import "SinglePhotoViewController.h"
#import "UIImage+Resize.h"
#import "AppDelegate.h"
#import <SDWebImage/SDImageCache.h>

@interface SinglePhotoViewController ()

@end

@implementation SinglePhotoViewController

@synthesize library;
@synthesize imageView;
@synthesize imageData;
@synthesize index;

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
    self.library = [[AppDelegate sharedDataController] sharedAssetsLibrary];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:self.toolbar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//iOS 6+
- (BOOL)shouldAutorotate
{
    return YES;
}

//iOS 6+
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return (UIInterfaceOrientationMaskAllButUpsideDown);
}


- (void)viewWillAppear:(BOOL)animated
{
    NSString *key = [self.imageData objectForKey:@"key"];
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType) {
        if (image == nil) {
            [self.library assetForURL:[NSURL URLWithString:key] resultBlock:^(ALAsset *asset) {
                // success, so set the image appropriately
                self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                CGImageRef image = [rep fullScreenImage];
                [self.imageView setImage:[UIImage imageWithCGImage:image]];
                
            } failureBlock:^(NSError *error) {
                NSLog(@"error loading image %@", [error localizedDescription]);
                self.imageView.contentMode = UIViewContentModeScaleAspectFit;
                [self.imageView setImage:[[UIImage imageNamed:@"profile_default_thumb"] resizedImage:self.imageView.bounds.size interpolationQuality:kCGInterpolationHigh]];
            }];
        }
        else {
            [self.imageView setImage:image];
        }
    }];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self orientStartImageView];
}

- (void) orientStartImageView
{
    UIInterfaceOrientation curOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (curOrientation == UIInterfaceOrientationPortrait || curOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        [self.imageView setFrame:CGRectMake(0, 0, 320, 475)];
    }else{
        [self.imageView setFrame:CGRectMake(0, 0, 475, 320)];
    }
}

- (IBAction)trashPhoto:(id)sender {
    NSLog(@"delete called");
    [[[AppDelegate sharedDataController] photoKeys] removeObjectAtIndex:self.index];
    SDImageCache *cache = [SDImageCache sharedImageCache];
    [cache clearDisk];
    [cache clearMemory];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
