//
//  IntroContentViewController.h
//  Pelotonia
//
//  Created by Mark Harris on 3/9/14.
//
//

#import <UIKit/UIKit.h>

@interface IntroContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *detailTextLabel;

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
@property NSString *detailText;

@end
