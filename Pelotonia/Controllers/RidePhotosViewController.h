//
//  RidePhotosViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 2/18/14.
//
//

@import UIKit;
@import Photos;

@interface RidePhotosViewController : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) PHPhotoLibrary *library;

@end
