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

@interface PhotoViewController : UIViewController<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (weak, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *photos;
@property (assign, nonatomic) NSInteger currentPhotoIndex;

@end
