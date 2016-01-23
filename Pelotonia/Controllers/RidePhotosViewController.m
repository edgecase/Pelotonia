//
//  RidePhotosViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 2/18/14.
//
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"
#import "RidePhotosViewController.h"
#import "RiderPhotoCell.h"
#import "PhotoViewController.h"
#import "UIImage+Resize.h"
#import "AppDelegate.h"

@interface RidePhotosViewController () {
    NSArray *_photos;
}

@end

@implementation RidePhotosViewController

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
    self.library = [PHPhotoLibrary sharedPhotoLibrary];
}

- (void)viewDidUnload
{
    self.library = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    _photos = [[AppDelegate sharedDataController] photoKeys];
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -- UICollectionViewDataSource methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_photos count];
}

// The cell that is returned must be retrieved from a call to - dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RiderPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"riderPhotoCell" forIndexPath:indexPath];
    NSString *key = [[_photos objectAtIndex:indexPath.row] objectForKey:@"key"];
    NSLog(@"loading cell %ld", (long)indexPath.row);
    
    // load the image from the absolute URL
//    [self.library assetForURL:[NSURL URLWithString:key] resultBlock:^(ALAsset *asset) {
//        [cell.imageView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
//        cell.tag = indexPath.row;
//    } failureBlock:^(NSError *error) {
//        NSLog(@"error loading image %@", [error localizedDescription]);
//        [cell.imageView setImage:[[UIImage imageNamed:@"profile_default_thumb"] resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:cell.imageView.bounds.size  interpolationQuality:kCGInterpolationDefault]];
//    }];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToShowPhoto"]) {
        PhotoViewController *vc = (PhotoViewController *)segue.destinationViewController;
        vc.photos = [_photos mutableCopy];
        RiderPhotoCell *rc = (RiderPhotoCell *)sender;
        vc.initialPhotoIndex = rc.tag;
    }
}

@end
