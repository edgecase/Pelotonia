//
//  RidePhotosViewController.m
//  Pelotonia
//
//  Created by Mark Harris on 2/18/14.
//
//

#import "AppDelegate.h"
#import "RidePhotosViewController.h"
#import "RiderPhotoCell.h"
#import "PhotoViewController.h"
#import "Pelotonia-Swift.h"

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

    [[AppDelegate pelotoniaPhotoLibrary] images:^(PHFetchResult * _Nonnull photos) {
        self.photos = photos;
    }];
    self.imageManager = [[PHCachingImageManager alloc] init];
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
    
    cell.tag = indexPath.row;
    cell.imageManager = self.imageManager;
    
    [self.imageManager requestImageForAsset: [self.photos objectAtIndex:indexPath.row]
                                 targetSize: CGSizeMake(165, 165)
                                contentMode: PHImageContentModeAspectFit
                                    options: nil
                              resultHandler: ^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  [cell.imageView setImage:result];
                              }];

    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToShowPhoto"]) {
        PhotoViewController *vc = (PhotoViewController *)segue.destinationViewController;
        vc.photos = self.photos;
        RiderPhotoCell *rc = (RiderPhotoCell *)sender;
        vc.initialPhotoIndex = rc.tag;
    }
}

@end
