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

@interface RidePhotosViewController () {

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
    self.photos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    self.imageManager = [[PHCachingImageManager alloc] init];
}

- (void)viewDidUnload
{
    self.library = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
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
    return [self.photos count];
}

// The cell that is returned must be retrieved from a call to - dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RiderPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"riderPhotoCell" forIndexPath:indexPath];
    cell.imageAsset = [self.photos objectAtIndex:indexPath.row];
    cell.imageManager = self.imageManager;
    
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
