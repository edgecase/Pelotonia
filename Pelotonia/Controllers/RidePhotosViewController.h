//
//  RidePhotosViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 2/18/14.
//
//

@import UIKit;
@import Photos;
#import "Pelotonia-Swift.h"

@interface RidePhotosViewController : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) PHFetchResult *photos;
@property (strong, nonatomic) PHCachingImageManager *imageManager;

@end
