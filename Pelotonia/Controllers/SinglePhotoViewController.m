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

@synthesize imageView;
@synthesize index;
@synthesize asset;

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
    PHImageManager *manager = [PHImageManager defaultManager];
    
    [manager requestImageForAsset:self.asset
                                 targetSize: CGSizeMake(320, 475)
                                contentMode: PHImageContentModeAspectFit
                                    options: nil
                              resultHandler: ^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  if (result != nil) {
                                      self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                                      [self.imageView setImage:result];
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

@end
