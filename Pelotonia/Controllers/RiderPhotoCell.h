//
//  RiderPhotoCell.h
//  Pelotonia
//
//  Created by Mark Harris on 2/18/14.
//
//

@import UIKit;
@import Photos;


@interface RiderPhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) PHAsset *imageAsset;
@property (strong, nonatomic) PHImageManager *imageManager;

@end
