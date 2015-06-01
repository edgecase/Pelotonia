//
//  PhotoViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 2/19/14.
//
//

#import <UIKit/UIKit.h>
#import "PhotoPageViewController.h"
#import "SinglePhotoViewController.h"

@interface PhotoViewController : UIViewController<UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIActionSheetDelegate>

@property (weak, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *photos;
@property (assign, nonatomic) NSInteger initialPhotoIndex;
@property (strong, nonatomic) ALAssetsLibrary *library;

- (IBAction)sharePhoto:(id)sender;
@end
