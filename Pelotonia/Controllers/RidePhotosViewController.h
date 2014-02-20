//
//  RidePhotosViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 2/18/14.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface RidePhotosViewController : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) ALAssetsLibrary *library;

@end
