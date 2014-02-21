//
//  SinglePhotoViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 2/18/14.
//
//

#import "SinglePhotoViewController.h"
#import "UIImage+Resize.h"
#import <SDWebImage/SDImageCache.h>

@interface SinglePhotoViewController ()

@end

@implementation SinglePhotoViewController

@synthesize library;
@synthesize imageView;
@synthesize imageData;

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
    self.library = [[ALAssetsLibrary alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSString *key = [self.imageData objectForKey:@"key"];
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType) {
        if (image == nil) {
            [self.library assetForURL:[NSURL URLWithString:key] resultBlock:^(ALAsset *asset) {
                // success, so set the image appropriately
                self.imageView.contentMode = UIViewContentModeScaleAspectFit;
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
@end
