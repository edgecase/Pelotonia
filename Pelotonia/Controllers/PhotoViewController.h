//
//  PhotoViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 2/19/14.
//
//

@import UIKit;
@import Photos;

#import "PhotoPageViewController.h"
#import "SinglePhotoViewController.h"

@interface PhotoViewController : UIViewController<UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIActionSheetDelegate>

@property (weak, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) PHFetchResult *photos;
@property (assign, nonatomic) NSInteger initialPhotoIndex;

- (IBAction)sharePhoto:(id)sender;
@end
