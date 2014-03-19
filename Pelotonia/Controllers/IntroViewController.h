//
//  IntroViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 3/9/14.
//
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController<UIPageViewControllerDataSource>

- (IBAction)startWalkthrough:(id)sender;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageDetailText;
@property (strong, nonatomic) NSArray *pageImages;

@end
